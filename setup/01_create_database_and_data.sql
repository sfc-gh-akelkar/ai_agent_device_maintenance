/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 1: Database, Schema, and Sample Data Setup
 * 
 * This script creates the foundation for the AI Agent demo:
 * - Role setup (SF_INTELLIGENCE_DEMO)
 * - Database and schema
 * - Device inventory table
 * - Device telemetry (time-series health data)
 * - Maintenance history
 * - Troubleshooting knowledge base
 ******************************************************************************/

-- ============================================================================
-- ROLE SETUP
-- Run these commands as ACCOUNTADMIN or a role with CREATE ROLE privilege
-- ============================================================================

-- Create the demo role
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS SF_INTELLIGENCE_DEMO
    COMMENT = 'Role for Predictive Device Maintenance Demo with Snowflake Intelligence';

-- Grant necessary account-level privileges
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;

-- Grant Cortex privileges (required for Cortex Search, Agents, etc.)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SF_INTELLIGENCE_DEMO;

-- Grant the role to current user (adjust as needed)
GRANT ROLE SF_INTELLIGENCE_DEMO TO ROLE SYSADMIN;
-- GRANT ROLE SF_INTELLIGENCE_DEMO TO USER <your_username>;

-- ============================================================================
-- SWITCH TO DEMO ROLE FOR ALL SUBSEQUENT OPERATIONS
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- WAREHOUSE SETUP (if needed)
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Device Maintenance demo';

USE WAREHOUSE COMPUTE_WH;

-- ============================================================================
-- DATABASE AND SCHEMA SETUP
-- ============================================================================
CREATE DATABASE IF NOT EXISTS DEVICE_MAINTENANCE;

-- Grant ownership to the demo role
GRANT OWNERSHIP ON DATABASE DEVICE_MAINTENANCE TO ROLE SF_INTELLIGENCE_DEMO COPY CURRENT GRANTS;

USE DATABASE DEVICE_MAINTENANCE;

CREATE SCHEMA IF NOT EXISTS DEVICE_OPS;

-- Grant ownership to the demo role
GRANT OWNERSHIP ON SCHEMA DEVICE_MAINTENANCE.DEVICE_OPS TO ROLE SF_INTELLIGENCE_DEMO COPY CURRENT GRANTS;

USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- DEVICE INVENTORY TABLE
-- All in-office screens deployed across healthcare facilities
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_INVENTORY (
    DEVICE_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_MODEL VARCHAR(50),
    FACILITY_NAME VARCHAR(100),
    FACILITY_TYPE VARCHAR(50),
    LOCATION_CITY VARCHAR(50),
    LOCATION_STATE VARCHAR(2),
    INSTALL_DATE DATE,
    WARRANTY_EXPIRY DATE,
    LAST_MAINTENANCE_DATE DATE,
    FIRMWARE_VERSION VARCHAR(20),
    STATUS VARCHAR(20) DEFAULT 'ONLINE',  -- ONLINE, OFFLINE, DEGRADED, MAINTENANCE
    -- Revenue tracking fields
    HOURLY_AD_REVENUE_USD FLOAT DEFAULT 12.50,  -- Advertising revenue per hour when online
    MONTHLY_IMPRESSIONS INT DEFAULT 15000,       -- Average monthly ad impressions
    -- Network dependency fields (CRITICAL: 90%+ devices run on provider Wi-Fi)
    NETWORK_TYPE VARCHAR(30) DEFAULT 'PROVIDER_WIFI',  -- PROVIDER_WIFI, COMPANY_MANAGED, CELLULAR
    PROVIDER_OFFICE_ID VARCHAR(20)  -- Links to the provider office (30,000 offices total)
);

-- Insert sample device inventory (100 devices across various facilities)
-- DEMO-OPTIMIZED: 90% healthy fleet with a few issues to demonstrate predictive value
-- Note: HOURLY_AD_REVENUE_USD and MONTHLY_IMPRESSIONS use defaults if not specified
INSERT INTO DEVICE_INVENTORY (DEVICE_ID, DEVICE_MODEL, FACILITY_NAME, FACILITY_TYPE, LOCATION_CITY, LOCATION_STATE, INSTALL_DATE, WARRANTY_EXPIRY, LAST_MAINTENANCE_DATE, FIRMWARE_VERSION, STATUS, HOURLY_AD_REVENUE_USD, MONTHLY_IMPRESSIONS) VALUES
    ('DEV-001', 'HealthScreen Pro 55', 'Downtown Medical Center', 'Hospital', 'Chicago', 'IL', '2023-01-15', '2026-01-15', '2024-11-01', 'v3.2.1', 'ONLINE', 15.00, 18000),
    ('DEV-002', 'HealthScreen Pro 55', 'Lakeside Family Practice', 'Primary Care', 'Chicago', 'IL', '2023-02-20', '2026-02-20', '2024-10-15', 'v3.2.1', 'ONLINE', 12.50, 15000),
    ('DEV-003', 'HealthScreen Lite 32', 'North Shore Pediatrics', 'Pediatrics', 'Evanston', 'IL', '2022-11-10', '2025-11-10', '2024-11-20', 'v3.2.1', 'ONLINE', 8.50, 10000),
    ('DEV-004', 'HealthScreen Pro 55', 'Midwest Cardiology Associates', 'Specialty', 'Oak Park', 'IL', '2023-03-05', '2026-03-05', '2024-10-10', 'v3.2.1', 'ONLINE', 14.00, 16500),
    ('DEV-005', 'HealthScreen Lite 32', 'Springfield Urgent Care', 'Urgent Care', 'Springfield', 'IL', '2022-08-22', '2025-08-22', '2024-09-01', 'v3.2.1', 'DEGRADED', 9.00, 11000),
    ('DEV-006', 'HealthScreen Pro 55', 'Memorial Hospital West', 'Hospital', 'Columbus', 'OH', '2023-04-18', '2026-04-18', '2024-11-05', 'v3.2.1', 'ONLINE', 15.50, 18500),
    ('DEV-007', 'HealthScreen Max 65', 'Cleveland Clinic Annex', 'Hospital', 'Cleveland', 'OH', '2023-06-01', '2026-06-01', '2024-12-01', 'v3.2.2', 'ONLINE', 22.00, 25000),
    ('DEV-008', 'HealthScreen Lite 32', 'Buckeye Family Medicine', 'Primary Care', 'Columbus', 'OH', '2022-09-14', '2025-09-14', '2024-10-28', 'v3.2.1', 'ONLINE', 8.00, 9500),
    ('DEV-009', 'HealthScreen Pro 55', 'Cincinnati Womens Health', 'OB/GYN', 'Cincinnati', 'OH', '2023-05-22', '2026-05-22', '2024-11-20', 'v3.2.1', 'ONLINE', 13.50, 16000),
    ('DEV-010', 'HealthScreen Pro 55', 'Dayton Orthopedic Center', 'Specialty', 'Dayton', 'OH', '2023-07-10', '2026-07-10', '2024-12-01', 'v3.2.1', 'ONLINE', 13.00, 15500),
    ('DEV-011', 'HealthScreen Max 65', 'Henry Ford Health Detroit', 'Hospital', 'Detroit', 'MI', '2023-01-08', '2026-01-08', '2024-10-01', 'v3.2.2', 'ONLINE', 21.00, 24000),
    ('DEV-012', 'HealthScreen Pro 55', 'Ann Arbor Family Care', 'Primary Care', 'Ann Arbor', 'MI', '2023-02-14', '2026-02-14', '2024-11-10', 'v3.2.1', 'ONLINE', 12.00, 14500),
    ('DEV-013', 'HealthScreen Lite 32', 'Grand Rapids Pediatrics', 'Pediatrics', 'Grand Rapids', 'MI', '2022-10-05', '2025-10-05', '2024-10-15', 'v3.2.1', 'ONLINE', 8.50, 10200),
    ('DEV-014', 'HealthScreen Pro 55', 'Lansing Cardiology Group', 'Specialty', 'Lansing', 'MI', '2023-04-01', '2026-04-01', '2024-11-01', 'v3.2.1', 'ONLINE', 13.50, 16200),
    ('DEV-015', 'HealthScreen Lite 32', 'Kalamazoo Walk-In Clinic', 'Urgent Care', 'Kalamazoo', 'MI', '2022-07-20', '2025-07-20', '2024-09-15', 'v3.2.1', 'ONLINE', 9.50, 11500),
    ('DEV-016', 'HealthScreen Pro 55', 'IU Health Indianapolis', 'Hospital', 'Indianapolis', 'IN', '2023-03-12', '2026-03-12', '2024-12-05', 'v3.2.1', 'ONLINE', 16.00, 19000),
    ('DEV-017', 'HealthScreen Max 65', 'Fort Wayne Medical Center', 'Hospital', 'Fort Wayne', 'IN', '2023-05-08', '2026-05-08', '2024-11-10', 'v3.2.2', 'ONLINE', 20.50, 23500),
    ('DEV-018', 'HealthScreen Lite 32', 'Evansville Family Practice', 'Primary Care', 'Evansville', 'IN', '2022-12-01', '2025-12-01', '2024-10-20', 'v3.2.1', 'DEGRADED', 7.50, 9000),
    ('DEV-019', 'HealthScreen Pro 55', 'South Bend Womens Clinic', 'OB/GYN', 'South Bend', 'IN', '2023-06-15', '2026-06-15', '2024-11-25', 'v3.2.1', 'ONLINE', 12.50, 15000),
    ('DEV-020', 'HealthScreen Lite 32', 'Bloomington Urgent Care', 'Urgent Care', 'Bloomington', 'IN', '2022-08-10', '2025-08-10', '2024-10-10', 'v3.2.1', 'ONLINE', 9.00, 10800),
    ('DEV-021', 'HealthScreen Pro 55', 'Aurora Health Milwaukee', 'Hospital', 'Milwaukee', 'WI', '2023-02-28', '2026-02-28', '2024-11-20', 'v3.2.1', 'ONLINE', 15.00, 17800),
    ('DEV-022', 'HealthScreen Max 65', 'UW Health Madison', 'Hospital', 'Madison', 'WI', '2023-04-10', '2026-04-10', '2024-12-01', 'v3.2.2', 'ONLINE', 23.00, 26000),
    ('DEV-023', 'HealthScreen Lite 32', 'Green Bay Pediatrics', 'Pediatrics', 'Green Bay', 'WI', '2022-09-25', '2025-09-25', '2024-10-25', 'v3.2.1', 'ONLINE', 8.00, 9600),
    ('DEV-024', 'HealthScreen Pro 55', 'Kenosha Heart Center', 'Specialty', 'Kenosha', 'WI', '2023-05-05', '2026-05-05', '2024-12-01', 'v3.2.1', 'ONLINE', 14.00, 16800),
    ('DEV-025', 'HealthScreen Lite 32', 'Appleton Walk-In Care', 'Urgent Care', 'Appleton', 'WI', '2022-06-18', '2025-06-18', '2024-09-05', 'v3.2.1', 'OFFLINE', 8.50, 10200),
    ('DEV-026', 'HealthScreen Pro 55', 'Mayo Clinic Rochester', 'Hospital', 'Rochester', 'MN', '2023-01-20', '2026-01-20', '2024-11-25', 'v3.2.1', 'ONLINE', 18.00, 21000),
    ('DEV-027', 'HealthScreen Max 65', 'Hennepin Healthcare', 'Hospital', 'Minneapolis', 'MN', '2023-03-15', '2026-03-15', '2024-12-01', 'v3.2.2', 'ONLINE', 24.00, 27000),
    ('DEV-028', 'HealthScreen Lite 32', 'St Paul Family Medicine', 'Primary Care', 'St Paul', 'MN', '2022-10-20', '2025-10-20', '2024-10-10', 'v3.2.1', 'ONLINE', 9.00, 10800),
    ('DEV-029', 'HealthScreen Pro 55', 'Duluth Womens Health', 'OB/GYN', 'Duluth', 'MN', '2023-06-01', '2026-06-01', '2024-11-20', 'v3.2.1', 'ONLINE', 11.50, 13800),
    ('DEV-030', 'HealthScreen Lite 32', 'Bloomington MN Urgent Care', 'Urgent Care', 'Bloomington', 'MN', '2022-07-08', '2025-07-08', '2024-10-20', 'v3.2.1', 'ONLINE', 9.50, 11400);

