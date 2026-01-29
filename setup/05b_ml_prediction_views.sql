/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 5b: ML Prediction Views - RULE-BASED FALLBACK
 * 
 * ⚠️  THIS IS A FALLBACK FOR DEMOS WITHOUT ML MODEL TRAINING
 * 
 * For FULL ML-POWERED predictions:
 *   Run the Jupyter notebook: notebooks/ML_Device_Failure_Prediction.ipynb
 *   - Trains XGBoost models on historical data
 *   - Logs models to Snowflake Model Registry
 *   - Creates views with MODEL!PREDICT() for real inference
 * 
 * This script creates RULE-BASED simulations that:
 *   - Work without running the notebook
 *   - Allow 06_enhanced_capabilities.sql to run
 *   - Demonstrate the CONCEPT of predictions
 *   - Use thresholds derived from failure patterns (NOT trained ML)
 * 
 * EXECUTION ORDER:
 * ================
 * Option A - Quick Demo (Rule-based):
 *   01 → 02 → 03 → 04 → 05 → 05b → 06
 * 
 * Option B - Full ML Demo (Recommended):
 *   01 → 02 → 03 → 04 → 05 → [Notebook] → 06
 *   (Notebook creates real ML views, skip 05b)
 * 
 * The notebook creates the same views (V_DEVICE_ML_FEATURES, V_ML_FAILURE_PREDICTIONS,
 * SV_ML_PREDICTIONS) but with actual XGBoost model inference via MODEL!PREDICT()
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEVICE_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- 1. V_DEVICE_ML_FEATURES: Current feature values for each device
-- This extracts the latest telemetry with rolling statistics for prediction
-- ============================================================================

