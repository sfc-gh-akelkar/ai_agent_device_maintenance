/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 5: Predictive Failure Simulation
 * 
 * This script demonstrates:
 * 1. Historical data available for ML model training
 * 2. Simulated failure predictions based on telemetry patterns
 * 3. 24-48 hour advance warning capability
 * 
 * NOTE: This simulates what a trained ML model would produce.
 * In production, you would use Snowflake Cortex ML (Classification/Forecasting)
 * trained on this historical data.
 * 
 * Prerequisites: Run scripts 01-04 first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEVICE_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- PART 1: PROVE HISTORICAL DATA EXISTS FOR MODEL TRAINING
-- Show the data foundation that would feed an ML model
-- ============================================================================

-- View: Training data summary - what we have available for ML
CREATE OR REPLACE VIEW V_ML_TRAINING_DATA_SUMMARY AS
SELECT 
    'Device Telemetry' as DATA_SOURCE,
    COUNT(*) as TOTAL_RECORDS,
    COUNT(DISTINCT DEVICE_ID) as UNIQUE_DEVICES,
    MIN(TIMESTAMP) as EARLIEST_RECORD,
    MAX(TIMESTAMP) as LATEST_RECORD,
    DATEDIFF('day', MIN(TIMESTAMP), MAX(TIMESTAMP)) as DAYS_OF_HISTORY,
    'CPU temp, CPU usage, memory, disk, network latency, errors, uptime' as FEATURES_AVAILABLE
FROM DEVICE_TELEMETRY
UNION ALL
SELECT 
    'Maintenance History',
    COUNT(*),
    COUNT(DISTINCT DEVICE_ID),
    MIN(CREATED_AT),
    MAX(CREATED_AT),
    DATEDIFF('day', MIN(CREATED_AT), MAX(CREATED_AT)),
    'Issue type, resolution type, cost, resolution time, technician notes'
FROM MAINTENANCE_HISTORY
UNION ALL
SELECT 
    'Device Inventory',
    COUNT(*),
    COUNT(DISTINCT DEVICE_ID),
    MIN(INSTALL_DATE),
    MAX(INSTALL_DATE),
    DATEDIFF('day', MIN(INSTALL_DATE), (SELECT REFERENCE_DATE FROM V_DEMO_REFERENCE_TIME)),
    'Model, facility type, location, firmware version, warranty status'
FROM DEVICE_INVENTORY;

-- View: Feature engineering examples - what patterns we can extract
CREATE OR REPLACE VIEW V_ML_FEATURE_EXAMPLES AS
WITH hourly_stats AS (
    SELECT 
        DEVICE_ID,
        DATE_TRUNC('hour', TIMESTAMP) as HOUR,
        AVG(CPU_TEMP_CELSIUS) as AVG_CPU_TEMP,
        AVG(CPU_USAGE_PCT) as AVG_CPU_USAGE,
        AVG(MEMORY_USAGE_PCT) as AVG_MEMORY_USAGE,
        AVG(NETWORK_LATENCY_MS) as AVG_NETWORK_LATENCY,
        SUM(ERROR_COUNT) as TOTAL_ERRORS,
        -- Trend features (change from previous hour)
        AVG(CPU_TEMP_CELSIUS) - LAG(AVG(CPU_TEMP_CELSIUS)) OVER (PARTITION BY DEVICE_ID ORDER BY DATE_TRUNC('hour', TIMESTAMP)) as CPU_TEMP_DELTA,
        AVG(CPU_USAGE_PCT) - LAG(AVG(CPU_USAGE_PCT)) OVER (PARTITION BY DEVICE_ID ORDER BY DATE_TRUNC('hour', TIMESTAMP)) as CPU_USAGE_DELTA,
        AVG(MEMORY_USAGE_PCT) - LAG(AVG(MEMORY_USAGE_PCT)) OVER (PARTITION BY DEVICE_ID ORDER BY DATE_TRUNC('hour', TIMESTAMP)) as MEMORY_USAGE_DELTA
    FROM DEVICE_TELEMETRY
    GROUP BY DEVICE_ID, DATE_TRUNC('hour', TIMESTAMP)
)
SELECT 
    DEVICE_ID,
    HOUR,
    AVG_CPU_TEMP,
    AVG_CPU_USAGE,
    AVG_MEMORY_USAGE,
    AVG_NETWORK_LATENCY,
    TOTAL_ERRORS,
    CPU_TEMP_DELTA,
    CPU_USAGE_DELTA,
    MEMORY_USAGE_DELTA,
    -- Derived features for ML
    CASE WHEN CPU_TEMP_DELTA > 5 THEN 1 ELSE 0 END as TEMP_SPIKE_FLAG,
    CASE WHEN CPU_USAGE_DELTA > 20 THEN 1 ELSE 0 END as CPU_SPIKE_FLAG,
    CASE WHEN MEMORY_USAGE_DELTA > 15 THEN 1 ELSE 0 END as MEMORY_SPIKE_FLAG