-- Add more devices to reach ~100 for a realistic demo
INSERT INTO DEVICE_INVENTORY (DEVICE_ID, DEVICE_MODEL, FACILITY_NAME, FACILITY_TYPE, LOCATION_CITY, LOCATION_STATE, INSTALL_DATE, WARRANTY_EXPIRY, LAST_MAINTENANCE_DATE, FIRMWARE_VERSION, STATUS, HOURLY_AD_REVENUE_USD, MONTHLY_IMPRESSIONS, NETWORK_TYPE, PROVIDER_OFFICE_ID)
SELECT 
    'DEV-' || LPAD((SEQ4() + 31)::VARCHAR, 3, '0'),
    CASE MOD(SEQ4(), 3) 
        WHEN 0 THEN 'HealthScreen Pro 55'
        WHEN 1 THEN 'HealthScreen Lite 32'
        ELSE 'HealthScreen Max 65'
    END,
    'Healthcare Facility ' || (SEQ4() + 31),
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Hospital'
        WHEN 1 THEN 'Primary Care'
        WHEN 2 THEN 'Specialty'
        WHEN 3 THEN 'Urgent Care'
        ELSE 'Pediatrics'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Chicago'
        WHEN 1 THEN 'Detroit'
        WHEN 2 THEN 'Cleveland'
        WHEN 3 THEN 'Indianapolis'
        WHEN 4 THEN 'Milwaukee'
        ELSE 'Minneapolis'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'IL'
        WHEN 1 THEN 'MI'
        WHEN 2 THEN 'OH'
        WHEN 3 THEN 'IN'
        WHEN 4 THEN 'WI'
        ELSE 'MN'
    END,
    DATEADD('day', -1 * (SEQ4() * 7 + 100), CURRENT_DATE()),
    DATEADD('year', 3, DATEADD('day', -1 * (SEQ4() * 7 + 100), CURRENT_DATE())),
    -- DEMO-OPTIMIZED: Recent maintenance dates (within last 60 days)
    DATEADD('day', -1 * MOD(SEQ4() * 7, 60), CURRENT_DATE()),
    'v3.2.' || MOD(SEQ4(), 3)::VARCHAR,
    -- REALISTIC: 85% ONLINE, 5% DEGRADED, 10% OFFLINE (matches industry reality)
    CASE 
        WHEN MOD(SEQ4(), 10) = 0 THEN 'OFFLINE'  -- 10% offline (realistic rate)
        WHEN MOD(SEQ4(), 15) = 0 THEN 'DEGRADED' -- ~5% degraded
        ELSE 'ONLINE'
    END,
    -- Revenue based on device model (Max > Pro > Lite)
    CASE MOD(SEQ4(), 3) 
        WHEN 0 THEN 12.50 + (MOD(SEQ4(), 5) * 0.50)  -- Pro 55: $12.50-$14.50
        WHEN 1 THEN 8.00 + (MOD(SEQ4(), 4) * 0.50)   -- Lite 32: $8.00-$9.50
        ELSE 20.00 + (MOD(SEQ4(), 6) * 0.75)         -- Max 65: $20.00-$23.75
    END,
    -- Impressions based on device model
    CASE MOD(SEQ4(), 3) 
        WHEN 0 THEN 14000 + (MOD(SEQ4(), 5) * 500)   -- Pro 55: 14000-16000
        WHEN 1 THEN 9000 + (MOD(SEQ4(), 4) * 400)    -- Lite 32: 9000-10200
        ELSE 22000 + (MOD(SEQ4(), 6) * 600)          -- Max 65: 22000-25000
    END,
    -- Network type: 90% on provider Wi-Fi, 8% managed, 2% cellular
    CASE 
        WHEN MOD(SEQ4(), 50) = 0 THEN 'CELLULAR'
        WHEN MOD(SEQ4(), 12) = 0 THEN 'COMPANY_MANAGED'
        ELSE 'PROVIDER_WIFI'
    END,
    -- Provider office ID (simulates 30,000 offices with ~5 devices each)
    'OFFICE-' || LPAD(MOD(SEQ4() + 31, 100)::VARCHAR, 5, '0')
FROM TABLE(GENERATOR(ROWCOUNT => 70));

-- Normalize all LAST_MAINTENANCE_DATE values to be relative to current date
-- This ensures "days since maintenance" calculations work regardless of when demo is run
UPDATE DEVICE_INVENTORY
SET LAST_MAINTENANCE_DATE = DATEADD('day', -1 * (5 + MOD(ABS(HASH(DEVICE_ID)), 55)), CURRENT_DATE())
WHERE LAST_MAINTENANCE_DATE IS NOT NULL;

-- Also update INSTALL_DATE and WARRANTY_EXPIRY to be relative
UPDATE DEVICE_INVENTORY
SET 
    INSTALL_DATE = DATEADD('month', -1 * (12 + MOD(ABS(HASH(DEVICE_ID)), 24)), CURRENT_DATE()),
    WARRANTY_EXPIRY = DATEADD('year', 3, DATEADD('month', -1 * (12 + MOD(ABS(HASH(DEVICE_ID)), 24)), CURRENT_DATE()));

-- ============================================================================
-- DEVICE TELEMETRY TABLE
-- Real-time health metrics from each device (IoT data)
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_TELEMETRY (
    TELEMETRY_ID VARCHAR(36) DEFAULT UUID_STRING(),
    DEVICE_ID VARCHAR(20),
    TIMESTAMP TIMESTAMP_NTZ,
    CPU_TEMP_CELSIUS FLOAT,
    CPU_USAGE_PCT FLOAT,
    MEMORY_USAGE_PCT FLOAT,
    DISK_USAGE_PCT FLOAT,
    NETWORK_LATENCY_MS FLOAT,
    DISPLAY_BRIGHTNESS_PCT FLOAT,
    UPTIME_HOURS FLOAT,
    ERROR_COUNT INT,
    LAST_HEARTBEAT TIMESTAMP_NTZ,
    -- Wi-Fi signal tracking (CRITICAL for "last gasp" analysis)
    WIFI_SIGNAL_STRENGTH INT DEFAULT -50,  -- dBm: -30 (excellent) to -90 (poor)
    CONNECTION_TYPE VARCHAR(20) DEFAULT 'WIFI',  -- WIFI, ETHERNET, CELLULAR
    CONSTRAINT fk_device FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Generate telemetry data for the past 30 days
-- REALISTIC: Fleet with 10% offline devices showing varied failure patterns
INSERT INTO DEVICE_TELEMETRY (DEVICE_ID, TIMESTAMP, CPU_TEMP_CELSIUS, CPU_USAGE_PCT, MEMORY_USAGE_PCT, 
                               DISK_USAGE_PCT, NETWORK_LATENCY_MS, DISPLAY_BRIGHTNESS_PCT, 
                               UPTIME_HOURS, ERROR_COUNT, LAST_HEARTBEAT, WIFI_SIGNAL_STRENGTH, CONNECTION_TYPE)
SELECT 
    d.DEVICE_ID,
    DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP()) as TIMESTAMP,
    -- CPU temp: healthy 42-52°C, degraded 55-65°C (showing warning signs, not critical)
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 55 + (RANDOM() / POW(10, 18)) * 10
        WHEN d.STATUS = 'OFFLINE' THEN 62 + (RANDOM() / POW(10, 18)) * 8
        ELSE 42 + (RANDOM() / POW(10, 18)) * 10
    END as CPU_TEMP_CELSIUS,
    -- CPU usage: healthy 15-35%, degraded 50-70%, capped at 99% (elevated but manageable)
    LEAST(99, CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 50 + (RANDOM() / POW(10, 18)) * 20
        WHEN d.STATUS = 'OFFLINE' THEN 65 + (RANDOM() / POW(10, 18)) * 15
        ELSE 15 + (RANDOM() / POW(10, 18)) * 20
    END) as CPU_USAGE_PCT,
    -- Memory usage: healthy 25-50%, degraded 60-75%, capped at 99%
    LEAST(99, CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 60 + (RANDOM() / POW(10, 18)) * 15
        ELSE 25 + (RANDOM() / POW(10, 18)) * 25
    END) as MEMORY_USAGE_PCT,
    -- Disk usage: healthy 35-55%
    35 + (RANDOM() / POW(10, 18)) * 20 as DISK_USAGE_PCT,
    -- Network latency: healthy 10-30ms, degraded 50-100ms
    CASE 
        WHEN d.STATUS IN ('DEGRADED', 'OFFLINE') THEN 50 + (RANDOM() / POW(10, 18)) * 50
        ELSE 10 + (RANDOM() / POW(10, 18)) * 20
    END as NETWORK_LATENCY_MS,
    -- Display brightness: consistent 80-100%
    80 + (RANDOM() / POW(10, 18)) * 20 as DISPLAY_BRIGHTNESS_PCT,
    -- Uptime hours: 24-336 hours (1-14 days, regular reboots show good maintenance)
    24 + (RANDOM() / POW(10, 18)) * 312 as UPTIME_HOURS,
    -- Error count: healthy 0-1, degraded 3-8 (noticeable but not alarming)
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN FLOOR((RANDOM() / POW(10, 18)) * 5) + 3
        WHEN d.STATUS = 'OFFLINE' THEN FLOOR((RANDOM() / POW(10, 18)) * 8) + 5
        ELSE FLOOR((RANDOM() / POW(10, 18)) * 2)
    END as ERROR_COUNT,
    DATEADD('minute', -1 * FLOOR((RANDOM() / POW(10, 18)) * 2), DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP())) as LAST_HEARTBEAT,
    -- Wi-Fi signal strength: healthy -45 to -60, degraded -65 to -75, offline sudden drop to -85
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN -85 + FLOOR((RANDOM() / POW(10, 18)) * 10)  -- Poor signal before going offline
        WHEN d.STATUS = 'DEGRADED' THEN -65 + FLOOR((RANDOM() / POW(10, 18)) * 15)
        ELSE -45 + FLOOR((RANDOM() / POW(10, 18)) * 15)  -- Good signal
    END as WIFI_SIGNAL_STRENGTH,
    -- Connection type based on device network type (most are WIFI)
    CASE WHEN d.NETWORK_TYPE = 'CELLULAR' THEN 'CELLULAR' ELSE 'WIFI' END as CONNECTION_TYPE
FROM DEVICE_INVENTORY d
CROSS JOIN (SELECT SEQ4() as SEQ FROM TABLE(GENERATOR(ROWCOUNT => 720))) t  -- 30 days * 24 hours
WHERE t.SEQ < 720;

-- ============================================================================
-- DEMO REFERENCE TIME VIEW
-- This provides a stable "current time" based on the latest telemetry data
-- Ensures demo works regardless of when it's run
-- Column names avoid conflict with Snowflake built-in functions
-- ============================================================================
CREATE OR REPLACE VIEW V_DEMO_REFERENCE_TIME AS
SELECT 
    MAX(TIMESTAMP) as REFERENCE_TIMESTAMP,
    MAX(TIMESTAMP)::DATE as REFERENCE_DATE,
    DATE_TRUNC('month', MAX(TIMESTAMP)) as REFERENCE_MONTH_START
FROM DEVICE_TELEMETRY;

