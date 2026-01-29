/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 6: Enhanced Capabilities for Talk Track Support
 * 
 * Adds:
 * 1. BatchDeviceCommand - Execute commands on multiple devices
 * 2. Cost-by-Failure-Cause view - Which failure types cost most
 * 3. Remote-Fixable Triage view - Classify what can be fixed remotely
 * 4. Predicted Impact calculation - Business impact of predicted failures
 * 
 * SCRIPT EXECUTION ORDER:
 * =======================
 * 1. 01_create_database_and_data.sql    - Base tables and sample data
 * 2. 02_create_semantic_views.sql       - Semantic views for agent
 * 3. 03_create_cortex_search.sql        - Cortex Search services
 * 4. 04_create_agent.sql                - Agent definition
 * 5. 05_predictive_simulation.sql       - Prediction simulation
 * 6. ML_Device_Failure_Prediction.ipynb - Train XGBoost & create prediction views (REQUIRED!)
 * 7. 06_enhanced_capabilities.sql       - This file
 * 
 * OPTIONAL (for more training data):
 * 8. 07_expanded_training_data.sql      - 6 months of data (destructive!)
 *    Then re-run the ML notebook after 07.
 * 
 * Prerequisites: Run 01-05 scripts, then the ML notebook. The notebook creates
 * the views this script depends on: V_ML_FAILURE_PREDICTIONS, V_DEVICE_ML_FEATURES
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEVICE_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- 1. BATCH DEVICE COMMAND PROCEDURE
-- Execute commands on multiple devices at once based on criteria
-- ============================================================================