CREATE OR REPLACE VIEW V_DEVICE_ML_FEATURES AS
WITH latest_telemetry AS (
    SELECT 
        DEVICE_ID,
        TIMESTAMP,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        DISK_USAGE_PCT,
        NETWORK_LATENCY_MS,
        ERROR_COUNT,
        WIFI_SIGNAL_STRENGTH,
        UPTIME_HOURS,
        ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP DESC) as RN
    FROM DEVICE_TELEMETRY
),
hourly_recent AS (
    SELECT 
        DEVICE_ID,
        TIMESTAMP,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        DISK_USAGE_PCT,
        NETWORK_LATENCY_MS,
        ERROR_COUNT,
        WIFI_SIGNAL_STRENGTH,
        UPTIME_HOURS,
        ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP DESC) as RECENCY_RANK
    FROM DEVICE_TELEMETRY
    WHERE TIMESTAMP >= DATEADD('day', -7, (SELECT MAX(TIMESTAMP) FROM DEVICE_TELEMETRY))
),
device_features AS (
    SELECT 
        h.DEVICE_ID,
        d.DEVICE_MODEL,
        d.NETWORK_TYPE,
        d.FACILITY_NAME,
        d.LOCATION_CITY,
        d.LOCATION_STATE,
        d.STATUS,
        d.INSTALL_DATE,
        d.LAST_MAINTENANCE_DATE,
        d.HOURLY_AD_REVENUE_USD,
        
        -- Current values (most recent reading)
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.CPU_TEMP_CELSIUS END) as CURRENT_CPU_TEMP,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.CPU_USAGE_PCT END) as CURRENT_CPU_USAGE,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.MEMORY_USAGE_PCT END) as CURRENT_MEMORY_USAGE,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.DISK_USAGE_PCT END) as CURRENT_DISK_USAGE,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.NETWORK_LATENCY_MS END) as CURRENT_NETWORK_LATENCY,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.ERROR_COUNT END) as CURRENT_ERROR_COUNT,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.WIFI_SIGNAL_STRENGTH END) as CURRENT_WIFI_SIGNAL,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.UPTIME_HOURS END) as CURRENT_UPTIME,
        MAX(CASE WHEN h.RECENCY_RANK = 1 THEN h.TIMESTAMP END) as LAST_READING_TIME,
        
        -- 24-hour averages
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 24 THEN h.CPU_TEMP_CELSIUS END), 2) as AVG_CPU_TEMP_24H,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 24 THEN h.CPU_USAGE_PCT END), 2) as AVG_CPU_USAGE_24H,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 24 THEN h.MEMORY_USAGE_PCT END), 2) as AVG_MEMORY_24H,
        ROUND(SUM(CASE WHEN h.RECENCY_RANK <= 24 THEN h.ERROR_COUNT ELSE 0 END), 0) as ERRORS_24H,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 24 THEN h.WIFI_SIGNAL_STRENGTH END), 2) as AVG_WIFI_SIGNAL_24H,
        
        -- 24-hour maximums (peak values)
        ROUND(MAX(CASE WHEN h.RECENCY_RANK <= 24 THEN h.CPU_TEMP_CELSIUS END), 2) as MAX_CPU_TEMP_24H,
        ROUND(MAX(CASE WHEN h.RECENCY_RANK <= 24 THEN h.CPU_USAGE_PCT END), 2) as MAX_CPU_USAGE_24H,
        ROUND(MAX(CASE WHEN h.RECENCY_RANK <= 24 THEN h.MEMORY_USAGE_PCT END), 2) as MAX_MEMORY_24H,
        ROUND(MIN(CASE WHEN h.RECENCY_RANK <= 24 THEN h.WIFI_SIGNAL_STRENGTH END), 0) as MIN_WIFI_SIGNAL_24H,
        
        -- 7-day statistics
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 168 THEN h.CPU_TEMP_CELSIUS END), 2) as AVG_CPU_TEMP_7D,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 168 THEN h.MEMORY_USAGE_PCT END), 2) as AVG_MEMORY_7D,
        ROUND(SUM(CASE WHEN h.RECENCY_RANK <= 168 THEN h.ERROR_COUNT ELSE 0 END), 0) as ERRORS_7D,
        ROUND(STDDEV(CASE WHEN h.RECENCY_RANK <= 168 THEN h.WIFI_SIGNAL_STRENGTH END), 2) as WIFI_SIGNAL_VOLATILITY,
        
        -- TREND features: Compare last 6 hours vs 18-24 hours ago
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 6 THEN h.CPU_TEMP_CELSIUS END) - 
              AVG(CASE WHEN h.RECENCY_RANK BETWEEN 18 AND 24 THEN h.CPU_TEMP_CELSIUS END), 2) as CPU_TEMP_TREND,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 6 THEN h.CPU_USAGE_PCT END) - 
              AVG(CASE WHEN h.RECENCY_RANK BETWEEN 18 AND 24 THEN h.CPU_USAGE_PCT END), 2) as CPU_USAGE_TREND,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 6 THEN h.MEMORY_USAGE_PCT END) - 
              AVG(CASE WHEN h.RECENCY_RANK BETWEEN 18 AND 24 THEN h.MEMORY_USAGE_PCT END), 2) as MEMORY_TREND,
        ROUND(AVG(CASE WHEN h.RECENCY_RANK <= 6 THEN h.WIFI_SIGNAL_STRENGTH END) - 
              AVG(CASE WHEN h.RECENCY_RANK BETWEEN 18 AND 24 THEN h.WIFI_SIGNAL_STRENGTH END), 2) as WIFI_SIGNAL_TREND
        
    FROM hourly_recent h
    JOIN DEVICE_INVENTORY d ON h.DEVICE_ID = d.DEVICE_ID
    GROUP BY h.DEVICE_ID, d.DEVICE_MODEL, d.NETWORK_TYPE, d.FACILITY_NAME, 
             d.LOCATION_CITY, d.LOCATION_STATE, d.STATUS, d.INSTALL_DATE, 
             d.LAST_MAINTENANCE_DATE, d.HOURLY_AD_REVENUE_USD
)
SELECT 
    DEVICE_ID,
    DEVICE_MODEL,
    -- Encode device type for ML
    CASE DEVICE_MODEL 
        WHEN 'HealthScreen Pro 55' THEN 'HEALTHSCREEN_PRO_55'
        WHEN 'HealthScreen Lite 32' THEN 'HEALTHSCREEN_LITE_32'
        WHEN 'HealthScreen Max 65' THEN 'HEALTHSCREEN_MAX_65'
        ELSE 'UNKNOWN'
    END as DEVICE_TYPE,
    NETWORK_TYPE,
    FACILITY_NAME,
    CONCAT(LOCATION_CITY, ', ', LOCATION_STATE) as LOCATION,
    STATUS,
    HOURLY_AD_REVENUE_USD,
    DATEDIFF('day', INSTALL_DATE, CURRENT_DATE()) as DEVICE_AGE_DAYS,
    DATEDIFF('day', LAST_MAINTENANCE_DATE, CURRENT_DATE()) as DAYS_SINCE_MAINTENANCE,
    LAST_READING_TIME,
    
    -- Current values
    CURRENT_CPU_TEMP,
    CURRENT_CPU_USAGE,
    CURRENT_MEMORY_USAGE,
    CURRENT_DISK_USAGE,
    CURRENT_NETWORK_LATENCY,
    CURRENT_ERROR_COUNT,
    CURRENT_WIFI_SIGNAL,
    CURRENT_UPTIME,
    
    -- Rolling statistics (24h)
    AVG_CPU_TEMP_24H,
    AVG_CPU_USAGE_24H,
    AVG_MEMORY_24H,
    ERRORS_24H,
    AVG_WIFI_SIGNAL_24H,
    MAX_CPU_TEMP_24H,
    MAX_CPU_USAGE_24H,
    MAX_MEMORY_24H,
    MIN_WIFI_SIGNAL_24H,
    
    -- Rolling statistics (7d)
    AVG_CPU_TEMP_7D,
    AVG_MEMORY_7D,
    ERRORS_7D,
    COALESCE(WIFI_SIGNAL_VOLATILITY, 0) as WIFI_SIGNAL_VOLATILITY,
    
    -- Trend features
    COALESCE(CPU_TEMP_TREND, 0) as CPU_TEMP_TREND,
    COALESCE(CPU_USAGE_TREND, 0) as CPU_USAGE_TREND,
    COALESCE(MEMORY_TREND, 0) as MEMORY_TREND,
    COALESCE(WIFI_SIGNAL_TREND, 0) as WIFI_SIGNAL_TREND