-- ============================================================================
-- MAINTENANCE HISTORY TABLE
-- Past service tickets and resolutions
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_HISTORY (
    TICKET_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    CREATED_AT TIMESTAMP_NTZ,
    RESOLVED_AT TIMESTAMP_NTZ,
    ISSUE_TYPE VARCHAR(50),
    ISSUE_DESCRIPTION TEXT,
    RESOLUTION_TYPE VARCHAR(30),  -- REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT
    RESOLUTION_NOTES TEXT,
    TECHNICIAN_ID VARCHAR(20),
    COST_USD FLOAT,
    CONSTRAINT fk_device_maint FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert realistic maintenance history using relative dates
-- All dates are relative to CURRENT_TIMESTAMP() so demo works regardless of when it's run
-- Using DATEADD with hours for Snowflake compatibility
INSERT INTO MAINTENANCE_HISTORY 
    (TICKET_ID, DEVICE_ID, CREATED_AT, RESOLVED_AT, ISSUE_TYPE, ISSUE_DESCRIPTION, RESOLUTION_TYPE, RESOLUTION_NOTES, TECHNICIAN_ID, COST_USD)
-- 90 days ago
SELECT 'TKT-001', 'DEV-003', DATEADD('hour', 8, DATEADD('day', -90, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -90, CURRENT_TIMESTAMP())), 'DISPLAY_FREEZE', 'Screen frozen on splash screen, unresponsive to touch', 'REMOTE_FIX', 'Performed remote restart via agent. Display resumed normal operation.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-002', 'DEV-005', DATEADD('hour', 14, DATEADD('day', -87, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -86, CURRENT_TIMESTAMP())), 'NO_NETWORK', 'Device offline, no heartbeat for 6 hours', 'FIELD_DISPATCH', 'Router failure at facility. Replaced ethernet cable and reset network config.', 'TECH-042', 185.00
UNION ALL
SELECT 'TKT-003', 'DEV-008', DATEADD('hour', 10, DATEADD('day', -83, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -83, CURRENT_TIMESTAMP())), 'HIGH_CPU', 'CPU usage consistently above 90%, sluggish performance', 'REMOTE_FIX', 'Killed runaway process and cleared temp files. Scheduled firmware update.', 'REMOTE_AGENT', 0
UNION ALL
-- 74-70 days ago
SELECT 'TKT-004', 'DEV-014', DATEADD('hour', 9, DATEADD('day', -74, CURRENT_TIMESTAMP())), DATEADD('hour', 14, DATEADD('day', -73, CURRENT_TIMESTAMP())), 'DISPLAY_FAILURE', 'Display showing vertical lines, hardware malfunction suspected', 'REPLACEMENT', 'Display panel replaced. Root cause: power surge damage.', 'TECH-018', 450.00
UNION ALL
SELECT 'TKT-005', 'DEV-018', DATEADD('hour', 16, DATEADD('day', -70, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -69, CURRENT_TIMESTAMP())), 'BOOT_FAILURE', 'Device stuck in boot loop', 'FIELD_DISPATCH', 'Corrupted firmware. Reflashed via USB. Recommended UPS installation.', 'TECH-025', 210.00
UNION ALL
-- 65-50 days ago
SELECT 'TKT-006', 'DEV-020', DATEADD('hour', 11, DATEADD('day', -65, CURRENT_TIMESTAMP())), DATEADD('hour', 12, DATEADD('day', -65, CURRENT_TIMESTAMP())), 'MEMORY_LEAK', 'Memory usage climbing to 95%, app crashes', 'REMOTE_FIX', 'Restarted application services and cleared cache. Issue resolved.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-007', 'DEV-025', DATEADD('hour', 8, DATEADD('day', -60, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -60, CURRENT_TIMESTAMP())), 'CONNECTIVITY', 'Intermittent WiFi disconnections', 'REMOTE_FIX', 'Reset network adapter and updated WiFi driver remotely.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-008', 'DEV-003', DATEADD('hour', 13, DATEADD('day', -55, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -54, CURRENT_TIMESTAMP())), 'DISPLAY_FREEZE', 'Recurring freeze issue, third occurrence this month', 'FIELD_DISPATCH', 'Replaced thermal paste and cleaned internal fans. Overheating was root cause.', 'TECH-042', 165.00
UNION ALL
SELECT 'TKT-009', 'DEV-012', DATEADD('hour', 10, DATEADD('day', -50, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -50, CURRENT_TIMESTAMP())), 'SOFTWARE_UPDATE', 'Scheduled firmware update to v3.2.2', 'REMOTE_FIX', 'Successfully pushed firmware update remotely.', 'REMOTE_AGENT', 0
UNION ALL
-- 45-30 days ago
SELECT 'TKT-010', 'DEV-007', DATEADD('hour', 14, DATEADD('day', -44, CURRENT_TIMESTAMP())), DATEADD('hour', 14, DATEADD('day', -44, CURRENT_TIMESTAMP())), 'DISPLAY_CALIBRATION', 'Touch calibration off, users reporting missed inputs', 'REMOTE_FIX', 'Ran remote touch calibration routine. Accuracy restored.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-011', 'DEV-005', DATEADD('hour', 9, DATEADD('day', -40, CURRENT_TIMESTAMP())), DATEADD('hour', 16, DATEADD('day', -40, CURRENT_TIMESTAMP())), 'NO_NETWORK', 'Device offline again, same facility as TKT-002', 'FIELD_DISPATCH', 'Facility network infrastructure unstable. Recommended network audit to facility manager.', 'TECH-042', 185.00
UNION ALL
SELECT 'TKT-012', 'DEV-019', DATEADD('hour', 11, DATEADD('day', -35, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -35, CURRENT_TIMESTAMP())), 'HIGH_MEMORY', 'Memory at 88%, preemptive maintenance flag', 'REMOTE_FIX', 'Cleared application cache and restarted services proactively.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-013', 'DEV-022', DATEADD('hour', 8, DATEADD('day', -30, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -30, CURRENT_TIMESTAMP())), 'SLOW_RESPONSE', 'UI lag reported by staff', 'REMOTE_FIX', 'Optimized database queries and cleared log files.', 'REMOTE_AGENT', 0
UNION ALL
-- 25-15 days ago
SELECT 'TKT-014', 'DEV-008', DATEADD('hour', 15, DATEADD('day', -25, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -24, CURRENT_TIMESTAMP())), 'OVERHEATING', 'CPU temp above 80C, automatic shutdown triggered', 'FIELD_DISPATCH', 'Replaced cooling fan and cleaned dust filters.', 'TECH-018', 195.00
UNION ALL
SELECT 'TKT-015', 'DEV-014', DATEADD('hour', 10, DATEADD('day', -20, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -20, CURRENT_TIMESTAMP())), 'DISPLAY_FLICKER', 'Occasional screen flicker', 'REMOTE_FIX', 'Adjusted display refresh rate settings remotely.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-016', 'DEV-001', DATEADD('hour', 9, DATEADD('day', -17, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -17, CURRENT_TIMESTAMP())), 'HIGH_CPU', 'CPU usage spike detected by AI monitoring', 'REMOTE_FIX', 'AI agent proactively restarted services before user impact.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-017', 'DEV-006', DATEADD('hour', 14, DATEADD('day', -16, CURRENT_TIMESTAMP())), DATEADD('hour', 15, DATEADD('day', -16, CURRENT_TIMESTAMP())), 'CONNECTIVITY', 'Brief network latency spike', 'REMOTE_FIX', 'Reset network stack and DNS cache remotely.', 'REMOTE_AGENT', 0
UNION ALL
-- Current month (last 14 days) - These will show up in "this month" queries
SELECT 'TKT-018', 'DEV-011', DATEADD('hour', 10, DATEADD('day', -12, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -12, CURRENT_TIMESTAMP())), 'MEMORY_LEAK', 'Predictive alert: memory trending high', 'REMOTE_FIX', 'Proactive cache clear prevented potential crash.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-019', 'DEV-016', DATEADD('hour', 11, DATEADD('day', -10, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -10, CURRENT_TIMESTAMP())), 'SOFTWARE_UPDATE', 'Scheduled security patch deployment', 'REMOTE_FIX', 'Successfully applied security patches across batch.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-020', 'DEV-021', DATEADD('hour', 8, DATEADD('day', -8, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -8, CURRENT_TIMESTAMP())), 'SLOW_RESPONSE', 'AI detected performance degradation', 'REMOTE_FIX', 'Optimized application settings and cleared temp files.', 'REMOTE_AGENT', 0
UNION ALL
-- Very recent (last week)
SELECT 'TKT-021', 'DEV-002', DATEADD('hour', 9, DATEADD('day', -5, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -5, CURRENT_TIMESTAMP())), 'HIGH_CPU', 'Proactive CPU throttling detected', 'REMOTE_FIX', 'Restarted background services, performance restored.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-022', 'DEV-009', DATEADD('hour', 14, DATEADD('day', -3, CURRENT_TIMESTAMP())), DATEADD('hour', 14, DATEADD('day', -3, CURRENT_TIMESTAMP())), 'CONNECTIVITY', 'Intermittent connection drops', 'REMOTE_FIX', 'Reset network adapter and cleared DNS cache.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-023', 'DEV-015', DATEADD('hour', 10, DATEADD('day', -2, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -2, CURRENT_TIMESTAMP())), 'MEMORY_LEAK', 'AI predictive alert: memory trending upward', 'REMOTE_FIX', 'Proactive cache clear and service restart.', 'REMOTE_AGENT', 0
UNION ALL
SELECT 'TKT-024', 'DEV-023', DATEADD('hour', 11, DATEADD('day', -1, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -1, CURRENT_TIMESTAMP())), 'DISPLAY_FREEZE', 'Brief display freeze reported', 'REMOTE_FIX', 'Remote restart resolved issue within 15 minutes.', 'REMOTE_AGENT', 0;

-- ============================================================================
-- TROUBLESHOOTING KNOWLEDGE BASE
-- Documentation for the AI agent to reference
-- ============================================================================
CREATE OR REPLACE TABLE TROUBLESHOOTING_KB (
    KB_ID VARCHAR(20) PRIMARY KEY,
    ISSUE_CATEGORY VARCHAR(50),
    ISSUE_SYMPTOMS TEXT,
    DIAGNOSTIC_STEPS TEXT,
    REMOTE_FIX_PROCEDURE TEXT,
    REQUIRES_DISPATCH BOOLEAN,
    ESTIMATED_REMOTE_FIX_TIME_MINS INT,
    SUCCESS_RATE_PCT FLOAT,
    LAST_UPDATED DATE
);

INSERT INTO TROUBLESHOOTING_KB VALUES
    ('KB-001', 'DISPLAY_FREEZE', 
     'Screen frozen, unresponsive to touch, display shows static image, no UI updates',
     '1. Check last heartbeat timestamp\n2. Verify CPU and memory usage\n3. Check for high error count\n4. Review recent telemetry for anomalies',
     '1. Attempt soft restart via remote command\n2. If unresponsive, force restart device\n3. Clear application cache\n4. Verify display resumes normal operation\n5. Monitor for 15 minutes post-fix',
     FALSE, 15, 87.5, '2024-10-01'),
    
    ('KB-002', 'NO_NETWORK',
     'Device offline, no heartbeat received, network connectivity lost, cannot reach device remotely',
     '1. Check last known network latency\n2. Verify facility network status if available\n3. Review historical network issues at location\n4. Check for patterns with other devices at same facility',
     '1. If device comes back online, reset network adapter\n2. Update network configuration\n3. Clear DNS cache\n4. Test connectivity to cloud services',
     TRUE, NULL, 25.0, '2024-10-15'),
    
    ('KB-003', 'HIGH_CPU',
     'CPU usage above 80%, sluggish performance, slow UI response, potential runaway process',
     '1. Check current CPU usage percentage\n2. Identify process consuming resources\n3. Check memory usage correlation\n4. Review uptime - long uptime may indicate need for restart',
     '1. Identify and terminate runaway processes\n2. Clear temporary files and cache\n3. Restart high-consumption services\n4. If persistent, schedule firmware update\n5. Consider restart if uptime exceeds 30 days',
     FALSE, 10, 92.0, '2024-09-20'),
    
    ('KB-004', 'HIGH_MEMORY',
     'Memory usage above 85%, application crashes, out of memory errors, slow performance',
     '1. Check current memory usage percentage\n2. Identify memory-consuming applications\n3. Check for memory leak patterns over time\n4. Review application logs for OOM errors',
     '1. Restart application services to free memory\n2. Clear application cache\n3. Remove old log files\n4. If recurring, escalate for code review',
     FALSE, 8, 94.0, '2024-09-25'),
    
    ('KB-005', 'OVERHEATING',
     'CPU temperature above 75C, thermal throttling, automatic shutdowns, fan noise',
     '1. Check current CPU temperature\n2. Compare to historical baseline\n3. Check ambient temperature if available\n4. Review CPU usage - high usage causes heat',
     '1. Reduce CPU load by stopping non-essential processes\n2. If persistent high temp, schedule field visit\n3. Remote restart may temporarily help\n4. Document for preventive maintenance',
     TRUE, NULL, 15.0, '2024-10-05'),
    
    ('KB-006', 'DISPLAY_FLICKER',
     'Screen flickering, intermittent display issues, refresh rate problems, visual artifacts',
     '1. Check display brightness settings\n2. Review recent configuration changes\n3. Check for electromagnetic interference patterns\n4. Verify display driver version',
     '1. Reset display settings to default\n2. Update display driver if outdated\n3. Adjust refresh rate settings\n4. Recalibrate display output',
     FALSE, 12, 78.0, '2024-10-10'),
    
    ('KB-007', 'CONNECTIVITY_INTERMITTENT',
     'Sporadic disconnections, high network latency spikes, packet loss, unstable connection',
     '1. Review network latency history\n2. Check for patterns (time of day, concurrent devices)\n3. Verify WiFi signal strength if wireless\n4. Check for IP conflicts',
     '1. Reset network adapter\n2. Renew DHCP lease\n3. Update network drivers\n4. Switch to backup network if available\n5. Clear network cache',
     FALSE, 10, 70.0, '2024-10-20'),
    
    ('KB-008', 'BOOT_FAILURE',
     'Device stuck in boot loop, fails to start, shows error on boot, cannot reach OS',
     '1. Review last successful boot timestamp\n2. Check for recent updates that may have failed\n3. Verify power stability at location\n4. Check for corrupted system files',
     '1. Attempt remote recovery mode if accessible\n2. Push recovery firmware if device responds\n3. Most boot failures require physical access',
     TRUE, NULL, 10.0, '2024-10-25'),
    
    ('KB-009', 'SOFTWARE_UPDATE',
     'Firmware update required, outdated version detected, security patch needed',
     '1. Verify current firmware version\n2. Check compatibility with latest release\n3. Confirm device is stable before update\n4. Verify network connectivity for download',
     '1. Schedule update during off-hours if possible\n2. Push firmware update package\n3. Monitor update progress\n4. Verify successful installation\n5. Confirm device restarts properly',
     FALSE, 20, 98.0, '2024-11-01'),
    
    ('KB-010', 'DISK_FULL',
     'Disk usage above 90%, cannot save data, application errors, log rotation failure',
     '1. Check current disk usage percentage\n2. Identify large files or directories\n3. Review log file sizes\n4. Check for failed cleanup jobs',
     '1. Clear old log files\n2. Remove temporary files\n3. Clear application cache\n4. Archive old data if needed\n5. Verify disk space recovered',
     FALSE, 10, 96.0, '2024-11-05');

-- ============================================================================
-- DEVICE DOWNTIME TRACKING TABLE
-- Tracks periods when devices are offline for revenue impact calculation
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_DOWNTIME (
    DOWNTIME_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    DOWNTIME_START TIMESTAMP_NTZ,
    DOWNTIME_END TIMESTAMP_NTZ,
    DOWNTIME_HOURS FLOAT,
    CAUSE VARCHAR(50),  -- HARDWARE_FAILURE, NETWORK_OUTAGE, SOFTWARE_ISSUE, MAINTENANCE
    TICKET_ID VARCHAR(20),
    REVENUE_LOSS_USD FLOAT,
    IMPRESSIONS_LOST INT,
    CONSTRAINT fk_device_downtime FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert sample downtime records (correlate with maintenance history)
-- Insert downtime data using relative dates to match maintenance history
-- Using DATEADD with hours for Snowflake compatibility
INSERT INTO DEVICE_DOWNTIME (DEVICE_ID, DOWNTIME_START, DOWNTIME_END, DOWNTIME_HOURS, CAUSE, TICKET_ID, REVENUE_LOSS_USD, IMPRESSIONS_LOST)
SELECT 'DEV-005', DATEADD('hour', 14, DATEADD('day', -87, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -86, CURRENT_TIMESTAMP())), 20.67, 'NETWORK_OUTAGE', 'TKT-002', 258.38, 430
UNION ALL
SELECT 'DEV-014', DATEADD('hour', 9, DATEADD('day', -74, CURRENT_TIMESTAMP())), DATEADD('hour', 14, DATEADD('day', -73, CURRENT_TIMESTAMP())), 29.5, 'HARDWARE_FAILURE', 'TKT-004', 368.75, 615
UNION ALL
SELECT 'DEV-018', DATEADD('hour', 16, DATEADD('day', -70, CURRENT_TIMESTAMP())), DATEADD('hour', 10, DATEADD('day', -69, CURRENT_TIMESTAMP())), 17.5, 'SOFTWARE_ISSUE', 'TKT-005', 218.75, 365
UNION ALL
SELECT 'DEV-003', DATEADD('hour', 13, DATEADD('day', -55, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -54, CURRENT_TIMESTAMP())), 19.75, 'HARDWARE_FAILURE', 'TKT-008', 246.88, 410
UNION ALL
SELECT 'DEV-005', DATEADD('hour', 9, DATEADD('day', -40, CURRENT_TIMESTAMP())), DATEADD('hour', 16, DATEADD('day', -40, CURRENT_TIMESTAMP())), 7.25, 'NETWORK_OUTAGE', 'TKT-011', 90.63, 150
UNION ALL
SELECT 'DEV-008', DATEADD('hour', 15, DATEADD('day', -25, CURRENT_TIMESTAMP())), DATEADD('hour', 11, DATEADD('day', -24, CURRENT_TIMESTAMP())), 19.5, 'HARDWARE_FAILURE', 'TKT-014', 243.75, 405
UNION ALL
-- Some unplanned downtime without tickets (discovered by monitoring)
SELECT 'DEV-020', DATEADD('hour', 2, DATEADD('day', -67, CURRENT_TIMESTAMP())), DATEADD('hour', 6, DATEADD('day', -67, CURRENT_TIMESTAMP())), 4.5, 'SOFTWARE_ISSUE', NULL, 56.25, 95
UNION ALL
SELECT 'DEV-025', DATEADD('hour', 22, DATEADD('day', -53, CURRENT_TIMESTAMP())), DATEADD('hour', 1, DATEADD('day', -52, CURRENT_TIMESTAMP())), 3.5, 'NETWORK_OUTAGE', NULL, 43.75, 75
UNION ALL
SELECT 'DEV-014', DATEADD('hour', 8, DATEADD('day', -43, CURRENT_TIMESTAMP())), DATEADD('hour', 9, DATEADD('day', -43, CURRENT_TIMESTAMP())), 1.25, 'SOFTWARE_ISSUE', NULL, 15.63, 25
UNION ALL
SELECT 'DEV-003', DATEADD('hour', 14, DATEADD('day', -27, CURRENT_TIMESTAMP())), DATEADD('hour', 15, DATEADD('day', -27, CURRENT_TIMESTAMP())), 1.5, 'SOFTWARE_ISSUE', NULL, 18.75, 30;

-- ============================================================================
-- DEVICE LAST GASP TABLE (NEW: "Last Gasp" telemetry capture)
-- Captures final device readings before going offline to classify failure cause
-- CRITICAL: This enables distinguishing Wi-Fi password changes from hardware failures
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_LAST_GASP (
    LAST_GASP_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    OFFLINE_TIMESTAMP TIMESTAMP_NTZ,
    -- Final readings before device went silent
    LAST_SIGNAL_STRENGTH INT,           -- Wi-Fi dBm: -30 excellent, -90 poor
    LAST_CPU_TEMP FLOAT,
    LAST_MEMORY_PCT FLOAT,
    LAST_ERROR_COUNT INT,
    -- Signal analysis
    SIGNAL_TREND VARCHAR(20),           -- SUDDEN_DROP, GRADUAL_DECLINE, STABLE
    SIGNAL_DROP_RATE FLOAT,             -- dBm/minute before going offline
    -- Failure classification (ML/rule-based)
    CLASSIFIED_CAUSE VARCHAR(50),       -- WIFI_PASSWORD_CHANGE, HARDWARE_FAILURE, NETWORK_OUTAGE, POWER_LOSS
    CLASSIFICATION_CONFIDENCE FLOAT,    -- 0.0 to 1.0
    CLASSIFICATION_REASON TEXT,         -- Human-readable explanation
    -- Resolution tracking
    RESOLVED_TIMESTAMP TIMESTAMP_NTZ,
    ACTUAL_CAUSE VARCHAR(50),           -- Confirmed cause after resolution
    RESOLUTION_ACTION VARCHAR(100),     -- What fixed it: CALL_OFFICE, DISPATCH_TECH, REMOTE_RESTART
    CONSTRAINT fk_last_gasp_device FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert sample "last gasp" data for offline devices
-- This demonstrates failure classification based on telemetry patterns
INSERT INTO DEVICE_LAST_GASP (DEVICE_ID, OFFLINE_TIMESTAMP, LAST_SIGNAL_STRENGTH, LAST_CPU_TEMP, 
    LAST_MEMORY_PCT, LAST_ERROR_COUNT, SIGNAL_TREND, SIGNAL_DROP_RATE,
    CLASSIFIED_CAUSE, CLASSIFICATION_CONFIDENCE, CLASSIFICATION_REASON,
    RESOLVED_TIMESTAMP, ACTUAL_CAUSE, RESOLUTION_ACTION)
-- Wi-Fi password change pattern: Sudden signal drop, otherwise healthy metrics
SELECT 'DEV-025', DATEADD('hour', -18, CURRENT_TIMESTAMP()), -88, 52.3, 45.2, 0, 'SUDDEN_DROP', 15.5,
    'WIFI_PASSWORD_CHANGE', 0.92, 'Signal dropped suddenly from -45 to -88 dBm in <2 mins. CPU/memory normal. Pattern matches credential rotation.',
    NULL, NULL, NULL
UNION ALL
-- Hardware failure pattern: Gradual degradation, high temps, errors
SELECT 'DEV-031', DATEADD('hour', -36, CURRENT_TIMESTAMP()), -52, 78.5, 88.3, 47, 'STABLE', 0.2,
    'HARDWARE_FAILURE', 0.87, 'High CPU temp (78C), memory at 88%, 47 errors logged. Signal was stable. Thermal/component failure suspected.',
    NULL, NULL, NULL
UNION ALL
-- Network outage pattern: Multiple devices in same office went down together
SELECT 'DEV-081', DATEADD('hour', -72, CURRENT_TIMESTAMP()), -91, 55.1, 52.4, 3, 'GRADUAL_DECLINE', 2.1,
    'NETWORK_OUTAGE', 0.78, 'Signal declined gradually over 30 mins. Other devices in same office also offline. Provider network issue likely.',
    NULL, NULL, NULL
UNION ALL
-- Resolved: Wi-Fi password change - fixed by calling office
SELECT 'DEV-017', DATEADD('hour', -168, CURRENT_TIMESTAMP()), -85, 51.2, 42.1, 0, 'SUDDEN_DROP', 18.2,
    'WIFI_PASSWORD_CHANGE', 0.95, 'Sudden signal loss, healthy metrics. Classic password rotation pattern.',
    DATEADD('hour', -166, CURRENT_TIMESTAMP()), 'WIFI_PASSWORD_CHANGE', 'CALL_OFFICE'
UNION ALL
-- Resolved: Power loss - fixed by remote restart after power restored
SELECT 'DEV-042', DATEADD('hour', -120, CURRENT_TIMESTAMP()), -48, 49.8, 38.5, 0, 'STABLE', 0.0,
    'POWER_LOSS', 0.89, 'All metrics normal, signal stable, then instant disconnect. No degradation pattern. Power event suspected.',
    DATEADD('hour', -116, CURRENT_TIMESTAMP()), 'POWER_LOSS', 'REMOTE_RESTART';

-- ============================================================================
-- ACTIVE DOWNTIME TABLE
-- Tracks devices currently experiencing downtime (ongoing incidents)
-- These are the 3 OFFLINE devices with active/open incidents
-- ============================================================================
CREATE OR REPLACE TABLE ACTIVE_DOWNTIME (
    INCIDENT_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    DOWNTIME_START TIMESTAMP_NTZ,
    CAUSE VARCHAR(50),
    TICKET_ID VARCHAR(20),
    ESTIMATED_RESOLUTION VARCHAR(100),
    PRIORITY VARCHAR(20),
    CONSTRAINT fk_active_downtime FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert active downtime for the 3 OFFLINE devices
-- These show devices that went down recently and haven't been fixed yet
INSERT INTO ACTIVE_DOWNTIME (DEVICE_ID, DOWNTIME_START, CAUSE, TICKET_ID, ESTIMATED_RESOLUTION, PRIORITY)
VALUES 
    -- DEV-025: Offline for ~18 hours (network issue discovered this morning)
    ('DEV-025', DATEADD('hour', -18, CURRENT_TIMESTAMP()), 'NETWORK_OUTAGE', 'TKT-025', 'Awaiting network team investigation', 'CRITICAL'),
    -- DEV-031: Offline for ~36 hours (hardware failure, parts on order)
    ('DEV-031', DATEADD('hour', -36, CURRENT_TIMESTAMP()), 'HARDWARE_FAILURE', 'TKT-031', 'Replacement display shipped, ETA 2 days', 'CRITICAL'),
    -- DEV-081: Offline for ~72 hours (complex issue, escalated)
    ('DEV-081', DATEADD('hour', -72, CURRENT_TIMESTAMP()), 'HARDWARE_FAILURE', 'TKT-081', 'Escalated to engineering - motherboard replacement', 'CRITICAL');

-- ============================================================================
-- VIEW: CURRENT DOWNTIME IMPACT
-- Shows revenue being lost RIGHT NOW from offline devices
-- ============================================================================
CREATE OR REPLACE VIEW V_CURRENT_DOWNTIME_IMPACT AS
SELECT 
    ad.DEVICE_ID,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.DEVICE_MODEL,
    d.HOURLY_AD_REVENUE_USD,
    ad.DOWNTIME_START,
    ad.CAUSE,
    ad.TICKET_ID,
    ad.PRIORITY,
    ad.ESTIMATED_RESOLUTION,
    -- Calculate hours offline
    ROUND(DATEDIFF('minute', ad.DOWNTIME_START, CURRENT_TIMESTAMP()) / 60.0, 1) as HOURS_OFFLINE,
    -- Calculate revenue lost so far
    ROUND(d.HOURLY_AD_REVENUE_USD * DATEDIFF('minute', ad.DOWNTIME_START, CURRENT_TIMESTAMP()) / 60.0, 2) as REVENUE_LOST_SO_FAR,
    -- Calculate impressions lost (estimate based on hourly rate)
    ROUND(d.MONTHLY_IMPRESSIONS / 720.0 * DATEDIFF('minute', ad.DOWNTIME_START, CURRENT_TIMESTAMP()) / 60.0) as IMPRESSIONS_LOST_SO_FAR,
    -- Daily burn rate
    ROUND(d.HOURLY_AD_REVENUE_USD * 24, 2) as DAILY_REVENUE_LOSS_RATE
FROM ACTIVE_DOWNTIME ad
JOIN DEVICE_INVENTORY d ON ad.DEVICE_ID = d.DEVICE_ID
WHERE d.STATUS = 'OFFLINE';

-- ============================================================================
-- PROVIDER FEEDBACK TABLE
-- Customer satisfaction tracking from healthcare providers
-- ============================================================================
CREATE OR REPLACE TABLE PROVIDER_FEEDBACK (
    FEEDBACK_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    FACILITY_NAME VARCHAR(100) NOT NULL,  -- Ensure facility name is always provided
    DEVICE_ID VARCHAR(20),
    FEEDBACK_DATE DATE,
    NPS_SCORE INT,  -- Net Promoter Score: -100 to 100 (calculated from 0-10 rating)
    SATISFACTION_RATING INT,  -- 1-5 stars
    RESPONSE_TIME_RATING INT,  -- 1-5 stars (how quickly issues were resolved)
    DEVICE_RELIABILITY_RATING INT,  -- 1-5 stars
    FEEDBACK_CATEGORY VARCHAR(50),  -- POSITIVE, NEUTRAL, NEGATIVE
    FEEDBACK_TEXT TEXT,
    FOLLOW_UP_REQUIRED BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_device_feedback FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert sample provider feedback
-- Insert feedback data using relative dates
INSERT INTO PROVIDER_FEEDBACK (FACILITY_NAME, DEVICE_ID, FEEDBACK_DATE, NPS_SCORE, SATISFACTION_RATING, 
                                RESPONSE_TIME_RATING, DEVICE_RELIABILITY_RATING, FEEDBACK_CATEGORY, 
                                FEEDBACK_TEXT, FOLLOW_UP_REQUIRED)
-- Positive feedback (recent)
SELECT 'Downtown Medical Center', 'DEV-001', DATEADD('day', -30, CURRENT_DATE())::DATE, 9, 5, 5, 5, 'POSITIVE', 
     'The screen has been running flawlessly. Patients love the health tips displayed.', FALSE
UNION ALL
SELECT 'Lakeside Family Practice', 'DEV-002', DATEADD('day', -35, CURRENT_DATE())::DATE, 8, 4, 5, 4, 'POSITIVE', 
     'Quick response when we had a minor issue. Very satisfied with the service.', FALSE
UNION ALL
SELECT 'Memorial Hospital West', 'DEV-006', DATEADD('day', -25, CURRENT_DATE())::DATE, 10, 5, 5, 5, 'POSITIVE', 
     'Excellent product and support. The remote fix capability saved us a lot of hassle.', FALSE
UNION ALL
SELECT 'Cleveland Clinic Annex', 'DEV-007', DATEADD('day', -27, CURRENT_DATE())::DATE, 9, 5, 4, 5, 'POSITIVE', 
     'Large screen is perfect for our waiting area. Great visibility for all patients.', FALSE
UNION ALL
SELECT 'Ann Arbor Family Care', 'DEV-012', DATEADD('day', -33, CURRENT_DATE())::DATE, 8, 4, 4, 4, 'POSITIVE', 
     'Reliable device. The educational content is very helpful for patient engagement.', FALSE
UNION ALL
SELECT 'Mayo Clinic Rochester', 'DEV-026', DATEADD('day', -23, CURRENT_DATE())::DATE, 10, 5, 5, 5, 'POSITIVE', 
     'Top-notch equipment and support. Exactly what we expect from a premium partner.', FALSE
UNION ALL
-- Additional positive feedback (DEMO-OPTIMIZED for higher satisfaction scores)
SELECT 'Henry Ford Health Detroit', 'DEV-011', DATEADD('day', -20, CURRENT_DATE())::DATE, 9, 5, 5, 5, 'POSITIVE', 
     'Outstanding reliability. The device has been running perfectly for months.', FALSE
UNION ALL
SELECT 'IU Health Indianapolis', 'DEV-016', DATEADD('day', -17, CURRENT_DATE())::DATE, 10, 5, 5, 5, 'POSITIVE', 
     'Best digital signage solution we have used. Patients and staff love it.', FALSE
UNION ALL
SELECT 'Fort Wayne Medical Center', 'DEV-017', DATEADD('day', -15, CURRENT_DATE())::DATE, 9, 4, 5, 5, 'POSITIVE', 
     'The predictive maintenance alerts have been incredibly helpful.', FALSE
UNION ALL
SELECT 'UW Health Madison', 'DEV-022', DATEADD('day', -12, CURRENT_DATE())::DATE, 10, 5, 5, 5, 'POSITIVE', 
     'World-class support team. Issues get resolved before we even notice them.', FALSE
UNION ALL
SELECT 'Hennepin Healthcare', 'DEV-027', DATEADD('day', -8, CURRENT_DATE())::DATE, 9, 5, 4, 5, 'POSITIVE', 
     'Remote fix capability is a game changer. No more waiting for technicians.', FALSE
UNION ALL
-- Neutral feedback (only 2 for realistic balance)
SELECT 'North Shore Pediatrics', 'DEV-003', DATEADD('day', -50, CURRENT_DATE())::DATE, 7, 4, 4, 4, 'NEUTRAL', 
     'Device works well. Would love to see more pediatric-focused content options.', FALSE
UNION ALL
SELECT 'Lansing Cardiology Group', 'DEV-014', DATEADD('day', -60, CURRENT_DATE())::DATE, 7, 4, 4, 4, 'NEUTRAL', 
     'Solid performance. Recent firmware update improved responsiveness.', FALSE
UNION ALL
-- Negative feedback (only 1 to show opportunity for improvement)
SELECT 'Springfield Urgent Care', 'DEV-005', DATEADD('day', -35, CURRENT_DATE())::DATE, 5, 3, 3, 3, 'NEGATIVE', 
     'Had a brief network outage last month. Support resolved it quickly but would prefer proactive alerts.', TRUE;

-- ============================================================================
-- REVENUE IMPACT VIEW
-- Calculates revenue loss from device downtime
-- NOTE: Uptime now accounts for current device status (OFFLINE = not 100% uptime)
-- ============================================================================
CREATE OR REPLACE VIEW V_REVENUE_IMPACT AS
SELECT 
    d.DEVICE_ID,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.STATUS as CURRENT_STATUS,
    d.HOURLY_AD_REVENUE_USD,
    d.MONTHLY_IMPRESSIONS,
    -- Downtime statistics from historical records
    COUNT(dt.DOWNTIME_ID) as DOWNTIME_INCIDENTS,
    COALESCE(SUM(dt.DOWNTIME_HOURS), 0) as TOTAL_DOWNTIME_HOURS,
    COALESCE(SUM(dt.REVENUE_LOSS_USD), 0) as TOTAL_REVENUE_LOSS_USD,
    COALESCE(SUM(dt.IMPRESSIONS_LOST), 0) as TOTAL_IMPRESSIONS_LOST,
    -- Uptime calculation that accounts for CURRENT status
    -- OFFLINE devices get 0% uptime, DEGRADED gets 50%, ONLINE gets 100% (minus historical downtime)
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 0.0
        WHEN d.STATUS = 'DEGRADED' THEN 50.0
        ELSE ROUND((720 - COALESCE(SUM(dt.DOWNTIME_HOURS), 0)) / 720 * 100, 2)
    END as UPTIME_PERCENTAGE,
    -- Revenue protection (what we saved by quick fixes)
    ROUND(d.HOURLY_AD_REVENUE_USD * 720, 2) as POTENTIAL_MONTHLY_REVENUE,
    -- Actual revenue accounts for current status
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 0
        WHEN d.STATUS = 'DEGRADED' THEN ROUND(d.HOURLY_AD_REVENUE_USD * 360, 2)  -- 50% capacity
        ELSE ROUND(d.HOURLY_AD_REVENUE_USD * (720 - COALESCE(SUM(dt.DOWNTIME_HOURS), 0)), 2)
    END as ACTUAL_MONTHLY_REVENUE
FROM DEVICE_INVENTORY d
LEFT JOIN DEVICE_DOWNTIME dt ON d.DEVICE_ID = dt.DEVICE_ID
    AND dt.DOWNTIME_START >= (SELECT REFERENCE_MONTH_START FROM V_DEMO_REFERENCE_TIME)
GROUP BY d.DEVICE_ID, d.FACILITY_NAME, d.FACILITY_TYPE, d.LOCATION_CITY, d.LOCATION_STATE,
         d.STATUS, d.HOURLY_AD_REVENUE_USD, d.MONTHLY_IMPRESSIONS;

-- ============================================================================
-- CUSTOMER SATISFACTION VIEW
-- Aggregates provider feedback for analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_CUSTOMER_SATISFACTION AS
SELECT 
    -- Use device inventory facility name as source of truth (avoids nulls)
    COALESCE(f.FACILITY_NAME, d.FACILITY_NAME, 'Unknown Facility') as FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    f.DEVICE_ID,
    d.STATUS as DEVICE_STATUS,
    -- Satisfaction metrics
    ROUND(AVG(f.NPS_SCORE), 1) as AVG_NPS_SCORE,
    ROUND(AVG(f.SATISFACTION_RATING), 1) as AVG_SATISFACTION,
    ROUND(AVG(f.RESPONSE_TIME_RATING), 1) as AVG_RESPONSE_TIME_RATING,
    ROUND(AVG(f.DEVICE_RELIABILITY_RATING), 1) as AVG_RELIABILITY_RATING,
    -- Feedback counts
    COUNT(*) as TOTAL_FEEDBACK_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) as POSITIVE_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'NEUTRAL' THEN 1 ELSE 0 END) as NEUTRAL_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) as NEGATIVE_COUNT,
    SUM(CASE WHEN f.FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) as FOLLOW_UPS_REQUIRED,
    -- Latest feedback
    MAX(f.FEEDBACK_DATE) as LAST_FEEDBACK_DATE,
    -- NPS category
    CASE 
        WHEN AVG(f.NPS_SCORE) >= 9 THEN 'PROMOTER'
        WHEN AVG(f.NPS_SCORE) >= 7 THEN 'PASSIVE'
        ELSE 'DETRACTOR'
    END as NPS_CATEGORY
FROM PROVIDER_FEEDBACK f
JOIN DEVICE_INVENTORY d ON f.DEVICE_ID = d.DEVICE_ID
WHERE f.FACILITY_NAME IS NOT NULL  -- Filter out any null facility names
GROUP BY COALESCE(f.FACILITY_NAME, d.FACILITY_NAME, 'Unknown Facility'), 
         d.FACILITY_TYPE, d.LOCATION_CITY, d.LOCATION_STATE, 
         f.DEVICE_ID, d.STATUS;

-- ============================================================================
-- TECHNICIANS TABLE
-- Field technicians available for dispatch
-- ============================================================================
CREATE OR REPLACE TABLE TECHNICIANS (
    TECHNICIAN_ID VARCHAR(20) PRIMARY KEY,
    TECHNICIAN_NAME VARCHAR(100),
    EMAIL VARCHAR(100),
    PHONE VARCHAR(20),
    REGION VARCHAR(50),  -- Midwest, Northeast, etc.
    COVERAGE_STATES ARRAY,  -- States they cover
    SPECIALIZATION VARCHAR(50),  -- Hardware, Software, Network
    CERTIFICATION_LEVEL VARCHAR(20),  -- Junior, Senior, Lead
    CURRENT_STATUS VARCHAR(20) DEFAULT 'AVAILABLE',  -- AVAILABLE, ON_CALL, DISPATCHED, OFF_DUTY
    CURRENT_LOCATION VARCHAR(100),
    AVG_RATING FLOAT DEFAULT 4.5,
    TOTAL_JOBS_COMPLETED INT DEFAULT 0
);

-- Insert sample technicians
-- Note: Using SELECT with UNION ALL because VALUES clause doesn't support ARRAY_CONSTRUCT
INSERT INTO TECHNICIANS 
SELECT 'TECH-001', 'Marcus Johnson', 'marcus.johnson@deviceops.example.com', '312-555-0101', 'Midwest', ARRAY_CONSTRUCT('IL', 'WI'), 'Hardware', 'Lead', 'AVAILABLE', 'Chicago, IL', 4.8, 156
UNION ALL SELECT 'TECH-002', 'Sarah Chen', 'sarah.chen@deviceops.example.com', '312-555-0102', 'Midwest', ARRAY_CONSTRUCT('IL', 'IN'), 'Software', 'Senior', 'DISPATCHED', 'Indianapolis, IN', 4.9, 142
UNION ALL SELECT 'TECH-003', 'David Martinez', 'david.martinez@deviceops.example.com', '614-555-0103', 'Midwest', ARRAY_CONSTRUCT('OH', 'MI'), 'Hardware', 'Senior', 'AVAILABLE', 'Columbus, OH', 4.7, 128
UNION ALL SELECT 'TECH-004', 'Emily Williams', 'emily.williams@deviceops.example.com', '313-555-0104', 'Midwest', ARRAY_CONSTRUCT('MI', 'OH'), 'Network', 'Senior', 'ON_CALL', 'Detroit, MI', 4.6, 98
UNION ALL SELECT 'TECH-005', 'James Thompson', 'james.thompson@deviceops.example.com', '414-555-0105', 'Midwest', ARRAY_CONSTRUCT('WI', 'MN'), 'Hardware', 'Junior', 'AVAILABLE', 'Milwaukee, WI', 4.4, 45
UNION ALL SELECT 'TECH-006', 'Lisa Anderson', 'lisa.anderson@deviceops.example.com', '612-555-0106', 'Midwest', ARRAY_CONSTRUCT('MN', 'WI'), 'Software', 'Lead', 'AVAILABLE', 'Minneapolis, MN', 4.9, 189;

-- ============================================================================
-- WORK ORDERS TABLE
-- Maintenance work orders for operations and technicians
-- ============================================================================
CREATE OR REPLACE TABLE WORK_ORDERS (
    WORK_ORDER_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SCHEDULED_DATE DATE,
    SCHEDULED_TIME_WINDOW VARCHAR(20),  -- MORNING, AFTERNOON, EVENING
    PRIORITY VARCHAR(20),  -- CRITICAL, HIGH, MEDIUM, LOW
    STATUS VARCHAR(30),  -- OPEN, ASSIGNED, IN_PROGRESS, PENDING_PARTS, COMPLETED, CANCELLED
    WORK_ORDER_TYPE VARCHAR(30),  -- PREDICTIVE, REACTIVE, PREVENTIVE, INSTALLATION
    SOURCE VARCHAR(30),  -- AI_PREDICTION, MANUAL, PROVIDER_REQUEST, SCHEDULED
    ISSUE_SUMMARY TEXT,
    AI_DIAGNOSIS TEXT,
    RECOMMENDED_ACTIONS TEXT,
    ASSIGNED_TECHNICIAN_ID VARCHAR(20),
    ESTIMATED_DURATION_MINS INT,
    ACTUAL_DURATION_MINS INT,
    PARTS_REQUIRED ARRAY,
    RESOLUTION_NOTES TEXT,
    CUSTOMER_NOTIFIED BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_device_wo FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID),
    CONSTRAINT fk_tech_wo FOREIGN KEY (ASSIGNED_TECHNICIAN_ID) REFERENCES TECHNICIANS(TECHNICIAN_ID)
);

-- Insert sample work orders (mix of statuses and types)
-- Note: Using SELECT with UNION ALL because VALUES clause doesn't support ARRAY_CONSTRUCT
INSERT INTO WORK_ORDERS (WORK_ORDER_ID, DEVICE_ID, CREATED_AT, SCHEDULED_DATE, SCHEDULED_TIME_WINDOW, 
                          PRIORITY, STATUS, WORK_ORDER_TYPE, SOURCE, ISSUE_SUMMARY, AI_DIAGNOSIS, 
                          RECOMMENDED_ACTIONS, ASSIGNED_TECHNICIAN_ID, ESTIMATED_DURATION_MINS, 
                          ACTUAL_DURATION_MINS, PARTS_REQUIRED, RESOLUTION_NOTES, CUSTOMER_NOTIFIED)
-- Critical/Open work orders (from AI predictions)
SELECT 'WO-2024-001', 'DEV-003', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'MORNING', 'CRITICAL', 'ASSIGNED', 'PREDICTIVE', 'AI_PREDICTION',
     'Device showing rising CPU temperature trend - failure predicted within 12 hours',
     'Telemetry analysis indicates thermal throttling. CPU temp increased 15°C over 24 hours. Fan may be failing or dust accumulation.',
     '1. Check/clean cooling fan\n2. Replace thermal paste\n3. Clear dust from vents\n4. Verify airflow around device',
     'TECH-001', 45, NULL, ARRAY_CONSTRUCT('Thermal Paste', 'Compressed Air'), NULL, TRUE
UNION ALL
SELECT 'WO-2024-002', 'DEV-008', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'AFTERNOON', 'HIGH', 'OPEN', 'PREDICTIVE', 'AI_PREDICTION',
     'Memory usage trending toward exhaustion - application instability expected',
     'Memory leak pattern detected. Usage increased from 65% to 92% over 48 hours. Likely application-level issue.',
     '1. Attempt remote service restart\n2. If fails, schedule on-site memory diagnostics\n3. May require application update',
     NULL, 30, NULL, NULL, NULL, FALSE
UNION ALL
SELECT 'WO-2024-003', 'DEV-005', DATEADD('day', -1, CURRENT_TIMESTAMP()), CURRENT_DATE(), 'MORNING', 'CRITICAL', 'IN_PROGRESS', 'REACTIVE', 'PROVIDER_REQUEST',
     'Device offline - facility reports no display for 2 hours',
     'Network connectivity lost. Last heartbeat 2 hours ago. Historical pattern: this facility has had 3 network issues in past 60 days.',
     '1. Check network cable and router\n2. Verify facility network is operational\n3. Test with alternate network connection\n4. Recommend facility network audit',
     'TECH-002', 60, NULL, ARRAY_CONSTRUCT('Ethernet Cable', 'USB Network Adapter'), NULL, TRUE
UNION ALL
-- Medium priority work orders
SELECT 'WO-2024-004', 'DEV-014', DATEADD('day', -2, CURRENT_TIMESTAMP()), DATEADD('day', 1, CURRENT_DATE()), 'AFTERNOON', 'MEDIUM', 'ASSIGNED', 'PREVENTIVE', 'SCHEDULED',
     'Preventive maintenance - device approaching 180 days since last service',
     'Routine maintenance due. Device has been stable but firmware is 2 versions behind.',
     '1. Update firmware to v3.2.2\n2. Clean screen and housing\n3. Check all connections\n4. Run full diagnostic',
     'TECH-003', 40, NULL, NULL, NULL, TRUE
UNION ALL
SELECT 'WO-2024-005', 'DEV-020', DATEADD('day', -1, CURRENT_TIMESTAMP()), DATEADD('day', 1, CURRENT_DATE()), 'MORNING', 'MEDIUM', 'ASSIGNED', 'PREDICTIVE', 'AI_PREDICTION',
     'Error rate increasing - 18 errors in past 24 hours',
     'Application errors correlating with memory pressure. Similar pattern preceded failure on DEV-008 last month.',
     '1. Clear application cache\n2. Restart all services\n3. Monitor for 24 hours\n4. Schedule follow-up if errors persist',
     'TECH-005', 25, NULL, NULL, NULL, FALSE
UNION ALL
-- Completed work orders (for history)
SELECT 'WO-2024-006', 'DEV-007', DATEADD('day', -5, CURRENT_TIMESTAMP()), DATEADD('day', -4, CURRENT_DATE()), 'AFTERNOON', 'LOW', 'COMPLETED', 'PREVENTIVE', 'SCHEDULED',
     'Scheduled firmware update and maintenance check',
     'Routine update. Device healthy, no issues detected.',
     'Standard firmware update procedure',
     'TECH-001', 30, 25, NULL, 'Firmware updated successfully to v3.2.2. All diagnostics passed. Device performing optimally.', TRUE
UNION ALL
SELECT 'WO-2024-007', 'DEV-012', DATEADD('day', -3, CURRENT_TIMESTAMP()), DATEADD('day', -2, CURRENT_DATE()), 'MORNING', 'HIGH', 'COMPLETED', 'REACTIVE', 'PROVIDER_REQUEST',
     'Display flickering reported by facility staff',
     'Display refresh rate misconfigured after power outage.',
     '1. Check display settings\n2. Recalibrate if needed\n3. Check power supply stability',
     'TECH-003', 45, 35, NULL, 'Reset display settings to factory defaults. Recalibrated touch screen. Issue resolved. Recommended UPS installation to facility.', TRUE
UNION ALL
SELECT 'WO-2024-008', 'DEV-019', DATEADD('day', -7, CURRENT_TIMESTAMP()), DATEADD('day', -6, CURRENT_DATE()), 'AFTERNOON', 'MEDIUM', 'COMPLETED', 'PREDICTIVE', 'AI_PREDICTION',
     'Disk usage at 88% - proactive cleanup recommended',
     'Log files consuming excessive space. Automated cleanup not running.',
     '1. Clear old logs\n2. Fix log rotation\n3. Verify automated cleanup scheduled',
     'TECH-006', 20, 15, NULL, 'Cleared 2.3GB of old logs. Fixed cron job for automated cleanup. Disk usage now at 52%.', TRUE;

-- ============================================================================
-- WORK ORDER VIEWS FOR OPERATIONS
-- ============================================================================

-- Active work orders view for operations dashboard
CREATE OR REPLACE VIEW V_ACTIVE_WORK_ORDERS AS
SELECT 
    wo.WORK_ORDER_ID,
    wo.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    wo.PRIORITY,
    wo.STATUS,
    wo.WORK_ORDER_TYPE,
    wo.SOURCE,
    wo.ISSUE_SUMMARY,
    wo.AI_DIAGNOSIS,
    wo.RECOMMENDED_ACTIONS,
    wo.SCHEDULED_DATE,
    wo.SCHEDULED_TIME_WINDOW,
    wo.ASSIGNED_TECHNICIAN_ID,
    t.TECHNICIAN_NAME,
    t.PHONE as TECHNICIAN_PHONE,
    t.CURRENT_STATUS as TECHNICIAN_STATUS,
    wo.ESTIMATED_DURATION_MINS,
    wo.CUSTOMER_NOTIFIED,
    wo.CREATED_AT,
    DATEDIFF('hour', wo.CREATED_AT, (SELECT REFERENCE_TIMESTAMP FROM V_DEMO_REFERENCE_TIME)) as HOURS_SINCE_CREATED,
    -- Urgency score for prioritization
    CASE 
        WHEN wo.PRIORITY = 'CRITICAL' AND wo.STATUS = 'OPEN' THEN 100
        WHEN wo.PRIORITY = 'CRITICAL' THEN 90
        WHEN wo.PRIORITY = 'HIGH' AND wo.STATUS = 'OPEN' THEN 80
        WHEN wo.PRIORITY = 'HIGH' THEN 70
        WHEN wo.PRIORITY = 'MEDIUM' THEN 50
        ELSE 30
    END as URGENCY_SCORE
FROM WORK_ORDERS wo
JOIN DEVICE_INVENTORY d ON wo.DEVICE_ID = d.DEVICE_ID
LEFT JOIN TECHNICIANS t ON wo.ASSIGNED_TECHNICIAN_ID = t.TECHNICIAN_ID
WHERE wo.STATUS NOT IN ('COMPLETED', 'CANCELLED')
ORDER BY URGENCY_SCORE DESC, wo.CREATED_AT ASC;

-- Technician workload view
CREATE OR REPLACE VIEW V_TECHNICIAN_WORKLOAD AS
SELECT 
    t.TECHNICIAN_ID,
    t.TECHNICIAN_NAME,
    t.CURRENT_STATUS,
    t.REGION,
    t.SPECIALIZATION,
    t.CERTIFICATION_LEVEL,
    t.AVG_RATING,
    t.CURRENT_LOCATION,
    COUNT(wo.WORK_ORDER_ID) as ASSIGNED_WORK_ORDERS,
    SUM(CASE WHEN wo.STATUS = 'IN_PROGRESS' THEN 1 ELSE 0 END) as IN_PROGRESS_COUNT,
    SUM(CASE WHEN wo.PRIORITY = 'CRITICAL' THEN 1 ELSE 0 END) as CRITICAL_COUNT,
    SUM(COALESCE(wo.ESTIMATED_DURATION_MINS, 0)) as TOTAL_ESTIMATED_MINS
FROM TECHNICIANS t
LEFT JOIN WORK_ORDERS wo ON t.TECHNICIAN_ID = wo.ASSIGNED_TECHNICIAN_ID 
    AND wo.STATUS NOT IN ('COMPLETED', 'CANCELLED')
GROUP BY t.TECHNICIAN_ID, t.TECHNICIAN_NAME, t.CURRENT_STATUS, t.REGION, 
         t.SPECIALIZATION, t.CERTIFICATION_LEVEL, t.AVG_RATING, t.CURRENT_LOCATION;

-- ============================================================================
-- DEVICE HEALTH SUMMARY VIEW
-- Combines device inventory with latest telemetry for health scoring
-- ============================================================================
CREATE OR REPLACE VIEW V_DEVICE_HEALTH_SUMMARY AS
WITH latest_telemetry AS (
    SELECT 
        DEVICE_ID,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        DISK_USAGE_PCT,
        NETWORK_LATENCY_MS,
        UPTIME_HOURS,
        ERROR_COUNT,
        LAST_HEARTBEAT,
        TIMESTAMP as TELEMETRY_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP DESC) as rn
    FROM DEVICE_TELEMETRY
)
SELECT 
    d.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.INSTALL_DATE,
    d.WARRANTY_EXPIRY,
    d.LAST_MAINTENANCE_DATE,
    DATEDIFF('day', d.LAST_MAINTENANCE_DATE, (SELECT REFERENCE_DATE FROM V_DEMO_REFERENCE_TIME)) as DAYS_SINCE_MAINTENANCE,
    d.FIRMWARE_VERSION,
    d.STATUS,
    d.HOURLY_AD_REVENUE_USD,
    d.MONTHLY_IMPRESSIONS,
    t.CPU_TEMP_CELSIUS,
    -- Cap percentages at 100% for display (handles any bad legacy data)
    LEAST(100, t.CPU_USAGE_PCT) as CPU_USAGE_PCT,
    LEAST(100, t.MEMORY_USAGE_PCT) as MEMORY_USAGE_PCT,
    LEAST(100, t.DISK_USAGE_PCT) as DISK_USAGE_PCT,
    t.NETWORK_LATENCY_MS,
    t.UPTIME_HOURS,
    t.ERROR_COUNT,
    t.LAST_HEARTBEAT,
    t.TELEMETRY_TIMESTAMP,
    -- Health score calculation (DEMO-OPTIMIZED: Lenient thresholds for healthy fleet)
    GREATEST(0, 
        100 
        - CASE WHEN t.CPU_TEMP_CELSIUS > 75 THEN 25 WHEN t.CPU_TEMP_CELSIUS > 65 THEN 10 ELSE 0 END
        - CASE WHEN t.CPU_USAGE_PCT > 95 THEN 20 WHEN t.CPU_USAGE_PCT > 85 THEN 8 ELSE 0 END
        - CASE WHEN t.MEMORY_USAGE_PCT > 95 THEN 20 WHEN t.MEMORY_USAGE_PCT > 85 THEN 8 ELSE 0 END
        - CASE WHEN t.NETWORK_LATENCY_MS > 300 THEN 10 WHEN t.NETWORK_LATENCY_MS > 150 THEN 5 ELSE 0 END
        - CASE WHEN t.ERROR_COUNT > 15 THEN 15 WHEN t.ERROR_COUNT > 8 THEN 8 ELSE 0 END
        - CASE WHEN d.STATUS = 'OFFLINE' THEN 30 WHEN d.STATUS = 'DEGRADED' THEN 10 ELSE 0 END
    )::INT as HEALTH_SCORE,
    -- Risk classification (DEMO-OPTIMIZED: Only flag truly problematic devices)
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 'CRITICAL'
        WHEN d.STATUS = 'DEGRADED' AND (t.CPU_TEMP_CELSIUS > 65 OR t.CPU_USAGE_PCT > 80) THEN 'HIGH'
        WHEN d.STATUS = 'DEGRADED' THEN 'MEDIUM'
        WHEN t.CPU_TEMP_CELSIUS > 75 OR t.CPU_USAGE_PCT > 95 OR t.MEMORY_USAGE_PCT > 95 THEN 'MEDIUM'
        ELSE 'LOW'
    END as RISK_LEVEL,
    -- Primary issue
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 'Device Offline'
        WHEN d.STATUS = 'DEGRADED' AND t.CPU_TEMP_CELSIUS > 65 THEN 'Overheating'
        WHEN d.STATUS = 'DEGRADED' AND t.CPU_USAGE_PCT > 80 THEN 'High CPU Usage'
        WHEN d.STATUS = 'DEGRADED' THEN 'Degraded Performance'
        WHEN t.CPU_TEMP_CELSIUS > 75 THEN 'Overheating'
        WHEN t.CPU_USAGE_PCT > 95 THEN 'High CPU Usage'
        WHEN t.MEMORY_USAGE_PCT > 95 THEN 'Memory Exhaustion'
        WHEN t.NETWORK_LATENCY_MS > 300 THEN 'Network Issues'
        WHEN t.ERROR_COUNT > 15 THEN 'High Error Rate'
        ELSE 'Healthy'
    END as PRIMARY_ISSUE