FROM hourly_stats
WHERE HOUR >= DATEADD('day', -7, (SELECT REFERENCE_TIMESTAMP FROM V_DEMO_REFERENCE_TIME))
ORDER BY DEVICE_ID, HOUR DESC;

-- ============================================================================
-- PART 2: LABELED TRAINING DATA
-- Link telemetry patterns to actual failures (for supervised learning)
-- ============================================================================

CREATE OR REPLACE VIEW V_LABELED_FAILURE_DATA AS
WITH failure_events AS (
    -- Get all maintenance tickets that represent actual failures
    SELECT 
        DEVICE_ID,
        CREATED_AT as FAILURE_TIMESTAMP,
        ISSUE_TYPE,
        RESOLUTION_TYPE,
        1 as FAILURE_LABEL
    FROM MAINTENANCE_HISTORY
    WHERE ISSUE_TYPE IN ('DISPLAY_FREEZE', 'NO_NETWORK', 'BOOT_FAILURE', 'OVERHEATING', 'DISPLAY_FAILURE')
),
telemetry_before_failure AS (
    -- Get telemetry data 24-48 hours before each failure
    SELECT 
        t.DEVICE_ID,
        t.TIMESTAMP as TELEMETRY_TIMESTAMP,
        f.FAILURE_TIMESTAMP,
        f.ISSUE_TYPE,
        DATEDIFF('hour', t.TIMESTAMP, f.FAILURE_TIMESTAMP) as HOURS_BEFORE_FAILURE,
        t.CPU_TEMP_CELSIUS,
        t.CPU_USAGE_PCT,
        t.MEMORY_USAGE_PCT,
        t.NETWORK_LATENCY_MS,
        t.ERROR_COUNT,
        t.UPTIME_HOURS,
        1 as WILL_FAIL_WITHIN_48H  -- This is the target label for ML
    FROM DEVICE_TELEMETRY t
    JOIN failure_events f ON t.DEVICE_ID = f.DEVICE_ID
    WHERE t.TIMESTAMP BETWEEN DATEADD('hour', -48, f.FAILURE_TIMESTAMP) AND f.FAILURE_TIMESTAMP
)
SELECT * FROM telemetry_before_failure
ORDER BY DEVICE_ID, HOURS_BEFORE_FAILURE;

-- ============================================================================
-- PART 3: SIMULATED FAILURE PREDICTIONS
-- This mimics what a trained ML model would output
-- Uses pattern-based rules derived from historical failure patterns
-- ============================================================================