FROM device_features;

-- ============================================================================
-- 2. V_ML_FAILURE_PREDICTIONS: Predicted failure probability for each device
-- This simulates what a trained ML model would output
-- Uses rule-based scoring derived from historical failure patterns
-- ============================================================================

CREATE OR REPLACE VIEW V_ML_FAILURE_PREDICTIONS AS
SELECT 
    f.DEVICE_ID,
    f.DEVICE_MODEL,
    f.DEVICE_TYPE,
    f.NETWORK_TYPE,
    f.FACILITY_NAME,
    f.LOCATION,
    f.STATUS,
    f.HOURLY_AD_REVENUE_USD,
    f.DEVICE_AGE_DAYS,
    f.DAYS_SINCE_MAINTENANCE,
    f.LAST_READING_TIME,
    
    -- Current metrics
    f.CURRENT_CPU_TEMP,
    f.CURRENT_CPU_USAGE,
    f.CURRENT_MEMORY_USAGE,
    f.CURRENT_WIFI_SIGNAL,
    f.CURRENT_UPTIME,
    f.ERRORS_24H,
    
    -- Trend metrics
    f.CPU_TEMP_TREND,
    f.CPU_USAGE_TREND,
    f.MEMORY_TREND,
    f.WIFI_SIGNAL_TREND,
    
    -- Feature summary for transparency
    f.AVG_CPU_TEMP_24H,
    f.AVG_WIFI_SIGNAL_24H,
    f.WIFI_SIGNAL_VOLATILITY,
    
    -- ===== ML MODEL SIMULATION =====
    -- Failure probability score (0-100) - simulates RandomForest classifier output
    LEAST(100, GREATEST(0,
        -- Base risk from current values
        CASE WHEN f.CURRENT_CPU_TEMP > 70 THEN 30 WHEN f.CURRENT_CPU_TEMP > 60 THEN 12 ELSE 0 END +
        CASE WHEN f.CURRENT_CPU_USAGE > 90 THEN 22 WHEN f.CURRENT_CPU_USAGE > 75 THEN 8 ELSE 0 END +
        CASE WHEN f.CURRENT_MEMORY_USAGE > 90 THEN 22 WHEN f.CURRENT_MEMORY_USAGE > 80 THEN 8 ELSE 0 END +
        CASE WHEN f.ERRORS_24H > 15 THEN 20 WHEN f.ERRORS_24H > 8 THEN 10 ELSE 0 END +
        
        -- Trend-based risk (rising metrics = impending failure)
        CASE WHEN f.CPU_TEMP_TREND > 12 THEN 18 WHEN f.CPU_TEMP_TREND > 6 THEN 9 ELSE 0 END +
        CASE WHEN f.CPU_USAGE_TREND > 18 THEN 14 WHEN f.CPU_USAGE_TREND > 10 THEN 7 ELSE 0 END +
        CASE WHEN f.MEMORY_TREND > 12 THEN 14 WHEN f.MEMORY_TREND > 6 THEN 7 ELSE 0 END +
        
        -- Wi-Fi signal issues (critical for provider networks)
        CASE WHEN f.NETWORK_TYPE = 'PROVIDER_WIFI' AND f.CURRENT_WIFI_SIGNAL < -75 THEN 15
             WHEN f.CURRENT_WIFI_SIGNAL < -80 THEN 10 ELSE 0 END +
        CASE WHEN f.WIFI_SIGNAL_TREND < -10 THEN 12 WHEN f.WIFI_SIGNAL_TREND < -5 THEN 6 ELSE 0 END +
        CASE WHEN f.WIFI_SIGNAL_VOLATILITY > 12 THEN 8 ELSE 0 END +
        
        -- Long uptime increases risk
        CASE WHEN f.CURRENT_UPTIME > 720 THEN 12 WHEN f.CURRENT_UPTIME > 360 THEN 5 ELSE 0 END +
        
        -- Current status multiplier
        CASE WHEN f.STATUS = 'OFFLINE' THEN 50 WHEN f.STATUS = 'DEGRADED' THEN 22 ELSE 0 END +
        
        -- Maintenance overdue
        CASE WHEN f.DAYS_SINCE_MAINTENANCE > 90 THEN 8 WHEN f.DAYS_SINCE_MAINTENANCE > 60 THEN 4 ELSE 0 END
    )) as FAILURE_PROBABILITY_PCT,
    
    -- Binary prediction: Will device fail within 48 hours?
    CASE 
        WHEN f.STATUS = 'OFFLINE' THEN 1
        WHEN f.STATUS = 'DEGRADED' AND (f.CURRENT_CPU_TEMP > 65 OR f.CPU_TEMP_TREND > 8 OR f.ERRORS_24H > 10) THEN 1
        WHEN f.CURRENT_CPU_TEMP > 70 OR f.CPU_TEMP_TREND > 12 THEN 1
        WHEN f.CURRENT_CPU_USAGE > 90 AND f.CPU_USAGE_TREND > 10 THEN 1
        WHEN f.CURRENT_MEMORY_USAGE > 90 AND f.MEMORY_TREND > 8 THEN 1
        WHEN f.ERRORS_24H > 15 THEN 1
        WHEN f.NETWORK_TYPE = 'PROVIDER_WIFI' AND f.CURRENT_WIFI_SIGNAL < -78 AND f.WIFI_SIGNAL_TREND < -8 THEN 1
        ELSE 0
    END as WILL_FAIL_48H,
    
    -- Predicted hours to failure (regression output)
    CASE 
        WHEN f.STATUS = 'OFFLINE' THEN 0
        WHEN f.CURRENT_CPU_TEMP > 75 OR f.CPU_TEMP_TREND > 15 THEN 6
        WHEN f.CURRENT_CPU_TEMP > 65 OR f.CPU_TEMP_TREND > 10 THEN 18
        WHEN f.CURRENT_CPU_USAGE > 95 OR f.CURRENT_MEMORY_USAGE > 95 THEN 8
        WHEN f.CURRENT_CPU_USAGE > 85 OR f.CURRENT_MEMORY_USAGE > 85 THEN 28
        WHEN f.ERRORS_24H > 15 THEN 12
        WHEN f.ERRORS_24H > 8 THEN 36
        WHEN f.STATUS = 'DEGRADED' THEN 42
        WHEN f.CURRENT_WIFI_SIGNAL < -75 AND f.NETWORK_TYPE = 'PROVIDER_WIFI' THEN 24
        ELSE NULL  -- No imminent failure predicted
    END as PREDICTED_HOURS_TO_FAILURE,
    
    -- Risk level classification
    CASE 
        WHEN f.STATUS = 'OFFLINE' THEN 'CRITICAL'
        WHEN f.STATUS = 'DEGRADED' AND (f.CURRENT_CPU_TEMP > 65 OR f.ERRORS_24H > 10) THEN 'CRITICAL'
        WHEN f.CURRENT_CPU_TEMP > 70 OR f.CPU_TEMP_TREND > 12 THEN 'CRITICAL'
        WHEN f.CURRENT_CPU_USAGE > 90 OR f.CURRENT_MEMORY_USAGE > 90 THEN 'WARNING'
        WHEN f.STATUS = 'DEGRADED' THEN 'WARNING'
        WHEN f.CPU_TEMP_TREND > 6 OR f.CPU_USAGE_TREND > 10 OR f.MEMORY_TREND > 8 THEN 'WARNING'
        WHEN f.ERRORS_24H > 8 THEN 'WARNING'
        WHEN f.CURRENT_WIFI_SIGNAL < -75 THEN 'WARNING'
        ELSE 'HEALTHY'
    END as RISK_LEVEL,
    
    -- Primary risk factor
    CASE 
        WHEN f.STATUS = 'OFFLINE' THEN 'DEVICE_OFFLINE'
        WHEN f.CPU_TEMP_TREND > 10 AND f.CURRENT_CPU_TEMP > 60 THEN 'RISING_TEMPERATURE'
        WHEN f.CURRENT_CPU_TEMP > 70 THEN 'OVERHEATING'
        WHEN f.CPU_USAGE_TREND > 12 THEN 'CPU_USAGE_CLIMBING'
        WHEN f.CURRENT_CPU_USAGE > 90 THEN 'HIGH_CPU_SUSTAINED'
        WHEN f.MEMORY_TREND > 8 THEN 'MEMORY_LEAK_DETECTED'
        WHEN f.CURRENT_MEMORY_USAGE > 90 THEN 'MEMORY_EXHAUSTION'
        WHEN f.WIFI_SIGNAL_TREND < -8 AND f.NETWORK_TYPE = 'PROVIDER_WIFI' THEN 'WIFI_SIGNAL_DEGRADING'
        WHEN f.CURRENT_WIFI_SIGNAL < -75 THEN 'POOR_WIFI_SIGNAL'
        WHEN f.ERRORS_24H > 10 THEN 'ERROR_RATE_HIGH'
        WHEN f.CURRENT_UPTIME > 720 THEN 'EXTENDED_UPTIME'
        WHEN f.STATUS = 'DEGRADED' THEN 'DEGRADED_PERFORMANCE'
        ELSE 'NORMAL_OPERATION'
    END as PRIMARY_RISK_FACTOR,
    
    -- Recommended action
    CASE 
        WHEN f.STATUS = 'OFFLINE' THEN 'INVESTIGATE: Device offline - check last gasp data for cause classification'
        WHEN f.CURRENT_CPU_TEMP > 70 OR f.CPU_TEMP_TREND > 12 THEN 'IMMEDIATE: Execute remote restart, schedule maintenance if persists'
        WHEN f.CURRENT_CPU_USAGE > 90 OR f.MEMORY_TREND > 8 THEN 'URGENT: Clear cache, restart services'
        WHEN f.WIFI_SIGNAL_TREND < -8 THEN 'MONITOR: Wi-Fi degrading, may need to call provider office'
        WHEN f.CURRENT_WIFI_SIGNAL < -75 THEN 'CALL OFFICE: Check if Wi-Fi password changed'
        WHEN f.STATUS = 'DEGRADED' THEN 'SOON: Schedule preventive maintenance within 48 hours'
        WHEN f.ERRORS_24H > 8 THEN 'REVIEW: Check error logs, consider restart'
        ELSE 'NONE: Device operating normally'
    END as RECOMMENDED_ACTION