FROM DEVICE_INVENTORY d
LEFT JOIN latest_telemetry t ON d.DEVICE_ID = t.DEVICE_ID AND t.rn = 1;

-- ============================================================================
-- MAINTENANCE ANALYTICS VIEW
-- Historical maintenance data with calculated metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_MAINTENANCE_ANALYTICS AS
SELECT 
    m.TICKET_ID,
    m.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    m.CREATED_AT,
    m.RESOLVED_AT,
    DATE_TRUNC('month', m.CREATED_AT) as TICKET_MONTH,
    DATE_TRUNC('week', m.CREATED_AT) as TICKET_WEEK,
    m.ISSUE_TYPE,
    m.ISSUE_DESCRIPTION,
    m.RESOLUTION_TYPE,
    m.RESOLUTION_NOTES,
    m.TECHNICIAN_ID,
    m.COST_USD,
    DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT) as RESOLUTION_TIME_MINS,
    CASE 
        WHEN m.RESOLUTION_TYPE = 'REMOTE_FIX' THEN 185  -- Avg dispatch cost saved
        ELSE 0 
    END as COST_SAVINGS_USD,
    CASE 
        WHEN m.RESOLUTION_TYPE = 'REMOTE_FIX' THEN TRUE
        ELSE FALSE
    END as WAS_REMOTE_FIX
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID;

