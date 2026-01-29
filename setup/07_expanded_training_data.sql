/*******************************************************************************
 * EXPANDED TRAINING DATA FOR ML MODELS
 * 
 * This script creates realistic historical failure data with telemetry patterns
 * that precede failures - enabling proper ML training.
 * 
 * Key improvements:
 * 1. 200+ maintenance tickets spanning 6 months
 * 2. Telemetry patterns that degrade BEFORE failure events
 * 3. Proper correlation between telemetry anomalies and failure types
 ******************************************************************************/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE PATIENTPOINT_MAINTENANCE;
USE SCHEMA DEVICE_OPS;
USE WAREHOUSE COMPUTE_WH;

-- ============================================================================
-- STEP 1: Create expanded maintenance history (200+ tickets over 6 months)
-- ============================================================================

-- First, let's expand to 6 months of telemetry (instead of 30 days)
-- This gives us more data points for pattern recognition
TRUNCATE TABLE DEVICE_TELEMETRY;

-- Generate 6 months of hourly telemetry (4320 hours = 180 days)
INSERT INTO DEVICE_TELEMETRY (DEVICE_ID, TIMESTAMP, CPU_TEMP_CELSIUS, CPU_USAGE_PCT, MEMORY_USAGE_PCT, 
                               DISK_USAGE_PCT, NETWORK_LATENCY_MS, DISPLAY_BRIGHTNESS_PCT, 
                               UPTIME_HOURS, ERROR_COUNT, LAST_HEARTBEAT, WIFI_SIGNAL_STRENGTH, CONNECTION_TYPE)
SELECT 
    d.DEVICE_ID,
    DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP()) as TIMESTAMP,
    -- Base healthy metrics with some noise
    42 + (RANDOM() / POW(10, 18)) * 8 as CPU_TEMP_CELSIUS,
    15 + (RANDOM() / POW(10, 18)) * 15 as CPU_USAGE_PCT,
    30 + (RANDOM() / POW(10, 18)) * 20 as MEMORY_USAGE_PCT,
    35 + (RANDOM() / POW(10, 18)) * 15 as DISK_USAGE_PCT,
    10 + (RANDOM() / POW(10, 18)) * 15 as NETWORK_LATENCY_MS,
    85 + (RANDOM() / POW(10, 18)) * 15 as DISPLAY_BRIGHTNESS_PCT,
    24 + MOD(t.SEQ, 168) as UPTIME_HOURS,
    FLOOR((RANDOM() / POW(10, 18)) * 2) as ERROR_COUNT,
    DATEADD('minute', -1 * FLOOR((RANDOM() / POW(10, 18)) * 5), DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP())) as LAST_HEARTBEAT,
    -45 + FLOOR((RANDOM() / POW(10, 18)) * 12) as WIFI_SIGNAL_STRENGTH,
    'WIFI' as CONNECTION_TYPE
FROM DEVICE_INVENTORY d
CROSS JOIN (SELECT SEQ4() as SEQ FROM TABLE(GENERATOR(ROWCOUNT => 4320))) t
WHERE t.SEQ < 4320;

-- ============================================================================
-- STEP 2: Create expanded maintenance history with varied failure types
-- ============================================================================

-- Clear existing and add comprehensive history
TRUNCATE TABLE MAINTENANCE_HISTORY;

-- Generate 200+ maintenance tickets over 6 months with realistic distribution
-- Issue type distribution: 30% HIGH_CPU, 25% MEMORY_LEAK, 20% CONNECTIVITY, 15% OVERHEATING, 10% HARDWARE
INSERT INTO MAINTENANCE_HISTORY (TICKET_ID, DEVICE_ID, CREATED_AT, RESOLVED_AT, ISSUE_TYPE, 
                                  ISSUE_DESCRIPTION, RESOLUTION_TYPE, RESOLUTION_NOTES, TECHNICIAN_ID, COST_USD)