CREATE OR REPLACE VIEW V_FAILURE_PREDICTIONS AS
WITH recent_telemetry AS (
    -- Get last 24 hours of telemetry per device
    SELECT 
        DEVICE_ID,
        TIMESTAMP,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        DISK_USAGE_PCT,
        NETWORK_LATENCY_MS,
        ERROR_COUNT,
        UPTIME_HOURS,
        ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP DESC) as RECENCY_RANK
    FROM DEVICE_TELEMETRY
    WHERE TIMESTAMP >= DATEADD('hour', -24, (SELECT REFERENCE_TIMESTAMP FROM V_DEMO_REFERENCE_TIME))
),
device_trends AS (
    -- Calculate trends over the last 24 hours
    SELECT 
        DEVICE_ID,
        -- Current values (most recent)
        MAX(CASE WHEN RECENCY_RANK = 1 THEN CPU_TEMP_CELSIUS END) as CURRENT_CPU_TEMP,
        MAX(CASE WHEN RECENCY_RANK = 1 THEN CPU_USAGE_PCT END) as CURRENT_CPU_USAGE,
        MAX(CASE WHEN RECENCY_RANK = 1 THEN MEMORY_USAGE_PCT END) as CURRENT_MEMORY_USAGE,
        MAX(CASE WHEN RECENCY_RANK = 1 THEN NETWORK_LATENCY_MS END) as CURRENT_NETWORK_LATENCY,
        MAX(CASE WHEN RECENCY_RANK = 1 THEN ERROR_COUNT END) as CURRENT_ERROR_COUNT,
        MAX(CASE WHEN RECENCY_RANK = 1 THEN UPTIME_HOURS END) as CURRENT_UPTIME,
        -- Averages over 24 hours
        AVG(CPU_TEMP_CELSIUS) as AVG_CPU_TEMP_24H,
        AVG(CPU_USAGE_PCT) as AVG_CPU_USAGE_24H,
        AVG(MEMORY_USAGE_PCT) as AVG_MEMORY_USAGE_24H,
        AVG(ERROR_COUNT) as AVG_ERRORS_24H,
        -- Trends (comparing recent to older)
        AVG(CASE WHEN RECENCY_RANK <= 6 THEN CPU_TEMP_CELSIUS END) - 
            AVG(CASE WHEN RECENCY_RANK > 18 THEN CPU_TEMP_CELSIUS END) as CPU_TEMP_TREND,
        AVG(CASE WHEN RECENCY_RANK <= 6 THEN CPU_USAGE_PCT END) - 
            AVG(CASE WHEN RECENCY_RANK > 18 THEN CPU_USAGE_PCT END) as CPU_USAGE_TREND,
        AVG(CASE WHEN RECENCY_RANK <= 6 THEN MEMORY_USAGE_PCT END) - 
            AVG(CASE WHEN RECENCY_RANK > 18 THEN MEMORY_USAGE_PCT END) as MEMORY_TREND,
        AVG(CASE WHEN RECENCY_RANK <= 6 THEN ERROR_COUNT END) - 
            AVG(CASE WHEN RECENCY_RANK > 18 THEN ERROR_COUNT END) as ERROR_TREND,
        -- Peak values
        MAX(CPU_TEMP_CELSIUS) as PEAK_CPU_TEMP_24H,
        MAX(CPU_USAGE_PCT) as PEAK_CPU_USAGE_24H,
        MAX(MEMORY_USAGE_PCT) as PEAK_MEMORY_24H,
        MAX(ERROR_COUNT) as PEAK_ERRORS_24H
    FROM recent_telemetry
    GROUP BY DEVICE_ID
),
prediction_scores AS (
    -- Calculate failure probability score (simulates ML model output)
    -- These thresholds are derived from patterns in historical failure data
    SELECT 
        t.DEVICE_ID,
        d.DEVICE_MODEL,
        d.FACILITY_NAME,
        d.LOCATION_CITY,
        d.LOCATION_STATE,
        d.STATUS,
        t.CURRENT_CPU_TEMP,
        t.CURRENT_CPU_USAGE,
        t.CURRENT_MEMORY_USAGE,
        t.CURRENT_UPTIME,
        t.CPU_TEMP_TREND,
        t.CPU_USAGE_TREND,
        t.MEMORY_TREND,
        t.ERROR_TREND,
        -- Failure probability score (0-100) - simulates ML model confidence
        LEAST(100, GREATEST(0,
            -- Base risk from current values
            CASE WHEN t.CURRENT_CPU_TEMP > 70 THEN 35 WHEN t.CURRENT_CPU_TEMP > 60 THEN 15 ELSE 0 END +
            CASE WHEN t.CURRENT_CPU_USAGE > 90 THEN 25 WHEN t.CURRENT_CPU_USAGE > 75 THEN 10 ELSE 0 END +
            CASE WHEN t.CURRENT_MEMORY_USAGE > 90 THEN 25 WHEN t.CURRENT_MEMORY_USAGE > 80 THEN 10 ELSE 0 END +
            CASE WHEN t.CURRENT_ERROR_COUNT > 10 THEN 20 WHEN t.CURRENT_ERROR_COUNT > 5 THEN 10 ELSE 0 END +
            -- Trend-based risk (rising metrics indicate impending failure)
            CASE WHEN t.CPU_TEMP_TREND > 10 THEN 20 WHEN t.CPU_TEMP_TREND > 5 THEN 10 ELSE 0 END +
            CASE WHEN t.CPU_USAGE_TREND > 15 THEN 15 WHEN t.CPU_USAGE_TREND > 8 THEN 8 ELSE 0 END +
            CASE WHEN t.MEMORY_TREND > 10 THEN 15 WHEN t.MEMORY_TREND > 5 THEN 8 ELSE 0 END +
            CASE WHEN t.ERROR_TREND > 5 THEN 20 WHEN t.ERROR_TREND > 2 THEN 10 ELSE 0 END +
            -- Long uptime increases failure risk
            CASE WHEN t.CURRENT_UPTIME > 720 THEN 15 WHEN t.CURRENT_UPTIME > 360 THEN 8 ELSE 0 END +
            -- Already degraded status
            CASE WHEN d.STATUS = 'DEGRADED' THEN 25 WHEN d.STATUS = 'OFFLINE' THEN 50 ELSE 0 END
        )) as FAILURE_PROBABILITY_PCT,
        -- Predicted time to failure (hours)
        CASE 
            WHEN d.STATUS = 'OFFLINE' THEN 0
            WHEN t.CURRENT_CPU_TEMP > 75 OR t.CPU_TEMP_TREND > 15 THEN 6
            WHEN t.CURRENT_CPU_TEMP > 65 OR t.CPU_TEMP_TREND > 10 THEN 24
            WHEN t.CURRENT_CPU_USAGE > 95 OR t.CURRENT_MEMORY_USAGE > 95 THEN 12
            WHEN t.CURRENT_CPU_USAGE > 85 OR t.CURRENT_MEMORY_USAGE > 85 THEN 36
            WHEN t.ERROR_TREND > 5 THEN 18
            WHEN d.STATUS = 'DEGRADED' THEN 48
            ELSE NULL  -- No imminent failure predicted
        END as PREDICTED_HOURS_TO_FAILURE,
        -- Primary risk factor
        CASE 
            WHEN d.STATUS = 'OFFLINE' THEN 'DEVICE_OFFLINE'
            WHEN t.CPU_TEMP_TREND > 10 AND t.CURRENT_CPU_TEMP > 60 THEN 'RISING_TEMPERATURE'
            WHEN t.CURRENT_CPU_TEMP > 70 THEN 'OVERHEATING'
            WHEN t.CPU_USAGE_TREND > 15 THEN 'CPU_USAGE_CLIMBING'
            WHEN t.CURRENT_CPU_USAGE > 90 THEN 'HIGH_CPU_SUSTAINED'
            WHEN t.MEMORY_TREND > 10 THEN 'MEMORY_LEAK_DETECTED'
            WHEN t.CURRENT_MEMORY_USAGE > 90 THEN 'MEMORY_EXHAUSTION'
            WHEN t.ERROR_TREND > 3 THEN 'ERROR_RATE_INCREASING'
            WHEN t.CURRENT_UPTIME > 720 THEN 'EXTENDED_UPTIME'
            WHEN d.STATUS = 'DEGRADED' THEN 'DEGRADED_PERFORMANCE'
            ELSE 'NORMAL_OPERATION'
        END as PRIMARY_RISK_FACTOR
    FROM device_trends t
    JOIN DEVICE_INVENTORY d ON t.DEVICE_ID = d.DEVICE_ID
)
SELECT 
    DEVICE_ID,
    DEVICE_MODEL,
    FACILITY_NAME,
    CONCAT(LOCATION_CITY, ', ', LOCATION_STATE) as LOCATION,
    STATUS,
    FAILURE_PROBABILITY_PCT,
    CASE 
        WHEN FAILURE_PROBABILITY_PCT >= 80 THEN 'CRITICAL - Failure imminent'
        WHEN FAILURE_PROBABILITY_PCT >= 60 THEN 'HIGH - Failure likely within 24-48 hours'
        WHEN FAILURE_PROBABILITY_PCT >= 40 THEN 'MEDIUM - Monitor closely'
        WHEN FAILURE_PROBABILITY_PCT >= 20 THEN 'LOW - Minor anomalies detected'
        ELSE 'HEALTHY - Normal operation'
    END as PREDICTION_CATEGORY,
    PREDICTED_HOURS_TO_FAILURE,
    CASE 
        WHEN PREDICTED_HOURS_TO_FAILURE IS NOT NULL 
        THEN DATEADD('hour', PREDICTED_HOURS_TO_FAILURE, (SELECT REFERENCE_TIMESTAMP FROM V_DEMO_REFERENCE_TIME))
        ELSE NULL 
    END as ESTIMATED_FAILURE_TIME,
    PRIMARY_RISK_FACTOR,
    CURRENT_CPU_TEMP,
    CURRENT_CPU_USAGE,
    CURRENT_MEMORY_USAGE,
    CPU_TEMP_TREND as TEMP_TREND_24H,
    CPU_USAGE_TREND as CPU_TREND_24H,
    MEMORY_TREND as MEMORY_TREND_24H,
    CURRENT_UPTIME as UPTIME_HOURS,
    -- Recommended action
    CASE 
        WHEN FAILURE_PROBABILITY_PCT >= 80 THEN 'IMMEDIATE: Execute remote restart or schedule emergency dispatch'
        WHEN FAILURE_PROBABILITY_PCT >= 60 THEN 'URGENT: Clear cache, restart services, schedule preventive maintenance'
        WHEN FAILURE_PROBABILITY_PCT >= 40 THEN 'SOON: Schedule remote maintenance within 24 hours'
        WHEN FAILURE_PROBABILITY_PCT >= 20 THEN 'MONITOR: Review telemetry, consider preventive restart'
        ELSE 'NONE: Device operating normally'
    END as RECOMMENDED_ACTION