-- ============================================================================
-- EXECUTIVE DASHBOARD VIEW
-- Single-pane-of-glass for C-suite executives
-- NOTE: References to V_FAILURE_PREDICTIONS and V_PREDICTION_ACCURACY_ANALYSIS 
--       require running script 05 first, or these will show NULL
-- ============================================================================
CREATE OR REPLACE VIEW V_EXECUTIVE_DASHBOARD AS
SELECT 
    -- Current timestamp for dashboard refresh (uses latest telemetry timestamp)
    (SELECT REFERENCE_TIMESTAMP FROM V_DEMO_REFERENCE_TIME) as DASHBOARD_REFRESH_TIME,
    
    -- ===== FLEET HEALTH METRICS =====
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as TOTAL_FLEET_SIZE,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as DEVICES_ONLINE,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'DEGRADED') as DEVICES_DEGRADED,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'OFFLINE') as DEVICES_OFFLINE,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM DEVICE_INVENTORY), 0), 1) 
     FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as FLEET_UPTIME_PCT,
    (SELECT ROUND(AVG(HEALTH_SCORE), 1) FROM V_DEVICE_HEALTH_SUMMARY) as AVG_FLEET_HEALTH_SCORE,
    
    -- ===== PREDICTIVE MAINTENANCE METRICS =====
    -- Note: These will show actual values after running script 05_predictive_simulation.sql
    -- For now, we estimate based on device health scores
    (SELECT COUNT(*) FROM V_DEVICE_HEALTH_SUMMARY WHERE RISK_LEVEL IN ('HIGH', 'CRITICAL')) as HIGH_RISK_DEVICES,
    (SELECT COUNT(*) FROM V_DEVICE_HEALTH_SUMMARY WHERE RISK_LEVEL = 'CRITICAL') as PREDICTED_FAILURES_48H,
    -- Placeholder accuracy based on historical remote fix success rate
    (SELECT ROUND(COUNT(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE ISSUE_TYPE IN ('DISPLAY_FREEZE', 'HIGH_CPU', 'MEMORY_LEAK')) as PREDICTION_ACCURACY_PCT,
    
    -- ===== COST METRICS =====
    (SELECT COALESCE(SUM(COST_SAVINGS_USD), 0) FROM V_MAINTENANCE_ANALYTICS) as TOTAL_COST_SAVINGS_USD,
    (SELECT COALESCE(SUM(COST_USD), 0) FROM MAINTENANCE_HISTORY) as TOTAL_MAINTENANCE_SPEND_USD,
    (SELECT ROUND(SUM(COST_SAVINGS_USD) / NULLIF(SUM(COST_USD) + SUM(COST_SAVINGS_USD), 0) * 100, 1) 
     FROM V_MAINTENANCE_ANALYTICS) as COST_AVOIDANCE_RATE_PCT,
    
    -- ===== OPERATIONAL EFFICIENCY =====
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as TOTAL_REMOTE_FIXES,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'FIELD_DISPATCH') as TOTAL_FIELD_DISPATCHES,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_RESOLUTION_RATE_PCT,
    (SELECT ROUND(AVG(RESOLUTION_TIME_MINS), 0) FROM V_MAINTENANCE_ANALYTICS) as AVG_MTTR_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN RESOLUTION_TIME_MINS END), 0) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_REMOTE_MTTR_MINS,
    
    -- ===== REVENUE IMPACT =====
    (SELECT COALESCE(SUM(REVENUE_LOSS_USD), 0) FROM DEVICE_DOWNTIME) as TOTAL_REVENUE_LOSS_USD,
    (SELECT COALESCE(SUM(DOWNTIME_HOURS), 0) FROM DEVICE_DOWNTIME) as TOTAL_DOWNTIME_HOURS,
    (SELECT ROUND(SUM(HOURLY_AD_REVENUE_USD * 720), 0) FROM DEVICE_INVENTORY) as MONTHLY_REVENUE_POTENTIAL_USD,
    (SELECT ROUND(AVG(UPTIME_PERCENTAGE), 2) FROM V_REVENUE_IMPACT) as AVG_UPTIME_PCT,
    
    -- ===== CUSTOMER SATISFACTION =====
    (SELECT ROUND(AVG(NPS_SCORE), 1) FROM PROVIDER_FEEDBACK) as NPS_SCORE,
    (SELECT ROUND(AVG(SATISFACTION_RATING), 2) FROM PROVIDER_FEEDBACK) as AVG_SATISFACTION_RATING,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PROMOTERS,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as DETRACTORS,
    (SELECT SUM(CASE WHEN FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PENDING_FOLLOW_UPS,
    
    -- ===== WORK ORDER STATUS =====
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE STATUS NOT IN ('COMPLETED', 'CANCELLED')) as ACTIVE_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE STATUS = 'OPEN') as UNASSIGNED_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE PRIORITY = 'CRITICAL' AND STATUS NOT IN ('COMPLETED', 'CANCELLED')) as CRITICAL_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE SOURCE = 'AI_PREDICTION' AND STATUS NOT IN ('COMPLETED', 'CANCELLED')) as AI_GENERATED_WORK_ORDERS;