WITH ticket_generator AS (
    SELECT 
        SEQ4() as TICKET_NUM,
        'DEV-' || LPAD(MOD(SEQ4(), 100) + 1, 3, '0') as DEVICE_ID,
        -- Spread tickets over 180 days
        DATEADD('hour', -1 * (SEQ4() * 20 + FLOOR((RANDOM() / POW(10, 18)) * 100)), CURRENT_TIMESTAMP()) as BASE_TIME,
        -- Issue type distribution
        CASE 
            WHEN MOD(SEQ4(), 10) < 3 THEN 'HIGH_CPU'
            WHEN MOD(SEQ4(), 10) < 5 THEN 'MEMORY_LEAK'
            WHEN MOD(SEQ4(), 10) < 7 THEN 'CONNECTIVITY'
            WHEN MOD(SEQ4(), 10) < 8 THEN 'OVERHEATING'
            WHEN MOD(SEQ4(), 10) < 9 THEN 'DISPLAY_FREEZE'
            ELSE 'HARDWARE_FAILURE'
        END as ISSUE_TYPE,
        -- Resolution type based on issue
        CASE 
            WHEN MOD(SEQ4(), 10) < 7 THEN 'REMOTE_FIX'
            ELSE 'FIELD_DISPATCH'
        END as RESOLUTION_TYPE
    FROM TABLE(GENERATOR(ROWCOUNT => 250))
)
SELECT 
    'TKT-' || LPAD(TICKET_NUM::VARCHAR, 4, '0') as TICKET_ID,
    DEVICE_ID,
    BASE_TIME as CREATED_AT,
    DATEADD('minute', 
        CASE RESOLUTION_TYPE 
            WHEN 'REMOTE_FIX' THEN 15 + FLOOR((RANDOM() / POW(10, 18)) * 30)
            ELSE 180 + FLOOR((RANDOM() / POW(10, 18)) * 240)
        END, 
        BASE_TIME) as RESOLVED_AT,
    ISSUE_TYPE,
    CASE ISSUE_TYPE
        WHEN 'HIGH_CPU' THEN 'CPU usage consistently above 85%, sluggish performance'
        WHEN 'MEMORY_LEAK' THEN 'Memory usage climbing steadily, approaching exhaustion'
        WHEN 'CONNECTIVITY' THEN 'Intermittent network disconnections, high latency'
        WHEN 'OVERHEATING' THEN 'CPU temperature above 70C, thermal throttling detected'
        WHEN 'DISPLAY_FREEZE' THEN 'Screen frozen, unresponsive to touch input'
        ELSE 'Hardware component failure detected'
    END as ISSUE_DESCRIPTION,
    RESOLUTION_TYPE,
    CASE ISSUE_TYPE
        WHEN 'HIGH_CPU' THEN 'Killed runaway process, cleared temp files'
        WHEN 'MEMORY_LEAK' THEN 'Restarted services, cleared application cache'
        WHEN 'CONNECTIVITY' THEN 'Reset network adapter, updated WiFi driver'
        WHEN 'OVERHEATING' THEN 'Cleaned dust filters, replaced thermal paste'
        WHEN 'DISPLAY_FREEZE' THEN 'Remote restart resolved frozen display'
        ELSE 'Replaced failed component on-site'
    END as RESOLUTION_NOTES,
    CASE RESOLUTION_TYPE 
        WHEN 'REMOTE_FIX' THEN 'REMOTE_AGENT'
        ELSE 'TECH-' || LPAD(MOD(TICKET_NUM, 6) + 1, 3, '0')
    END as TECHNICIAN_ID,
    CASE RESOLUTION_TYPE 
        WHEN 'REMOTE_FIX' THEN 0
        ELSE 150 + FLOOR((RANDOM() / POW(10, 18)) * 150)
    END as COST_USD
FROM ticket_generator
WHERE BASE_TIME > DATEADD('day', -180, CURRENT_TIMESTAMP());

-- ============================================================================
-- STEP 3: Inject telemetry anomalies BEFORE failure events
-- This is the key to creating proper training data!
-- ============================================================================

-- For each maintenance ticket, update telemetry in the 24-72 hours BEFORE the failure
-- to show degradation patterns