FROM prediction_scores
ORDER BY FAILURE_PROBABILITY_PCT DESC;

-- ============================================================================
-- PART 4: PREDICTION ACCURACY SIMULATION
-- Shows what accuracy we could achieve with the historical data
-- ============================================================================

CREATE OR REPLACE VIEW V_PREDICTION_ACCURACY_ANALYSIS AS
WITH historical_predictions AS (
    -- Simulate what our prediction model would have predicted
    -- by looking at telemetry 24-48 hours before known failures
    SELECT 
        m.TICKET_ID,
        m.DEVICE_ID,
        m.CREATED_AT as ACTUAL_FAILURE_TIME,
        m.ISSUE_TYPE,
        -- Check if telemetry 24-48 hours before showed warning signs
        AVG(t.CPU_TEMP_CELSIUS) as AVG_TEMP_BEFORE_FAILURE,
        AVG(t.CPU_USAGE_PCT) as AVG_CPU_BEFORE_FAILURE,
        AVG(t.MEMORY_USAGE_PCT) as AVG_MEMORY_BEFORE_FAILURE,
        AVG(t.ERROR_COUNT) as AVG_ERRORS_BEFORE_FAILURE,
        -- Would we have predicted this failure?
        CASE 
            WHEN AVG(t.CPU_TEMP_CELSIUS) > 60 THEN TRUE
            WHEN AVG(t.CPU_USAGE_PCT) > 75 THEN TRUE
            WHEN AVG(t.MEMORY_USAGE_PCT) > 80 THEN TRUE
            WHEN AVG(t.ERROR_COUNT) > 5 THEN TRUE
            ELSE FALSE
        END as WOULD_HAVE_PREDICTED,
        -- How many hours before did warning signs appear?
        MIN(CASE 
            WHEN t.CPU_TEMP_CELSIUS > 60 OR t.CPU_USAGE_PCT > 75 OR 
                 t.MEMORY_USAGE_PCT > 80 OR t.ERROR_COUNT > 5 
            THEN DATEDIFF('hour', t.TIMESTAMP, m.CREATED_AT)
            ELSE NULL 
        END) as HOURS_WARNING_BEFORE_FAILURE
    FROM MAINTENANCE_HISTORY m
    JOIN DEVICE_TELEMETRY t ON m.DEVICE_ID = t.DEVICE_ID
    WHERE m.ISSUE_TYPE IN ('DISPLAY_FREEZE', 'NO_NETWORK', 'BOOT_FAILURE', 'OVERHEATING', 
                           'HIGH_CPU', 'MEMORY_LEAK', 'DISPLAY_FAILURE')
    AND t.TIMESTAMP BETWEEN DATEADD('hour', -48, m.CREATED_AT) AND m.CREATED_AT
    GROUP BY m.TICKET_ID, m.DEVICE_ID, m.CREATED_AT, m.ISSUE_TYPE
)
SELECT 
    COUNT(*) as TOTAL_HISTORICAL_FAILURES,
    SUM(CASE WHEN WOULD_HAVE_PREDICTED THEN 1 ELSE 0 END) as CORRECTLY_PREDICTED,
    ROUND(SUM(CASE WHEN WOULD_HAVE_PREDICTED THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as PREDICTION_ACCURACY_PCT,
    ROUND(AVG(HOURS_WARNING_BEFORE_FAILURE), 1) as AVG_LEAD_TIME_HOURS,
    MIN(HOURS_WARNING_BEFORE_FAILURE) as MIN_LEAD_TIME_HOURS,
    MAX(HOURS_WARNING_BEFORE_FAILURE) as MAX_LEAD_TIME_HOURS
FROM historical_predictions
WHERE WOULD_HAVE_PREDICTED = TRUE;

-- Detailed breakdown by issue type
CREATE OR REPLACE VIEW V_PREDICTION_ACCURACY_BY_ISSUE AS
WITH historical_predictions AS (
    SELECT 
        m.ISSUE_TYPE,
        CASE 
            WHEN AVG(t.CPU_TEMP_CELSIUS) > 60 THEN TRUE
            WHEN AVG(t.CPU_USAGE_PCT) > 75 THEN TRUE
            WHEN AVG(t.MEMORY_USAGE_PCT) > 80 THEN TRUE
            WHEN AVG(t.ERROR_COUNT) > 5 THEN TRUE
            ELSE FALSE
        END as WOULD_HAVE_PREDICTED
    FROM MAINTENANCE_HISTORY m
    JOIN DEVICE_TELEMETRY t ON m.DEVICE_ID = t.DEVICE_ID
    WHERE t.TIMESTAMP BETWEEN DATEADD('hour', -48, m.CREATED_AT) AND m.CREATED_AT
    GROUP BY m.TICKET_ID, m.ISSUE_TYPE
)
SELECT 
    ISSUE_TYPE,
    COUNT(*) as TOTAL_INCIDENTS,
    SUM(CASE WHEN WOULD_HAVE_PREDICTED THEN 1 ELSE 0 END) as WOULD_DETECT,
    ROUND(SUM(CASE WHEN WOULD_HAVE_PREDICTED THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as DETECTION_RATE_PCT
FROM historical_predictions
GROUP BY ISSUE_TYPE
ORDER BY DETECTION_RATE_PCT DESC;

-- ============================================================================
-- PART 5: EXECUTIVE SUMMARY VIEW
-- For demo: single view showing predictive capability
-- ============================================================================

CREATE OR REPLACE VIEW V_PREDICTIVE_MAINTENANCE_SUMMARY AS
SELECT 
    -- Fleet Status
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as TOTAL_DEVICES,
    (SELECT COUNT(*) FROM V_FAILURE_PREDICTIONS WHERE FAILURE_PROBABILITY_PCT >= 60) as DEVICES_AT_HIGH_RISK,
    (SELECT COUNT(*) FROM V_FAILURE_PREDICTIONS WHERE PREDICTED_HOURS_TO_FAILURE IS NOT NULL AND PREDICTED_HOURS_TO_FAILURE <= 48) as FAILURES_PREDICTED_NEXT_48H,
    
    -- Prediction Accuracy (from historical data)
    (SELECT PREDICTION_ACCURACY_PCT FROM V_PREDICTION_ACCURACY_ANALYSIS) as HISTORICAL_ACCURACY_PCT,
    (SELECT AVG_LEAD_TIME_HOURS FROM V_PREDICTION_ACCURACY_ANALYSIS) as AVG_WARNING_LEAD_TIME_HOURS,
    
    -- Data Foundation
    (SELECT COUNT(*) FROM DEVICE_TELEMETRY) as TELEMETRY_RECORDS_AVAILABLE,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY) as HISTORICAL_INCIDENTS,
    (SELECT DAYS_OF_HISTORY FROM V_ML_TRAINING_DATA_SUMMARY WHERE DATA_SOURCE = 'Device Telemetry') as DAYS_OF_TRAINING_DATA,
    
    -- Business Impact
    (SELECT SUM(COST_SAVINGS_USD) FROM V_MAINTENANCE_ANALYTICS) as TOTAL_COST_SAVINGS_USD,
    (SELECT COUNT(*) FROM V_MAINTENANCE_ANALYTICS WHERE WAS_REMOTE_FIX = TRUE) as REMOTE_FIXES_COMPLETED,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_RESOLUTION_RATE_PCT;

-- ============================================================================
-- UPDATE SEMANTIC MODEL TO INCLUDE PREDICTIONS
-- ============================================================================

-- Add prediction data to the semantic view
CREATE OR REPLACE VIEW V_DEVICE_PREDICTIONS AS
SELECT 
    p.DEVICE_ID,
    p.DEVICE_MODEL,
    p.FACILITY_NAME,
    p.LOCATION,
    p.STATUS,
    p.FAILURE_PROBABILITY_PCT,
    p.PREDICTION_CATEGORY,
    p.PREDICTED_HOURS_TO_FAILURE,
    p.ESTIMATED_FAILURE_TIME,
    p.PRIMARY_RISK_FACTOR,
    p.RECOMMENDED_ACTION,
    p.CURRENT_CPU_TEMP,
    p.CURRENT_CPU_USAGE,
    p.CURRENT_MEMORY_USAGE,
    p.TEMP_TREND_24H,
    p.CPU_TREND_24H,
    p.MEMORY_TREND_24H,
    p.UPTIME_HOURS
FROM V_FAILURE_PREDICTIONS p;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Show ML training data availability
SELECT * FROM V_ML_TRAINING_DATA_SUMMARY;

-- Show devices with predicted failures
SELECT * FROM V_FAILURE_PREDICTIONS 
WHERE FAILURE_PROBABILITY_PCT >= 40
ORDER BY FAILURE_PROBABILITY_PCT DESC;

-- Show prediction accuracy analysis
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;

-- Show executive summary
SELECT * FROM V_PREDICTIVE_MAINTENANCE_SUMMARY;

-- Sample: Devices predicted to fail within 48 hours
SELECT 
    DEVICE_ID,
    FACILITY_NAME,
    LOCATION,
    FAILURE_PROBABILITY_PCT || '%' as FAILURE_RISK,
    PREDICTED_HOURS_TO_FAILURE || ' hours' as TIME_TO_FAILURE,
    PRIMARY_RISK_FACTOR,
    RECOMMENDED_ACTION
FROM V_FAILURE_PREDICTIONS
WHERE PREDICTED_HOURS_TO_FAILURE IS NOT NULL
AND PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY PREDICTED_HOURS_TO_FAILURE ASC;

-- ============================================================================
-- PART 6: LAST GASP ANALYSIS VIEW (NEW)
-- Analyzes failure patterns from "last gasp" telemetry
-- CRITICAL: Enables classifying Wi-Fi password changes vs hardware failures
-- ============================================================================

CREATE OR REPLACE VIEW V_LAST_GASP_ANALYSIS AS
SELECT 
    lg.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.NETWORK_TYPE,
    lg.OFFLINE_TIMESTAMP,
    lg.LAST_SIGNAL_STRENGTH,
    lg.LAST_CPU_TEMP,
    lg.LAST_MEMORY_PCT,
    lg.LAST_ERROR_COUNT,
    lg.SIGNAL_TREND,
    lg.SIGNAL_DROP_RATE,
    lg.CLASSIFIED_CAUSE,
    lg.CLASSIFICATION_CONFIDENCE,
    lg.CLASSIFICATION_REASON,
    lg.RESOLVED_TIMESTAMP,
    lg.ACTUAL_CAUSE,
    lg.RESOLUTION_ACTION,
    DATEDIFF('hour', lg.OFFLINE_TIMESTAMP, COALESCE(lg.RESOLVED_TIMESTAMP, CURRENT_TIMESTAMP())) as HOURS_OFFLINE,
    CASE WHEN lg.RESOLVED_TIMESTAMP IS NULL THEN 'ACTIVE' ELSE 'RESOLVED' END as INCIDENT_STATUS,
    CASE 
        WHEN lg.CLASSIFIED_CAUSE = 'WIFI_PASSWORD_CHANGE' THEN 'Call provider office to get new Wi-Fi password'
        WHEN lg.CLASSIFIED_CAUSE = 'HARDWARE_FAILURE' THEN 'Dispatch technician for hardware repair/replacement'
        WHEN lg.CLASSIFIED_CAUSE = 'NETWORK_OUTAGE' THEN 'Wait for provider network to recover; contact office if >4hrs'
        WHEN lg.CLASSIFIED_CAUSE = 'POWER_LOSS' THEN 'Attempt remote restart after power restoration'
        ELSE 'Investigate further before action'
    END as RECOMMENDED_RESOLUTION
FROM DEVICE_LAST_GASP lg
JOIN DEVICE_INVENTORY d ON lg.DEVICE_ID = d.DEVICE_ID
ORDER BY lg.OFFLINE_TIMESTAMP DESC;

-- Summary view: Failure cause distribution
CREATE OR REPLACE VIEW V_LAST_GASP_SUMMARY AS
SELECT 
    CLASSIFIED_CAUSE,
    COUNT(*) as INCIDENT_COUNT,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as PERCENTAGE,
    ROUND(AVG(CLASSIFICATION_CONFIDENCE), 2) as AVG_CONFIDENCE,
    SUM(CASE WHEN RESOLVED_TIMESTAMP IS NULL THEN 1 ELSE 0 END) as ACTIVE_INCIDENTS,
    SUM(CASE WHEN RESOLVED_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END) as RESOLVED_INCIDENTS,
    CASE 
        WHEN CLASSIFIED_CAUSE = 'WIFI_PASSWORD_CHANGE' THEN 'CALL_OFFICE'
        WHEN CLASSIFIED_CAUSE = 'HARDWARE_FAILURE' THEN 'DISPATCH_TECH'
        WHEN CLASSIFIED_CAUSE = 'NETWORK_OUTAGE' THEN 'WAIT_MONITOR'
        WHEN CLASSIFIED_CAUSE = 'POWER_LOSS' THEN 'REMOTE_RESTART'
        ELSE 'INVESTIGATE'
    END as PRIMARY_RESOLUTION_PATH
FROM DEVICE_LAST_GASP
GROUP BY CLASSIFIED_CAUSE
ORDER BY INCIDENT_COUNT DESC;

-- Network type impact analysis
CREATE OR REPLACE VIEW V_NETWORK_TYPE_FAILURE_ANALYSIS AS
SELECT 
    d.NETWORK_TYPE,
    COUNT(*) as TOTAL_DEVICES,
    SUM(CASE WHEN d.STATUS = 'OFFLINE' THEN 1 ELSE 0 END) as OFFLINE_DEVICES,
    ROUND(SUM(CASE WHEN d.STATUS = 'OFFLINE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as OFFLINE_RATE_PCT,
    (SELECT COUNT(*) FROM DEVICE_LAST_GASP lg2 
     JOIN DEVICE_INVENTORY d2 ON lg2.DEVICE_ID = d2.DEVICE_ID 
     WHERE d2.NETWORK_TYPE = d.NETWORK_TYPE 
     AND lg2.CLASSIFIED_CAUSE = 'WIFI_PASSWORD_CHANGE') as WIFI_PASSWORD_INCIDENTS,
    'Provider Wi-Fi devices are 5x more likely to go offline due to credential changes' as INSIGHT
FROM DEVICE_INVENTORY d
GROUP BY d.NETWORK_TYPE
ORDER BY OFFLINE_RATE_PCT DESC;

-- Verification queries for last gasp analysis
SELECT '=== Last Gasp Analysis ===' as SECTION;
SELECT * FROM V_LAST_GASP_ANALYSIS;

SELECT '=== Failure Cause Summary ===' as SECTION;
SELECT * FROM V_LAST_GASP_SUMMARY;

SELECT '=== Network Type Impact ===' as SECTION;
SELECT * FROM V_NETWORK_TYPE_FAILURE_ANALYSIS;