-- ============================================================================
-- BUSINESS IMPACT SUMMARY VIEW
-- Executive-level KPIs combining all metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_BUSINESS_IMPACT_SUMMARY AS
SELECT 
    -- Fleet metrics
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as TOTAL_DEVICES,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as ONLINE_DEVICES,
    
    -- Cost savings
    (SELECT COALESCE(SUM(COST_SAVINGS_USD), 0) FROM V_MAINTENANCE_ANALYTICS) as TOTAL_COST_SAVINGS_USD,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIXES,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIX_RATE_PCT,
    
    -- Revenue protection
    (SELECT COALESCE(SUM(REVENUE_LOSS_USD), 0) FROM DEVICE_DOWNTIME) as TOTAL_REVENUE_LOSS_USD,
    (SELECT COALESCE(SUM(DOWNTIME_HOURS), 0) FROM DEVICE_DOWNTIME) as TOTAL_DOWNTIME_HOURS,
    (SELECT COUNT(*) FROM DEVICE_DOWNTIME) as DOWNTIME_INCIDENTS,
    (SELECT ROUND(SUM(HOURLY_AD_REVENUE_USD * 720), 2) FROM DEVICE_INVENTORY) as POTENTIAL_MONTHLY_REVENUE_USD,
    
    -- Customer satisfaction
    (SELECT ROUND(AVG(NPS_SCORE), 1) FROM PROVIDER_FEEDBACK) as AVG_NPS_SCORE,
    (SELECT ROUND(AVG(SATISFACTION_RATING), 1) FROM PROVIDER_FEEDBACK) as AVG_SATISFACTION_RATING,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as POSITIVE_FEEDBACK_COUNT,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as NEGATIVE_FEEDBACK_COUNT,
    (SELECT SUM(CASE WHEN FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PENDING_FOLLOW_UPS,
    
    -- MTTR
    (SELECT ROUND(AVG(RESOLUTION_TIME_MINS), 1) FROM V_MAINTENANCE_ANALYTICS) as AVG_RESOLUTION_TIME_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN RESOLUTION_TIME_MINS END), 1) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_REMOTE_FIX_TIME_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'FIELD_DISPATCH' THEN RESOLUTION_TIME_MINS END), 1) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_DISPATCH_TIME_MINS;