-- HIGH_CPU failures: CPU usage and temp ramp up before failure
UPDATE DEVICE_TELEMETRY t
SET 
    CPU_USAGE_PCT = LEAST(99, t.CPU_USAGE_PCT + 40 + (RANDOM() / POW(10, 18)) * 20),
    CPU_TEMP_CELSIUS = t.CPU_TEMP_CELSIUS + 15 + (RANDOM() / POW(10, 18)) * 10,
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 8) + 3
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'HIGH_CPU'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -48, m.CREATED_AT) AND m.CREATED_AT;

-- MEMORY_LEAK failures: Memory steadily increases before failure
UPDATE DEVICE_TELEMETRY t
SET 
    MEMORY_USAGE_PCT = LEAST(98, t.MEMORY_USAGE_PCT + 35 + (RANDOM() / POW(10, 18)) * 15),
    CPU_USAGE_PCT = LEAST(90, t.CPU_USAGE_PCT + 10 + (RANDOM() / POW(10, 18)) * 10),
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 5) + 2
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'MEMORY_LEAK'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -72, m.CREATED_AT) AND m.CREATED_AT;

-- CONNECTIVITY failures: WiFi signal degrades, latency spikes
UPDATE DEVICE_TELEMETRY t
SET 
    WIFI_SIGNAL_STRENGTH = t.WIFI_SIGNAL_STRENGTH - 25 - FLOOR((RANDOM() / POW(10, 18)) * 15),
    NETWORK_LATENCY_MS = t.NETWORK_LATENCY_MS + 80 + (RANDOM() / POW(10, 18)) * 100,
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 6) + 2
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'CONNECTIVITY'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -36, m.CREATED_AT) AND m.CREATED_AT;

-- OVERHEATING failures: Temperature climbs steadily
UPDATE DEVICE_TELEMETRY t
SET 
    CPU_TEMP_CELSIUS = t.CPU_TEMP_CELSIUS + 25 + (RANDOM() / POW(10, 18)) * 15,
    CPU_USAGE_PCT = LEAST(95, t.CPU_USAGE_PCT + 20 + (RANDOM() / POW(10, 18)) * 15),
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 10) + 5
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'OVERHEATING'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -48, m.CREATED_AT) AND m.CREATED_AT;

-- DISPLAY_FREEZE failures: Error count spikes
UPDATE DEVICE_TELEMETRY t
SET 
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 15) + 8,
    CPU_USAGE_PCT = LEAST(90, t.CPU_USAGE_PCT + 15 + (RANDOM() / POW(10, 18)) * 10)
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'DISPLAY_FREEZE'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -24, m.CREATED_AT) AND m.CREATED_AT;

-- HARDWARE_FAILURE: Multiple metrics degrade together
UPDATE DEVICE_TELEMETRY t
SET 
    CPU_TEMP_CELSIUS = t.CPU_TEMP_CELSIUS + 20 + (RANDOM() / POW(10, 18)) * 10,
    CPU_USAGE_PCT = LEAST(95, t.CPU_USAGE_PCT + 25 + (RANDOM() / POW(10, 18)) * 15),
    MEMORY_USAGE_PCT = LEAST(95, t.MEMORY_USAGE_PCT + 20 + (RANDOM() / POW(10, 18)) * 10),
    ERROR_COUNT = t.ERROR_COUNT + FLOOR((RANDOM() / POW(10, 18)) * 20) + 10,
    NETWORK_LATENCY_MS = t.NETWORK_LATENCY_MS + 50 + (RANDOM() / POW(10, 18)) * 50
FROM MAINTENANCE_HISTORY m
WHERE t.DEVICE_ID = m.DEVICE_ID
  AND m.ISSUE_TYPE = 'HARDWARE_FAILURE'
  AND t.TIMESTAMP BETWEEN DATEADD('hour', -72, m.CREATED_AT) AND m.CREATED_AT;

-- ============================================================================
-- STEP 4: Create ML Training Data View with proper labels
-- Labels are based on whether device had a failure within next 48 hours
-- ============================================================================