CREATE OR REPLACE PROCEDURE BATCH_DEVICE_COMMAND(
    COMMAND VARCHAR,           -- RESTART_SERVICES, CLEAR_CACHE, RESET_NETWORK, FORCE_REBOOT
    CRITERIA VARCHAR,          -- 'HIGH_RISK', 'OFFLINE', 'DEGRADED', 'WIFI_ISSUE', or comma-separated device IDs
    REASON VARCHAR
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    devices_affected INT := 0;
    devices_success INT := 0;
    devices_failed INT := 0;
    result VARIANT;
    device_list ARRAY;
    batch_id VARCHAR;
BEGIN
    batch_id := 'BATCH-' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS');
    
    -- Determine which devices to target based on criteria
    IF (:CRITERIA = 'HIGH_RISK') THEN
        -- Target devices predicted to fail in 48h that are still online
        SELECT ARRAY_AGG(DEVICE_ID) INTO device_list
        FROM V_ML_FAILURE_PREDICTIONS
        WHERE WILL_FAIL_48H = 1 AND STATUS = 'ONLINE';
    ELSEIF (:CRITERIA = 'OFFLINE') THEN
        -- Target offline devices (for restart attempts)
        SELECT ARRAY_AGG(DEVICE_ID) INTO device_list
        FROM DEVICE_INVENTORY WHERE STATUS = 'OFFLINE';
    ELSEIF (:CRITERIA = 'DEGRADED') THEN
        -- Target degraded devices
        SELECT ARRAY_AGG(DEVICE_ID) INTO device_list
        FROM DEVICE_INVENTORY WHERE STATUS = 'DEGRADED';
    ELSEIF (:CRITERIA = 'WIFI_ISSUE') THEN
        -- Target devices with recent Wi-Fi signal issues
        SELECT ARRAY_AGG(DISTINCT lg.DEVICE_ID) INTO device_list
        FROM DEVICE_LAST_GASP lg
        JOIN DEVICE_INVENTORY d ON lg.DEVICE_ID = d.DEVICE_ID
        WHERE lg.CLASSIFIED_CAUSE = 'WIFI_PASSWORD_CHANGE'
        AND lg.OFFLINE_TIMESTAMP > DATEADD('day', -1, CURRENT_TIMESTAMP());
    ELSE
        -- Assume comma-separated device IDs
        SELECT ARRAY_AGG(VALUE) INTO device_list
        FROM TABLE(SPLIT_TO_TABLE(:CRITERIA, ','));
    END IF;
    
    devices_affected := ARRAY_SIZE(device_list);
    
    -- Simulate batch execution (in production, this would call external API)
    -- For demo, we log each command and simulate 90% success rate
    INSERT INTO EXTERNAL_ACTION_LOG (
        ACTION_TYPE, TARGET_SYSTEM, TARGET_DEVICE_ID, COMMAND, PAYLOAD, INITIATED_BY, STATUS, NOTES
    )
    SELECT 
        'BATCH_DEVICE_COMMAND',
        'Device Management API',
        d.VALUE::VARCHAR,
        :COMMAND,
        OBJECT_CONSTRUCT(
            'batch_id', :batch_id,
            'api_endpoint', 'https://api.deviceops.example.com/v1/devices/' || d.VALUE::VARCHAR || '/command',
            'command', :COMMAND,
            'reason', :REASON,
            'batch_criteria', :CRITERIA
        ),
        'AI_AGENT',
        CASE WHEN UNIFORM(0, 100, RANDOM()) < 90 THEN 'SUCCESS' ELSE 'FAILED' END,
        'Batch command ' || :batch_id || ' - ' || :COMMAND || ' via ' || :CRITERIA
    FROM TABLE(FLATTEN(device_list)) d;
    
    -- Count successes and failures
    SELECT 
        COUNT(CASE WHEN STATUS = 'SUCCESS' THEN 1 END),
        COUNT(CASE WHEN STATUS = 'FAILED' THEN 1 END)
    INTO devices_success, devices_failed
    FROM EXTERNAL_ACTION_LOG
    WHERE PAYLOAD:batch_id = :batch_id;
    
    -- Calculate estimated savings (avg $150 per avoided truck roll)
    result := OBJECT_CONSTRUCT(
        'status', 'COMPLETED',
        'batch_id', :batch_id,
        'command', :COMMAND,
        'criteria', :CRITERIA,
        'devices_targeted', devices_affected,
        'devices_success', devices_success,
        'devices_failed', devices_failed,
        'success_rate', ROUND(devices_success * 100.0 / NULLIF(devices_affected, 0), 1),
        'estimated_savings', devices_success * 150,
        'message', 'Batch command completed. ' || devices_success || ' of ' || devices_affected || ' devices responded successfully.',
        'note', 'SIMULATED - In production, this would execute via External Function to Device API'
    );
    
    RETURN result;
END;
$$;

GRANT USAGE ON PROCEDURE BATCH_DEVICE_COMMAND(VARCHAR, VARCHAR, VARCHAR) TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- 2. COST BY FAILURE CAUSE VIEW
-- Answer: "Which failure type costs us the most to fix?"
-- ============================================================================

CREATE OR REPLACE VIEW V_COST_BY_FAILURE_CAUSE AS
WITH failure_costs AS (
    SELECT 
        lg.CLASSIFIED_CAUSE,
        COUNT(*) as INCIDENT_COUNT,
        -- Estimated costs by failure type
        CASE lg.CLASSIFIED_CAUSE
            WHEN 'WIFI_PASSWORD_CHANGE' THEN 150  -- Phone call + remote config
            WHEN 'HARDWARE_FAILURE' THEN 280      -- Truck roll + parts
            WHEN 'NETWORK_OUTAGE' THEN 50         -- Monitoring only, usually resolves
            WHEN 'POWER_LOSS' THEN 100            -- Remote restart or quick visit
            ELSE 200
        END as AVG_COST_PER_INCIDENT,
        CASE lg.CLASSIFIED_CAUSE
            WHEN 'WIFI_PASSWORD_CHANGE' THEN TRUE   -- Can call office
            WHEN 'HARDWARE_FAILURE' THEN FALSE      -- Needs dispatch
            WHEN 'NETWORK_OUTAGE' THEN TRUE         -- Wait and monitor
            WHEN 'POWER_LOSS' THEN TRUE             -- Remote restart
            ELSE FALSE
        END as REMOTE_FIXABLE,
        CASE lg.CLASSIFIED_CAUSE
            WHEN 'WIFI_PASSWORD_CHANGE' THEN 'Call provider office for new Wi-Fi credentials'
            WHEN 'HARDWARE_FAILURE' THEN 'Dispatch field technician for repair/replacement'
            WHEN 'NETWORK_OUTAGE' THEN 'Monitor - provider network issue, usually self-resolves'
            WHEN 'POWER_LOSS' THEN 'Attempt remote restart, escalate if fails'
            ELSE 'Manual triage required'
        END as RECOMMENDED_ACTION
    FROM DEVICE_LAST_GASP lg
    WHERE lg.CLASSIFIED_CAUSE IS NOT NULL
    AND lg.OFFLINE_TIMESTAMP > DATEADD('day', -30, CURRENT_TIMESTAMP())
    GROUP BY lg.CLASSIFIED_CAUSE
)
SELECT 
    CLASSIFIED_CAUSE,
    INCIDENT_COUNT,
    AVG_COST_PER_INCIDENT,
    INCIDENT_COUNT * AVG_COST_PER_INCIDENT as TOTAL_COST_30D,
    REMOTE_FIXABLE,
    RECOMMENDED_ACTION,
    ROUND(INCIDENT_COUNT * 100.0 / SUM(INCIDENT_COUNT) OVER (), 1) as PCT_OF_INCIDENTS
FROM failure_costs
ORDER BY TOTAL_COST_30D DESC;

-- ============================================================================
-- 3. REMOTE-FIXABLE TRIAGE VIEW
-- Answer: "Can we prevent any of these failures automatically?"
-- Classifies at-risk devices into: REMOTE_RESTART, WIFI_CREDENTIAL_UPDATE, NEEDS_DISPATCH
-- ============================================================================

CREATE OR REPLACE VIEW V_DEVICE_TRIAGE AS
WITH at_risk_devices AS (
    SELECT 
        p.DEVICE_ID,
        p.STATUS,
        p.DEVICE_TYPE,
        p.NETWORK_TYPE,
        p.WILL_FAIL_48H,
        p.PREDICTED_HOURS_TO_FAILURE,
        p.RISK_LEVEL,
        f.AVG_CPU_TEMP_24H,
        f.ERRORS_24H,
        f.AVG_WIFI_SIGNAL_24H,
        f.WIFI_SIGNAL_VOLATILITY,
        f.WIFI_SIGNAL_TREND,
        lg.CLASSIFIED_CAUSE as LAST_FAILURE_CAUSE
    FROM V_ML_FAILURE_PREDICTIONS p
    LEFT JOIN V_DEVICE_ML_FEATURES f ON p.DEVICE_ID = f.DEVICE_ID
    LEFT JOIN (
        SELECT DEVICE_ID, CLASSIFIED_CAUSE,
               ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY OFFLINE_TIMESTAMP DESC) as rn
        FROM DEVICE_LAST_GASP
    ) lg ON p.DEVICE_ID = lg.DEVICE_ID AND lg.rn = 1
    WHERE p.RISK_LEVEL IN ('CRITICAL', 'WARNING')
)
SELECT 
    DEVICE_ID,
    STATUS,
    DEVICE_TYPE,
    NETWORK_TYPE,
    RISK_LEVEL,
    PREDICTED_HOURS_TO_FAILURE,
    
    -- Triage classification
    CASE 
        -- High CPU/Memory issues → Remote restart can help
        WHEN AVG_CPU_TEMP_24H > 75 OR ERRORS_24H > 5 THEN 'REMOTE_RESTART'
        
        -- Wi-Fi signal issues on provider network → Credential update likely needed
        WHEN NETWORK_TYPE = 'PROVIDER_WIFI' 
             AND (AVG_WIFI_SIGNAL_24H < -70 OR WIFI_SIGNAL_VOLATILITY > 10 OR WIFI_SIGNAL_TREND < -5)
        THEN 'WIFI_CREDENTIAL_UPDATE'
        
        -- Previous Wi-Fi failure → Likely same issue
        WHEN LAST_FAILURE_CAUSE = 'WIFI_PASSWORD_CHANGE' THEN 'WIFI_CREDENTIAL_UPDATE'
        
        -- Previous hardware failure → Needs dispatch
        WHEN LAST_FAILURE_CAUSE = 'HARDWARE_FAILURE' THEN 'NEEDS_DISPATCH'
        
        -- Network issues → Monitor, usually self-resolves
        WHEN LAST_FAILURE_CAUSE = 'NETWORK_OUTAGE' THEN 'MONITOR_ONLY'
        
        -- Default: Try remote restart first
        WHEN STATUS = 'ONLINE' THEN 'REMOTE_RESTART'
        
        -- Offline with no clear cause → Needs investigation
        ELSE 'NEEDS_DISPATCH'
    END as TRIAGE_ACTION,
    
    -- Estimated cost to resolve
    CASE 
        WHEN AVG_CPU_TEMP_24H > 75 OR ERRORS_24H > 5 THEN 0  -- Free remote restart
        WHEN NETWORK_TYPE = 'PROVIDER_WIFI' AND AVG_WIFI_SIGNAL_24H < -70 THEN 50  -- Phone call
        WHEN LAST_FAILURE_CAUSE = 'WIFI_PASSWORD_CHANGE' THEN 50
        WHEN LAST_FAILURE_CAUSE = 'HARDWARE_FAILURE' THEN 280
        WHEN STATUS = 'ONLINE' THEN 0
        ELSE 185  -- Avg dispatch cost
    END as ESTIMATED_RESOLUTION_COST,
    
    -- Can be fixed without dispatch?
    CASE 
        WHEN AVG_CPU_TEMP_24H > 75 OR ERRORS_24H > 5 THEN TRUE
        WHEN NETWORK_TYPE = 'PROVIDER_WIFI' AND AVG_WIFI_SIGNAL_24H < -70 THEN TRUE
        WHEN LAST_FAILURE_CAUSE IN ('WIFI_PASSWORD_CHANGE', 'NETWORK_OUTAGE', 'POWER_LOSS') THEN TRUE
        WHEN STATUS = 'ONLINE' THEN TRUE
        ELSE FALSE
    END as REMOTE_FIXABLE,
    
    AVG_CPU_TEMP_24H,
    ERRORS_24H,
    AVG_WIFI_SIGNAL_24H,
    LAST_FAILURE_CAUSE
    