-- ============================================================================
-- ROI AND COST ANALYSIS VIEW
-- Annual cost baseline and projected savings for executive ROI questions
-- ============================================================================
CREATE OR REPLACE VIEW V_ROI_ANALYSIS AS
SELECT 
    -- Fleet scale
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as DEMO_DEVICE_COUNT,
    500000 as PRODUCTION_DEVICE_COUNT,
    
    -- Cost assumptions (industry standard)
    185.00 as AVG_FIELD_DISPATCH_COST_USD,
    25.00 as AVG_REMOTE_FIX_COST_USD,
    
    -- Current metrics (from maintenance data)
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY) as TOTAL_MAINTENANCE_TICKETS,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'FIELD_DISPATCH') as FIELD_DISPATCHES,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIXES,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIX_RATE_PCT,
    
    -- Demo-scale annual projection (100 devices, ~24 tickets/month = ~288/year)
    ROUND(288 * 185.00, 2) as DEMO_ANNUAL_DISPATCH_COST_USD,
    
    -- Production-scale annual projection (500,000 devices)
    -- Assuming 2 issues per device per year = 1,000,000 potential dispatches
    ROUND(1000000 * 185.00, 2) as PRODUCTION_ANNUAL_DISPATCH_COST_USD,
    
    -- Savings calculation with 60% remote fix rate
    ROUND(1000000 * 0.60 * (185.00 - 25.00), 2) as PROJECTED_ANNUAL_SAVINGS_USD,
    
    -- Cost savings already achieved (from actual data)
    (SELECT COALESCE(SUM(COST_SAVINGS_USD), 0) FROM V_MAINTENANCE_ANALYTICS) as ACTUAL_SAVINGS_TO_DATE_USD,
    
    -- Avoided dispatches
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as DISPATCHES_AVOIDED,
    ROUND(1000000 * 0.60, 0) as PROJECTED_ANNUAL_DISPATCHES_AVOIDED;