FROM V_DEVICE_ML_FEATURES f;

-- ============================================================================
-- 3. SV_ML_PREDICTIONS: Semantic View for Agent Integration
-- This enables natural language queries about predictions
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ML_PREDICTIONS
  COMMENT = 'ML-powered device failure predictions. Shows which devices will fail in the next 48 hours, risk levels, and recommended actions. Use for predictive maintenance questions.'
  TABLES (
    predictions AS V_ML_FAILURE_PREDICTIONS PRIMARY KEY (DEVICE_ID)
  )
  RELATIONSHIPS ()
  DIMENSIONS (
    predictions.DEVICE_ID AS predictions.device_id
      LABEL 'Device ID'
      WITH SYNONYMS = ('device', 'unit', 'screen'),
    predictions.DEVICE_MODEL AS predictions.device_model
      LABEL 'Device Model',
    predictions.DEVICE_TYPE AS predictions.device_type
      LABEL 'Device Type',
    predictions.FACILITY_NAME AS predictions.facility_name
      LABEL 'Facility'
      WITH SYNONYMS = ('location', 'site', 'office'),
    predictions.LOCATION AS predictions.location
      LABEL 'City State',
    predictions.STATUS AS predictions.status
      LABEL 'Current Status',
    predictions.RISK_LEVEL AS predictions.risk_level
      LABEL 'Risk Level'
      WITH SYNONYMS = ('risk', 'priority', 'urgency')
      DESCRIPTION 'Risk classification: CRITICAL, WARNING, or HEALTHY',
    predictions.PRIMARY_RISK_FACTOR AS predictions.primary_risk_factor
      LABEL 'Risk Factor'
      DESCRIPTION 'Main reason for the risk level',
    predictions.RECOMMENDED_ACTION AS predictions.recommended_action
      LABEL 'Recommended Action'
  )
  METRICS (
    predictions.total_devices AS COUNT(DISTINCT predictions.DEVICE_ID)
      LABEL 'Total Devices',
    predictions.devices_at_risk AS COUNT(CASE WHEN predictions.RISK_LEVEL IN ('CRITICAL', 'WARNING') THEN 1 END)
      LABEL 'Devices at Risk'
      WITH SYNONYMS = ('at risk', 'risky devices', 'high risk count')
      DESCRIPTION 'Count of devices with CRITICAL or WARNING risk level',
    predictions.predicted_failures_48h AS SUM(predictions.WILL_FAIL_48H)
      LABEL 'Predicted Failures (48h)'
      WITH SYNONYMS = ('will fail', 'predicted to fail', 'failures next 48 hours')
      DESCRIPTION 'Number of devices predicted to fail within 48 hours',
    predictions.critical_devices AS COUNT(CASE WHEN predictions.RISK_LEVEL = 'CRITICAL' THEN 1 END)
      LABEL 'Critical Devices'
      DESCRIPTION 'Devices requiring immediate attention',
    predictions.warning_devices AS COUNT(CASE WHEN predictions.RISK_LEVEL = 'WARNING' THEN 1 END)
      LABEL 'Warning Devices',
    predictions.avg_failure_probability AS ROUND(AVG(predictions.FAILURE_PROBABILITY_PCT), 1)
      LABEL 'Average Failure Probability'
      DESCRIPTION 'Average failure probability across devices (0-100%)',
    predictions.avg_hours_to_failure AS ROUND(AVG(predictions.PREDICTED_HOURS_TO_FAILURE), 1)
      LABEL 'Average Hours to Failure'
  );

