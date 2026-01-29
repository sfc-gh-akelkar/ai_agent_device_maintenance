/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 3: Cortex Search Services
 * 
 * Creates Cortex Search services over:
 * - Troubleshooting knowledge base (diagnostic procedures)
 * - Maintenance history (past incidents and resolutions)
 * 
 * These enable RAG-based retrieval for the AI agent
 * 
 * Prerequisites: Run 01 and 02 scripts first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEVICE_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- PREPARE KNOWLEDGE BASE FOR CORTEX SEARCH
-- Combine all relevant text fields into a searchable document
-- ============================================================================
CREATE OR REPLACE TABLE TROUBLESHOOTING_KB_SEARCH AS
SELECT 
    KB_ID,
    ISSUE_CATEGORY,
    ISSUE_SYMPTOMS,
    DIAGNOSTIC_STEPS,
    REMOTE_FIX_PROCEDURE,
    REQUIRES_DISPATCH,
    ESTIMATED_REMOTE_FIX_TIME_MINS,
    SUCCESS_RATE_PCT,
    -- Combined searchable content
    CONCAT(
        'Issue Category: ', ISSUE_CATEGORY, '\n\n',
        'Symptoms: ', ISSUE_SYMPTOMS, '\n\n',
        'Diagnostic Steps: ', DIAGNOSTIC_STEPS, '\n\n',
        'Remote Fix Procedure: ', REMOTE_FIX_PROCEDURE, '\n\n',
        'Requires Field Dispatch: ', IFF(REQUIRES_DISPATCH, 'Yes - this issue typically requires a technician on-site', 'No - this can usually be fixed remotely'), '\n',
        'Estimated Fix Time: ', COALESCE(ESTIMATED_REMOTE_FIX_TIME_MINS::VARCHAR, 'N/A - Requires Dispatch'), ' minutes\n',
        'Historical Success Rate: ', SUCCESS_RATE_PCT::VARCHAR, '%'
    ) AS SEARCH_CONTENT
FROM TROUBLESHOOTING_KB;

-- ============================================================================
-- CREATE MAINTENANCE HISTORY SEARCH TABLE
-- Enable searching past incidents and resolutions
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_HISTORY_SEARCH AS
SELECT 
    m.TICKET_ID,
    m.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    m.ISSUE_TYPE,
    m.ISSUE_DESCRIPTION,
    m.RESOLUTION_TYPE,
    m.RESOLUTION_NOTES,
    m.COST_USD,
    m.CREATED_AT,
    m.RESOLVED_AT,
    DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT) as RESOLUTION_TIME_MINS,
    -- Combined searchable content
    CONCAT(
        'Maintenance Ticket: ', m.TICKET_ID, '\n',
        'Device: ', m.DEVICE_ID, ' (', d.DEVICE_MODEL, ')\n',
        'Facility: ', d.FACILITY_NAME, ' - ', d.FACILITY_TYPE, '\n',
        'Location: ', d.LOCATION_CITY, ', ', d.LOCATION_STATE, '\n\n',
        'Issue Type: ', m.ISSUE_TYPE, '\n',
        'Problem Description: ', m.ISSUE_DESCRIPTION, '\n\n',
        'How it was resolved: ', m.RESOLUTION_TYPE, '\n',
        'Resolution Details: ', m.RESOLUTION_NOTES, '\n',
        'Cost: $', COALESCE(m.COST_USD::VARCHAR, '0'), '\n',
        'Time to Resolve: ', DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT)::VARCHAR, ' minutes'
    ) AS SEARCH_CONTENT
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID;

-- ============================================================================
-- CREATE CORTEX SEARCH SERVICE FOR TROUBLESHOOTING KB
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TROUBLESHOOTING_SEARCH_SVC
    ON SEARCH_CONTENT
    ATTRIBUTES ISSUE_CATEGORY, REQUIRES_DISPATCH
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
AS (
    SELECT 
        KB_ID,
        ISSUE_CATEGORY,
        ISSUE_SYMPTOMS,
        DIAGNOSTIC_STEPS,
        REMOTE_FIX_PROCEDURE,
        REQUIRES_DISPATCH,
        ESTIMATED_REMOTE_FIX_TIME_MINS,
        SUCCESS_RATE_PCT,
        SEARCH_CONTENT
    FROM TROUBLESHOOTING_KB_SEARCH
);