FROM at_risk_devices
ORDER BY 
    CASE RISK_LEVEL WHEN 'CRITICAL' THEN 1 WHEN 'WARNING' THEN 2 ELSE 3 END,
    PREDICTED_HOURS_TO_FAILURE;

-- Summary view for talk track
CREATE OR REPLACE VIEW V_TRIAGE_SUMMARY AS
SELECT 
    TRIAGE_ACTION,
    COUNT(*) as DEVICE_COUNT,
    SUM(CASE WHEN REMOTE_FIXABLE THEN 1 ELSE 0 END) as REMOTE_FIXABLE_COUNT,
    SUM(ESTIMATED_RESOLUTION_COST) as TOTAL_ESTIMATED_COST,
    ROUND(AVG(PREDICTED_HOURS_TO_FAILURE), 1) as AVG_HOURS_TO_FAILURE
FROM V_DEVICE_TRIAGE
GROUP BY TRIAGE_ACTION
ORDER BY DEVICE_COUNT DESC;

-- ============================================================================
-- 4. PREDICTED IMPACT VIEW
-- Answer: "What's the business impact if these predicted failures occur?"
-- ============================================================================

CREATE OR REPLACE VIEW V_PREDICTED_FAILURE_IMPACT AS
WITH predictions AS (
    SELECT 
        p.DEVICE_ID,
        p.RISK_LEVEL,
        p.PREDICTED_HOURS_TO_FAILURE,
        p.DEVICE_TYPE,  -- Use DEVICE_TYPE from predictions view (already computed)
        p.FACILITY_NAME,
        p.HOURLY_AD_REVENUE_USD as HOURLY_REVENUE,  -- Use actual device revenue
        -- Estimated resolution cost
        CASE 
            WHEN t.REMOTE_FIXABLE THEN 25    -- Remote fix cost
            ELSE 185                          -- Field dispatch cost
        END as RESOLUTION_COST,
        t.TRIAGE_ACTION,
        t.REMOTE_FIXABLE
    FROM V_ML_FAILURE_PREDICTIONS p
    LEFT JOIN V_DEVICE_TRIAGE t ON p.DEVICE_ID = t.DEVICE_ID
    WHERE p.WILL_FAIL_48H = 1
)
SELECT 
    DEVICE_ID,
    DEVICE_TYPE,
    FACILITY_NAME,
    RISK_LEVEL,
    PREDICTED_HOURS_TO_FAILURE,
    TRIAGE_ACTION,
    COALESCE(REMOTE_FIXABLE, FALSE) as REMOTE_FIXABLE,
    HOURLY_REVENUE,
    COALESCE(RESOLUTION_COST, 185) as RESOLUTION_COST,
    -- If device fails, estimate 24h downtime before resolution
    ROUND(HOURLY_REVENUE * 24, 2) as POTENTIAL_REVENUE_LOSS_24H,
    -- Total potential impact
    ROUND(COALESCE(RESOLUTION_COST, 185) + (HOURLY_REVENUE * 24), 2) as TOTAL_POTENTIAL_IMPACT