CREATE OR REPLACE VIEW V_ML_TRAINING_DATA AS
WITH telemetry_with_future_failures AS (
    SELECT 
        t.DEVICE_ID,
        t.TIMESTAMP,
        t.CPU_TEMP_CELSIUS,
        t.CPU_USAGE_PCT,
        t.MEMORY_USAGE_PCT,
        t.DISK_USAGE_PCT,
        t.NETWORK_LATENCY_MS,
        t.ERROR_COUNT,
        t.WIFI_SIGNAL_STRENGTH,
        t.UPTIME_HOURS,
        d.DEVICE_MODEL,
        d.NETWORK_TYPE,
        d.INSTALL_DATE,
        d.LAST_MAINTENANCE_DATE,
        -- Check if there's a failure within next 48 hours
        (SELECT MIN(m.CREATED_AT) 
         FROM MAINTENANCE_HISTORY m 
         WHERE m.DEVICE_ID = t.DEVICE_ID 
           AND m.CREATED_AT > t.TIMESTAMP
           AND m.CREATED_AT <= DATEADD('hour', 48, t.TIMESTAMP)
        ) as NEXT_FAILURE_TIME,
        -- Get the failure type if there is one
        (SELECT m.ISSUE_TYPE 
         FROM MAINTENANCE_HISTORY m 
         WHERE m.DEVICE_ID = t.DEVICE_ID 
           AND m.CREATED_AT > t.TIMESTAMP
           AND m.CREATED_AT <= DATEADD('hour', 48, t.TIMESTAMP)
         ORDER BY m.CREATED_AT ASC
         LIMIT 1
        ) as FAILURE_TYPE
    FROM DEVICE_TELEMETRY t
    JOIN DEVICE_INVENTORY d ON t.DEVICE_ID = d.DEVICE_ID
)
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
    -- Device attributes
    CASE DEVICE_MODEL 
        WHEN 'HealthScreen Pro 55' THEN 0 
        WHEN 'HealthScreen Lite 32' THEN 1 
        ELSE 2 
    END as DEVICE_TYPE_ENCODED,
    CASE NETWORK_TYPE 
        WHEN 'PROVIDER_WIFI' THEN 0 
        WHEN 'PATIENTPOINT_MANAGED' THEN 1 
        ELSE 2 
    END as NETWORK_TYPE_ENCODED,
    DATEDIFF('day', INSTALL_DATE, TIMESTAMP) as DEVICE_AGE_DAYS,
    DATEDIFF('day', LAST_MAINTENANCE_DATE, TIMESTAMP) as DAYS_SINCE_MAINTENANCE,
    -- LABEL: Will device fail within 48 hours?
    CASE WHEN NEXT_FAILURE_TIME IS NOT NULL THEN 1 ELSE 0 END as WILL_FAIL_48H,
    -- Hours until failure (for regression, NULL if no failure)
    CASE WHEN NEXT_FAILURE_TIME IS NOT NULL 
         THEN DATEDIFF('hour', TIMESTAMP, NEXT_FAILURE_TIME) 
         ELSE NULL 
    END as HOURS_TO_FAILURE,
    FAILURE_TYPE
FROM telemetry_with_future_failures;

-- ============================================================================
-- STEP 5: Create Feature Engineering View with trends
-- ============================================================================