-- ============================================================================
-- CREATE CORTEX SEARCH SERVICE FOR MAINTENANCE HISTORY
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MAINTENANCE_HISTORY_SEARCH_SVC
    ON SEARCH_CONTENT
    ATTRIBUTES ISSUE_TYPE, RESOLUTION_TYPE, DEVICE_MODEL, LOCATION_STATE
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
AS (
    SELECT 
        TICKET_ID,
        DEVICE_ID,
        DEVICE_MODEL,
        FACILITY_NAME,
        FACILITY_TYPE,
        LOCATION_CITY,
        LOCATION_STATE,
        ISSUE_TYPE,
        ISSUE_DESCRIPTION,
        RESOLUTION_TYPE,
        RESOLUTION_NOTES,
        COST_USD,
        CREATED_AT,
        RESOLVED_AT,
        RESOLUTION_TIME_MINS,
        SEARCH_CONTENT
    FROM MAINTENANCE_HISTORY_SEARCH
);

-- ============================================================================
-- VERIFY CORTEX SEARCH SERVICES
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA DEVICE_OPS;

-- ============================================================================
-- TEST QUERIES
-- ============================================================================

-- Test: Find troubleshooting steps for a frozen screen
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DEVICE_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC',
    '{
        "query": "screen is frozen and not responding to touch input",
        "columns": ["KB_ID", "ISSUE_CATEGORY", "ISSUE_SYMPTOMS", "REMOTE_FIX_PROCEDURE", "SUCCESS_RATE_PCT"],
        "limit": 3
    }'
);

-- Test: Find past incidents with high CPU issues
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DEVICE_MAINTENANCE.DEVICE_OPS.MAINTENANCE_HISTORY_SEARCH_SVC',
    '{
        "query": "device running slow with high CPU usage",
        "columns": ["TICKET_ID", "DEVICE_ID", "ISSUE_TYPE", "RESOLUTION_TYPE", "RESOLUTION_NOTES"],
        "limit": 3
    }'
);

-- Test: Find issues that required field dispatch
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DEVICE_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC',
    '{
        "query": "what issues require sending a technician on site",
        "columns": ["ISSUE_CATEGORY", "ISSUE_SYMPTOMS", "REQUIRES_DISPATCH"],
        "filter": {"@eq": {"REQUIRES_DISPATCH": true}},
        "limit": 5
    }'
);

-- ============================================================================
-- ADD WI-FI TROUBLESHOOTING KB ENTRIES (NEW)
-- CRITICAL: 90%+ of devices run on provider Wi-Fi, not company-managed
-- These procedures address the most common issue: Wi-Fi password changes
-- ============================================================================