FROM predictions
ORDER BY TOTAL_POTENTIAL_IMPACT DESC;

-- Summary for talk track
CREATE OR REPLACE VIEW V_PREDICTED_IMPACT_SUMMARY AS
SELECT 
    COUNT(*) as DEVICES_AT_RISK,
    SUM(CASE WHEN REMOTE_FIXABLE THEN 1 ELSE 0 END) as CAN_FIX_REMOTELY,
    SUM(CASE WHEN NOT COALESCE(REMOTE_FIXABLE, FALSE) THEN 1 ELSE 0 END) as NEEDS_DISPATCH,
    ROUND(SUM(RESOLUTION_COST), 2) as TOTAL_FIELD_SERVICE_COST,
    ROUND(SUM(POTENTIAL_REVENUE_LOSS_24H), 2) as TOTAL_POTENTIAL_REVENUE_LOSS,
    ROUND(SUM(TOTAL_POTENTIAL_IMPACT), 2) as TOTAL_BUSINESS_IMPACT,
    -- Savings if we fix remotely where possible
    ROUND(SUM(CASE WHEN REMOTE_FIXABLE THEN 185 - 25 ELSE 0 END), 2) as POTENTIAL_SAVINGS_REMOTE_FIX,
    -- Per-device averages
    ROUND(AVG(TOTAL_POTENTIAL_IMPACT), 2) as AVG_IMPACT_PER_DEVICE,
    ROUND(AVG(POTENTIAL_REVENUE_LOSS_24H), 2) as AVG_REVENUE_LOSS_PER_DEVICE