CREATE OR REPLACE VIEW V_ML_FEATURES_ENHANCED AS
WITH hourly_data AS (
    SELECT 
        DEVICE_ID,
        TIMESTAMP,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        ERROR_COUNT,
        WIFI_SIGNAL_STRENGTH,
        NETWORK_LATENCY_MS,
        UPTIME_HOURS,
        DISK_USAGE_PCT
    FROM DEVICE_TELEMETRY
),
rolling_stats AS (
    SELECT 
        h.DEVICE_ID,
        h.TIMESTAMP,
        d.DEVICE_MODEL,
        d.NETWORK_TYPE,
        d.INSTALL_DATE,
        d.LAST_MAINTENANCE_DATE,
        
        -- Current metrics
        h.CPU_TEMP_CELSIUS,
        h.CPU_USAGE_PCT,
        h.MEMORY_USAGE_PCT,
        h.ERROR_COUNT,
        h.WIFI_SIGNAL_STRENGTH,
        h.NETWORK_LATENCY_MS,
        h.UPTIME_HOURS,
        h.DISK_USAGE_PCT,
        
        -- 24-hour rolling averages
        AVG(h.CPU_TEMP_CELSIUS) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as AVG_CPU_TEMP_24H,
        AVG(h.CPU_USAGE_PCT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as AVG_CPU_USAGE_24H,
        AVG(h.MEMORY_USAGE_PCT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as AVG_MEMORY_24H,
        SUM(h.ERROR_COUNT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as ERRORS_24H,
        AVG(h.WIFI_SIGNAL_STRENGTH) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as AVG_WIFI_SIGNAL_24H,
        
        -- 24-hour max values
        MAX(h.CPU_TEMP_CELSIUS) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as MAX_CPU_TEMP_24H,
        MAX(h.CPU_USAGE_PCT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as MAX_CPU_USAGE_24H,
        MAX(h.MEMORY_USAGE_PCT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as MAX_MEMORY_24H,
        MIN(h.WIFI_SIGNAL_STRENGTH) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW) as MIN_WIFI_SIGNAL_24H,
        
        -- 7-day rolling averages (168 hours)
        AVG(h.CPU_TEMP_CELSIUS) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 168 PRECEDING AND CURRENT ROW) as AVG_CPU_TEMP_7D,
        AVG(h.MEMORY_USAGE_PCT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 168 PRECEDING AND CURRENT ROW) as AVG_MEMORY_7D,
        SUM(h.ERROR_COUNT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 168 PRECEDING AND CURRENT ROW) as ERRORS_7D,
        STDDEV(h.WIFI_SIGNAL_STRENGTH) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 168 PRECEDING AND CURRENT ROW) as WIFI_SIGNAL_VOLATILITY,
        
        -- TREND FEATURES (change from 24h ago to now)
        h.CPU_TEMP_CELSIUS - LAG(h.CPU_TEMP_CELSIUS, 24) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP) as CPU_TEMP_TREND_24H,
        h.CPU_USAGE_PCT - LAG(h.CPU_USAGE_PCT, 24) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP) as CPU_USAGE_TREND_24H,
        h.MEMORY_USAGE_PCT - LAG(h.MEMORY_USAGE_PCT, 24) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP) as MEMORY_TREND_24H,
        h.WIFI_SIGNAL_STRENGTH - LAG(h.WIFI_SIGNAL_STRENGTH, 24) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP) as WIFI_SIGNAL_TREND_24H,
        
        -- ERROR ACCELERATION (change in error rate)
        (SUM(h.ERROR_COUNT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)) -
        (SUM(h.ERROR_COUNT) OVER (PARTITION BY h.DEVICE_ID ORDER BY h.TIMESTAMP ROWS BETWEEN 48 PRECEDING AND 24 PRECEDING)) as ERROR_ACCELERATION
        
    FROM hourly_data h
    JOIN DEVICE_INVENTORY d ON h.DEVICE_ID = d.DEVICE_ID
)
SELECT 
    DEVICE_ID,
    TIMESTAMP,
    
    -- Current state features
    CPU_TEMP_CELSIUS,
    CPU_USAGE_PCT,
    MEMORY_USAGE_PCT,
    ERROR_COUNT,
    WIFI_SIGNAL_STRENGTH,
    NETWORK_LATENCY_MS,
    UPTIME_HOURS,
    DISK_USAGE_PCT,
    
    -- Rolling statistics (24h)
    ROUND(AVG_CPU_TEMP_24H, 2) as AVG_CPU_TEMP_24H,
    ROUND(AVG_CPU_USAGE_24H, 2) as AVG_CPU_USAGE_24H,
    ROUND(AVG_MEMORY_24H, 2) as AVG_MEMORY_24H,
    ERRORS_24H,
    ROUND(AVG_WIFI_SIGNAL_24H, 2) as AVG_WIFI_SIGNAL_24H,
    ROUND(MAX_CPU_TEMP_24H, 2) as MAX_CPU_TEMP_24H,
    ROUND(MAX_CPU_USAGE_24H, 2) as MAX_CPU_USAGE_24H,
    ROUND(MAX_MEMORY_24H, 2) as MAX_MEMORY_24H,
    MIN_WIFI_SIGNAL_24H,
    
    -- Rolling statistics (7d)
    ROUND(AVG_CPU_TEMP_7D, 2) as AVG_CPU_TEMP_7D,
    ROUND(AVG_MEMORY_7D, 2) as AVG_MEMORY_7D,
    ERRORS_7D,
    ROUND(COALESCE(WIFI_SIGNAL_VOLATILITY, 0), 2) as WIFI_SIGNAL_VOLATILITY,
    
    -- TREND features (KEY for prediction)
    ROUND(COALESCE(CPU_TEMP_TREND_24H, 0), 2) as CPU_TEMP_TREND_24H,
    ROUND(COALESCE(CPU_USAGE_TREND_24H, 0), 2) as CPU_USAGE_TREND_24H,
    ROUND(COALESCE(MEMORY_TREND_24H, 0), 2) as MEMORY_TREND_24H,
    ROUND(COALESCE(WIFI_SIGNAL_TREND_24H, 0), 2) as WIFI_SIGNAL_TREND_24H,
    COALESCE(ERROR_ACCELERATION, 0) as ERROR_ACCELERATION,
    
    -- Device attributes
    CASE DEVICE_MODEL 
        WHEN 'HealthScreen Pro 55' THEN 0 
        WHEN 'HealthScreen Lite 32' THEN 1 
        ELSE 2 
    END as DEVICE_TYPE_ENCODED,
    CASE NETWORK_TYPE 
        WHEN 'PROVIDER_WIFI' THEN 0 
        WHEN 'PATIENTPOINT_MANAGED' THEN 1 
        ELSE 2 
    END as NETWORK_TYPE_ENCODED,
    DATEDIFF('day', INSTALL_DATE, TIMESTAMP) as DEVICE_AGE_DAYS,
    DATEDIFF('day', LAST_MAINTENANCE_DATE, TIMESTAMP) as DAYS_SINCE_MAINTENANCE
    