INSERT INTO TROUBLESHOOTING_KB (KB_ID, ISSUE_CATEGORY, ISSUE_SYMPTOMS, DIAGNOSTIC_STEPS, REMOTE_FIX_PROCEDURE, REQUIRES_DISPATCH, ESTIMATED_REMOTE_FIX_TIME_MINS, SUCCESS_RATE_PCT, LAST_UPDATED)
VALUES
    ('KB-011', 'WIFI_PASSWORD_CHANGE', 
     'Device suddenly offline, signal dropped from good (-45dBm) to poor (-85dBm) instantly. No hardware degradation. Other devices at same facility may still be online.',
     '1. Check last gasp telemetry for signal pattern\n2. Verify SUDDEN_DROP signal trend\n3. Confirm CPU/memory were healthy before disconnect\n4. Check if other devices in same office are affected\n5. Review provider office contact info',
     'CALL OFFICE PROCEDURE:\n1. This is NOT a remote fix - requires contacting the provider office\n2. Look up facility contact number in provider database\n3. Call office and ask: "Did you recently change your Wi-Fi password?"\n4. If YES: Get new password and schedule remote reconnection\n5. If NO: Escalate to network team\n6. Log resolution in last_gasp table with ACTUAL_CAUSE',
     FALSE, 10, 95.0, CURRENT_DATE()),
     
    ('KB-012', 'NETWORK_OUTAGE_PROVIDER', 
     'Multiple devices offline at same facility or geographic area. Gradual signal decline pattern. Provider network infrastructure suspected.',
     '1. Query last_gasp for devices with same PROVIDER_OFFICE_ID\n2. Check if multiple devices show GRADUAL_DECLINE pattern\n3. Verify no hardware issues (normal CPU/memory/temps)\n4. Cross-reference with known ISP outages in the area',
     'WAIT AND MONITOR:\n1. Do NOT dispatch technician - this is a provider-side issue\n2. Contact provider office to report the outage\n3. Set up monitoring alert for when devices come back online\n4. If offline > 4 hours, call provider to verify they are aware\n5. Track outage duration for SLA reporting',
     FALSE, 5, 88.0, CURRENT_DATE()),

    ('KB-013', 'WIFI_SIGNAL_DEGRADATION', 
     'Device showing intermittent connectivity, signal strength fluctuating between -60 and -80 dBm. May auto-reconnect then drop again.',
     '1. Review signal strength history over past 24 hours\n2. Check for new interference sources (time-of-day patterns)\n3. Verify device has not been moved\n4. Check if provider added new equipment near device',
     'REMOTE + CALL OFFICE:\n1. Attempt remote network adapter reset first\n2. If issue persists, call office to ask about:\n   - New equipment near the device\n   - Router location changes\n   - New wireless devices in the area\n3. May need to recommend Wi-Fi extender installation\n4. If chronic issue, consider cellular backup option',
     FALSE, 20, 75.0, CURRENT_DATE()),

    ('KB-014', 'PROVIDER_WIFI_ONBOARDING', 
     'New device installation at facility using provider Wi-Fi. Need to connect to existing network.',
     '1. Confirm facility contact and IT contact available\n2. Verify device serial number and model\n3. Ensure technician has network configuration tools',
     'INSTALLATION PROCEDURE (Provider Wi-Fi):\n1. Technician on-site contacts facility IT or office manager\n2. Request Wi-Fi SSID and password\n3. Configure device network settings\n4. Verify stable connection for 15 minutes\n5. Document network details in secure credential store\n6. Set NETWORK_TYPE = PROVIDER_WIFI in device inventory\n7. Note: Company has NO control over this network',
     TRUE, 30, 98.0, CURRENT_DATE());

-- Refresh the search table with new KB entries
INSERT INTO TROUBLESHOOTING_KB_SEARCH
SELECT 
    KB_ID,
    ISSUE_CATEGORY,
    ISSUE_SYMPTOMS,
    DIAGNOSTIC_STEPS,
    REMOTE_FIX_PROCEDURE,
    REQUIRES_DISPATCH,
    ESTIMATED_REMOTE_FIX_TIME_MINS,
    SUCCESS_RATE_PCT,
    CONCAT(
        'Issue Category: ', ISSUE_CATEGORY, '\n\n',
        'Symptoms: ', ISSUE_SYMPTOMS, '\n\n',
        'Diagnostic Steps: ', DIAGNOSTIC_STEPS, '\n\n',
        'Remote Fix Procedure: ', REMOTE_FIX_PROCEDURE, '\n\n',
        'Requires Field Dispatch: ', IFF(REQUIRES_DISPATCH, 'Yes - this issue typically requires a technician on-site', 'No - this can usually be fixed remotely'), '\n',
        'Estimated Fix Time: ', COALESCE(ESTIMATED_REMOTE_FIX_TIME_MINS::VARCHAR, 'N/A - Requires Dispatch'), ' minutes\n',
        'Historical Success Rate: ', SUCCESS_RATE_PCT::VARCHAR, '%'
    ) AS SEARCH_CONTENT
FROM TROUBLESHOOTING_KB
WHERE KB_ID IN ('KB-011', 'KB-012', 'KB-013', 'KB-014');

-- Test: Find Wi-Fi password change troubleshooting
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'DEVICE_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC',
    '{
        "query": "device went offline suddenly, signal dropped, might be wifi password change",
        "columns": ["KB_ID", "ISSUE_CATEGORY", "ISSUE_SYMPTOMS", "REMOTE_FIX_PROCEDURE"],
        "limit": 3
    }'
);