FROM V_PREDICTED_FAILURE_IMPACT;

-- ============================================================================
-- 5. CREATE SEMANTIC VIEW FOR TRIAGE (Agent Integration)
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_TRIAGE
  COMMENT = 'Device triage analysis: Which devices can be fixed remotely vs need dispatch. Use for prioritizing maintenance actions.'
  TABLES (
    triage AS V_DEVICE_TRIAGE PRIMARY KEY (DEVICE_ID)
  )
  RELATIONSHIPS ()
  DIMENSIONS (
    triage.DEVICE_ID AS triage.device_id
      LABEL 'Device ID',
    triage.TRIAGE_ACTION AS triage.triage_action
      LABEL 'Triage Action'
      DESCRIPTION 'Recommended action: REMOTE_RESTART, WIFI_CREDENTIAL_UPDATE, NEEDS_DISPATCH, MONITOR_ONLY',
    triage.RISK_LEVEL AS triage.risk_level
      LABEL 'Risk Level',
    triage.REMOTE_FIXABLE AS triage.remote_fixable
      LABEL 'Remote Fixable'
      DESCRIPTION 'TRUE if device can be fixed without field dispatch'
  )
  METRICS (
    triage.devices_remote_fixable AS COUNT(CASE WHEN triage.REMOTE_FIXABLE THEN 1 END)
      LABEL 'Remote Fixable Devices'
      DESCRIPTION 'Count of at-risk devices that can be fixed remotely',
    triage.devices_need_dispatch AS COUNT(CASE WHEN NOT triage.REMOTE_FIXABLE THEN 1 END)
      LABEL 'Devices Needing Dispatch',
    triage.total_resolution_cost AS SUM(triage.ESTIMATED_RESOLUTION_COST)
      LABEL 'Total Resolution Cost'
  );

-- ============================================================================
-- 6. UPDATE AGENT WITH NEW TOOLS
-- Run this after updating 04_create_agent.sql
-- ============================================================================

-- Grant permissions
GRANT SELECT ON V_COST_BY_FAILURE_CAUSE TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON V_DEVICE_TRIAGE TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON V_TRIAGE_SUMMARY TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON V_PREDICTED_FAILURE_IMPACT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON V_PREDICTED_IMPACT_SUMMARY TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Test batch command (simulated)
-- CALL BATCH_DEVICE_COMMAND('RESTART_SERVICES', 'HIGH_RISK', 'Proactive restart for predicted failures');

-- View cost by failure cause
SELECT * FROM V_COST_BY_FAILURE_CAUSE;

-- View triage summary
SELECT * FROM V_TRIAGE_SUMMARY;

-- View predicted impact
SELECT * FROM V_PREDICTED_IMPACT_SUMMARY;

-- Sample triage details
SELECT * FROM V_DEVICE_TRIAGE LIMIT 10;