-- Grant permissions
GRANT SELECT ON V_DEVICE_ML_FEATURES TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON V_ML_FAILURE_PREDICTIONS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_ML_PREDICTIONS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Show ML feature summary
SELECT 'Device ML Features' as VIEW_NAME, COUNT(*) as DEVICE_COUNT FROM V_DEVICE_ML_FEATURES;

-- Show prediction summary
SELECT 
    'ML Predictions Summary' as SUMMARY,
    COUNT(*) as TOTAL_DEVICES,
    SUM(WILL_FAIL_48H) as PREDICTED_FAILURES_48H,
    SUM(CASE WHEN RISK_LEVEL = 'CRITICAL' THEN 1 ELSE 0 END) as CRITICAL_COUNT,
    SUM(CASE WHEN RISK_LEVEL = 'WARNING' THEN 1 ELSE 0 END) as WARNING_COUNT,
    SUM(CASE WHEN RISK_LEVEL = 'HEALTHY' THEN 1 ELSE 0 END) as HEALTHY_COUNT,
    ROUND(AVG(FAILURE_PROBABILITY_PCT), 1) as AVG_FAILURE_PROBABILITY
FROM V_ML_FAILURE_PREDICTIONS;

-- Show top 10 at-risk devices
SELECT 
    DEVICE_ID,
    FACILITY_NAME,
    LOCATION,
    STATUS,
    RISK_LEVEL,
    FAILURE_PROBABILITY_PCT || '%' as FAILURE_RISK,
    PREDICTED_HOURS_TO_FAILURE,
    PRIMARY_RISK_FACTOR,
    RECOMMENDED_ACTION
FROM V_ML_FAILURE_PREDICTIONS
WHERE RISK_LEVEL IN ('CRITICAL', 'WARNING')
ORDER BY FAILURE_PROBABILITY_PCT DESC
LIMIT 10;

-- Verify semantic view
SELECT * FROM SEMANTIC_VIEW(
    SV_ML_PREDICTIONS
    DIMENSIONS risk_level
    METRICS total_devices, predicted_failures_48h
);