-- Verify data loaded correctly
SELECT 'DEVICE_INVENTORY' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM DEVICE_INVENTORY
UNION ALL
SELECT 'DEVICE_TELEMETRY', COUNT(*) FROM DEVICE_TELEMETRY
UNION ALL
SELECT 'MAINTENANCE_HISTORY', COUNT(*) FROM MAINTENANCE_HISTORY
UNION ALL
SELECT 'TROUBLESHOOTING_KB', COUNT(*) FROM TROUBLESHOOTING_KB
UNION ALL
SELECT 'DEVICE_DOWNTIME', COUNT(*) FROM DEVICE_DOWNTIME
UNION ALL
SELECT 'PROVIDER_FEEDBACK', COUNT(*) FROM PROVIDER_FEEDBACK
UNION ALL
SELECT 'TECHNICIANS', COUNT(*) FROM TECHNICIANS
UNION ALL
SELECT 'WORK_ORDERS', COUNT(*) FROM WORK_ORDERS;

-- ============================================================================
-- SIMULATED EXTERNAL SERVICE INTEGRATION
-- This demonstrates how Cortex Agents can trigger external actions
-- In production, these would be actual API calls via External Functions
-- For demo purposes, we log what WOULD be sent to external systems
-- ============================================================================

-- Table to log simulated external API calls
CREATE OR REPLACE TABLE EXTERNAL_ACTION_LOG (
    ACTION_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    ACTION_TYPE VARCHAR(50),      -- DEVICE_COMMAND, ALERT, WORK_ORDER, NOTIFICATION
    TARGET_SYSTEM VARCHAR(100),   -- Device Management API, ServiceNow, Slack, PagerDuty
    TARGET_DEVICE_ID VARCHAR(20),
    COMMAND VARCHAR(100),         -- RESTART_SERVICES, CLEAR_CACHE, UPDATE_FIRMWARE, etc.
    PAYLOAD VARIANT,              -- Full JSON payload that would be sent
    STATUS VARCHAR(20) DEFAULT 'SIMULATED',  -- SIMULATED, PENDING, SENT, FAILED
    INITIATED_BY VARCHAR(100),    -- AI_AGENT, SCHEDULED_TASK, MANUAL
    NOTES TEXT
);

-- Stored procedure to simulate sending a device command
-- In production, this would call an External Function to hit the device management API
CREATE OR REPLACE PROCEDURE SEND_DEVICE_COMMAND(
    DEVICE_ID VARCHAR,
    COMMAND VARCHAR,
    REASON VARCHAR
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    action_id VARCHAR;
    device_info VARIANT;
    result VARIANT;
BEGIN
    -- Get device information
    SELECT OBJECT_CONSTRUCT(
        'device_id', DEVICE_ID,
        'facility', FACILITY_NAME,
        'location', CONCAT(LOCATION_CITY, ', ', LOCATION_STATE),
        'model', DEVICE_MODEL,
        'current_status', STATUS
    ) INTO device_info
    FROM DEVICE_INVENTORY
    WHERE DEVICE_ID = :DEVICE_ID;
    
    -- Log the simulated action
    INSERT INTO EXTERNAL_ACTION_LOG (
        ACTION_TYPE, TARGET_SYSTEM, TARGET_DEVICE_ID, COMMAND, PAYLOAD, INITIATED_BY, NOTES
    )
    SELECT 
        'DEVICE_COMMAND',
        'Device Management API',
        :DEVICE_ID,
        :COMMAND,
        OBJECT_CONSTRUCT(
            'api_endpoint', 'https://api.deviceops.example.com/v1/devices/' || :DEVICE_ID || '/command',
            'method', 'POST',
            'headers', OBJECT_CONSTRUCT('Authorization', 'Bearer ***', 'Content-Type', 'application/json'),
            'body', OBJECT_CONSTRUCT(
                'device_id', :DEVICE_ID,
                'command', :COMMAND,
                'reason', :REASON,
                'initiated_by', 'CORTEX_AGENT',
                'timestamp', CURRENT_TIMESTAMP()
            ),
            'device_info', :device_info
        ),
        'AI_AGENT',
        'Simulated API call - In production, this would send command to device via External Function';
    
    -- Return what would be sent
    result := OBJECT_CONSTRUCT(
        'status', 'SIMULATED',
        'message', 'Command logged successfully. In production, this would trigger: ' || :COMMAND || ' on device ' || :DEVICE_ID,
        'device_id', :DEVICE_ID,
        'command', :COMMAND,
        'reason', :REASON,
        'api_endpoint', 'https://api.deviceops.example.com/v1/devices/' || :DEVICE_ID || '/command',
        'note', 'To implement in production: Create External Function connected to Device Management API'
    );
    
    RETURN result;
END;
$$;

-- Stored procedure to simulate sending an alert/notification
CREATE OR REPLACE PROCEDURE SEND_ALERT(
    ALERT_TYPE VARCHAR,      -- SLACK, PAGERDUTY, EMAIL, SMS
    RECIPIENT VARCHAR,       -- Channel name, email, phone
    DEVICE_ID VARCHAR,
    MESSAGE VARCHAR
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    result VARIANT;
BEGIN
    INSERT INTO EXTERNAL_ACTION_LOG (
        ACTION_TYPE, TARGET_SYSTEM, TARGET_DEVICE_ID, COMMAND, PAYLOAD, INITIATED_BY, NOTES
    )
    SELECT
        'ALERT',
        :ALERT_TYPE,
        :DEVICE_ID,
        'SEND_NOTIFICATION',
        OBJECT_CONSTRUCT(
            'alert_type', :ALERT_TYPE,
            'recipient', :RECIPIENT,
            'device_id', :DEVICE_ID,
            'message', :MESSAGE,
            'timestamp', CURRENT_TIMESTAMP(),
            'priority', 'HIGH'
        ),
        'AI_AGENT',
        'Simulated notification - Would send to ' || :ALERT_TYPE || ' via External Function';
    
    result := OBJECT_CONSTRUCT(
        'status', 'SIMULATED',
        'message', 'Alert would be sent to ' || :RECIPIENT || ' via ' || :ALERT_TYPE,
        'device_id', :DEVICE_ID
    );
    
    RETURN result;
END;
$$;

-- Stored procedure to simulate creating a ServiceNow incident
CREATE OR REPLACE PROCEDURE CREATE_SERVICENOW_INCIDENT(
    DEVICE_ID VARCHAR,
    PRIORITY VARCHAR,
    DESCRIPTION VARCHAR
)
RETURNS VARIANT
LANGUAGE SQL
AS
$$
DECLARE
    incident_number VARCHAR;
    result VARIANT;
BEGIN
    incident_number := 'INC' || TO_CHAR(CURRENT_TIMESTAMP(), 'YYYYMMDDHH24MISS');
    
    INSERT INTO EXTERNAL_ACTION_LOG (
        ACTION_TYPE, TARGET_SYSTEM, TARGET_DEVICE_ID, COMMAND, PAYLOAD, INITIATED_BY, NOTES
    )
    SELECT
        'WORK_ORDER',
        'ServiceNow',
        :DEVICE_ID,
        'CREATE_INCIDENT',
        OBJECT_CONSTRUCT(
            'incident_number', :incident_number,
            'api_endpoint', 'https://deviceops.service-now.com/api/now/table/incident',
            'method', 'POST',
            'body', OBJECT_CONSTRUCT(
                'short_description', 'Device ' || :DEVICE_ID || ' requires attention',
                'description', :DESCRIPTION,
                'priority', :PRIORITY,
                'category', 'Hardware',
                'subcategory', 'HealthScreen Device',
                'assignment_group', 'Field Services',
                'caller_id', 'AI_AGENT'
            )
        ),
        'AI_AGENT',
        'Simulated ServiceNow incident creation - ' || :incident_number;
    
    result := OBJECT_CONSTRUCT(
        'status', 'SIMULATED',
        'incident_number', :incident_number,
        'message', 'ServiceNow incident would be created via Native App or API integration',
        'device_id', :DEVICE_ID,
        'priority', :PRIORITY
    );
    
    RETURN result;
END;
$$;

-- View to show recent external actions (for demo)
CREATE OR REPLACE VIEW V_RECENT_EXTERNAL_ACTIONS AS
SELECT 
    TIMESTAMP,
    ACTION_TYPE,
    TARGET_SYSTEM,
    TARGET_DEVICE_ID as DEVICE_ID,
    COMMAND,
    STATUS,
    INITIATED_BY,
    PAYLOAD:api_endpoint::VARCHAR as API_ENDPOINT,
    NOTES
FROM EXTERNAL_ACTION_LOG
ORDER BY TIMESTAMP DESC
LIMIT 20;

-- Insert some sample historical actions to show the pattern
INSERT INTO EXTERNAL_ACTION_LOG (TIMESTAMP, ACTION_TYPE, TARGET_SYSTEM, TARGET_DEVICE_ID, COMMAND, PAYLOAD, STATUS, INITIATED_BY, NOTES)
SELECT DATEADD('hour', -2, CURRENT_TIMESTAMP()), 'DEVICE_COMMAND', 'Device Management API', 'DEV-003', 'RESTART_SERVICES', 
    PARSE_JSON('{"api_endpoint": "https://api.deviceops.example.com/v1/devices/DEV-003/command", "command": "RESTART_SERVICES"}'),
    'SIMULATED', 'AI_AGENT', 'High CPU detected - AI agent initiated remote restart'
UNION ALL
SELECT DATEADD('hour', -1, CURRENT_TIMESTAMP()), 'ALERT', 'Slack', 'DEV-005', 'SEND_NOTIFICATION',
    PARSE_JSON('{"channel": "#device-alerts", "message": "DEV-005 at Springfield showing degraded status"}'),
    'SIMULATED', 'AI_AGENT', 'Proactive alert sent to operations team'
UNION ALL
SELECT DATEADD('minute', -30, CURRENT_TIMESTAMP()), 'WORK_ORDER', 'ServiceNow', 'DEV-008', 'CREATE_INCIDENT',
    PARSE_JSON('{"incident_number": "INC20241213143000", "priority": "HIGH", "description": "Overheating detected"}'),
    'SIMULATED', 'AI_AGENT', 'Work order created for field dispatch';

-- Grant execute on procedures
GRANT USAGE ON PROCEDURE SEND_DEVICE_COMMAND(VARCHAR, VARCHAR, VARCHAR) TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON PROCEDURE SEND_ALERT(VARCHAR, VARCHAR, VARCHAR, VARCHAR) TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON PROCEDURE CREATE_SERVICENOW_INCIDENT(VARCHAR, VARCHAR, VARCHAR) TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- STUB TABLE: T_ML_PREDICTIONS
-- This stub table allows the semantic views to be created before running the
-- ML notebook. The notebook will DROP and REPLACE this with real predictions.
-- ============================================================================
CREATE OR REPLACE TABLE T_ML_PREDICTIONS (
    DEVICE_ID VARCHAR(20) PRIMARY KEY,
    STATUS VARCHAR(20),
    DEVICE_TYPE VARCHAR(50),
    NETWORK_TYPE VARCHAR(20),
    WILL_FAIL_48H NUMBER(1,0),
    PREDICTED_HOURS_TO_FAILURE FLOAT,
    FAILURE_PROBABILITY FLOAT,
    RISK_LEVEL VARCHAR(20),
    PRIMARY_RISK_FACTOR VARCHAR(100),
    PREDICTION_TIMESTAMP TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    MODEL_VERSION VARCHAR(20) DEFAULT 'STUB'
);

-- Insert stub predictions based on device health (will be replaced by ML notebook)
INSERT INTO T_ML_PREDICTIONS (DEVICE_ID, STATUS, DEVICE_TYPE, NETWORK_TYPE, WILL_FAIL_48H, PREDICTED_HOURS_TO_FAILURE, FAILURE_PROBABILITY, RISK_LEVEL, PRIMARY_RISK_FACTOR)
SELECT 
    DEVICE_ID,
    STATUS,
    DEVICE_MODEL as DEVICE_TYPE,
    NETWORK_TYPE,
    CASE WHEN STATUS = 'OFFLINE' OR STATUS = 'DEGRADED' THEN 1 ELSE 0 END as WILL_FAIL_48H,
    CASE 
        WHEN STATUS = 'OFFLINE' THEN 0
        WHEN STATUS = 'DEGRADED' THEN 24
        ELSE 168
    END as PREDICTED_HOURS_TO_FAILURE,
    CASE 
        WHEN STATUS = 'OFFLINE' THEN 0.95
        WHEN STATUS = 'DEGRADED' THEN 0.70
        ELSE 0.10
    END as FAILURE_PROBABILITY,
    CASE 
        WHEN STATUS = 'OFFLINE' THEN 'CRITICAL'
        WHEN STATUS = 'DEGRADED' THEN 'WARNING'
        ELSE 'HEALTHY'
    END as RISK_LEVEL,
    CASE 
        WHEN STATUS = 'OFFLINE' THEN 'Device currently offline'
        WHEN STATUS = 'DEGRADED' THEN 'Performance degradation detected'
        ELSE 'Normal operation'
    END as PRIMARY_RISK_FACTOR
FROM DEVICE_INVENTORY;

GRANT SELECT ON TABLE T_ML_PREDICTIONS TO ROLE SF_INTELLIGENCE_DEMO;