FROM rolling_stats
WHERE TIMESTAMP >= DATEADD('day', -7, (SELECT MIN(TIMESTAMP) FROM DEVICE_TELEMETRY)) + INTERVAL '7 days';

-- ============================================================================
-- STEP 6: Create final training dataset view
-- ============================================================================

CREATE OR REPLACE VIEW V_ML_TRAINING_DATASET AS
SELECT 
    f.*,
    -- Join with labels
    CASE WHEN m.DEVICE_ID IS NOT NULL THEN 1 ELSE 0 END as WILL_FAIL_48H,
    DATEDIFF('hour', f.TIMESTAMP, m.CREATED_AT) as HOURS_TO_FAILURE,
    m.ISSUE_TYPE as FAILURE_TYPE
FROM V_ML_FEATURES_ENHANCED f
LEFT JOIN (
    SELECT DEVICE_ID, CREATED_AT, ISSUE_TYPE,
           LAG(CREATED_AT, 1, DATEADD('day', -365, CREATED_AT)) OVER (PARTITION BY DEVICE_ID ORDER BY CREATED_AT) as PREV_FAILURE
    FROM MAINTENANCE_HISTORY
) m ON f.DEVICE_ID = m.DEVICE_ID 
    AND f.TIMESTAMP >= DATEADD('hour', -48, m.CREATED_AT)
    AND f.TIMESTAMP < m.CREATED_AT
    AND f.TIMESTAMP >= m.PREV_FAILURE;

-- ============================================================================
-- Verify the data
-- ============================================================================

SELECT 'DEVICE_TELEMETRY' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM DEVICE_TELEMETRY
UNION ALL
SELECT 'MAINTENANCE_HISTORY', COUNT(*) FROM MAINTENANCE_HISTORY
UNION ALL
SELECT 'V_ML_TRAINING_DATASET (positive labels)', COUNT(*) FROM V_ML_TRAINING_DATASET WHERE WILL_FAIL_48H = 1
UNION ALL
SELECT 'V_ML_TRAINING_DATASET (negative labels)', COUNT(*) FROM V_ML_TRAINING_DATASET WHERE WILL_FAIL_48H = 0;

-- Sample of the training data
SELECT * FROM V_ML_TRAINING_DATASET 
WHERE WILL_FAIL_48H = 1 
ORDER BY RANDOM()
LIMIT 10;
