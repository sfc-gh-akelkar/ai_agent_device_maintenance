/*******************************************************************************
 * PATIENTPOINT PREDICTIVE MAINTENANCE DEMO
 * Part 2: Snowflake Semantic Views for Cortex Analyst
 * 
 * Creates native Snowflake Semantic Views for natural language queries
 * in Snowflake Intelligence
 * 
 * Prerequisites: Run 01_create_database_and_data.sql first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- SEMANTIC VIEW 1: DEVICE FLEET ANALYTICS
-- For querying device health, status, and fleet metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_FLEET

  TABLES (
    devices AS V_DEVICE_HEALTH_SUMMARY PRIMARY KEY (DEVICE_ID)
  )

  DIMENSIONS (
    devices.device_id AS devices.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen id', 'unit id')
      COMMENT = 'Unique identifier for each HealthScreen device',
    
    devices.device_model AS devices.DEVICE_MODEL
      WITH SYNONYMS = ('model', 'screen type', 'product type')
      COMMENT = 'Device model: Pro 55, Lite 32, or Max 65',
    
    devices.facility_name AS devices.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'clinic', 'hospital', 'office', 'site')
      COMMENT = 'Name of the healthcare facility where device is installed',
    
    devices.facility_type AS devices.FACILITY_TYPE
      WITH SYNONYMS = ('facility category', 'type of facility', 'practice type')
      COMMENT = 'Type of healthcare facility',
    
    devices.city AS devices.LOCATION_CITY
      WITH SYNONYMS = ('city')
      COMMENT = 'City where the facility is located',
    
    devices.state AS devices.LOCATION_STATE
      WITH SYNONYMS = ('state', 'region')
      COMMENT = 'State where the facility is located',
    
    devices.location AS devices.LOCATION
      WITH SYNONYMS = ('full location', 'city and state', 'where')
      COMMENT = 'Combined city and state location',
    
    devices.device_status AS devices.STATUS
      WITH SYNONYMS = ('status', 'state', 'condition', 'operational status')
      COMMENT = 'Current status: ONLINE, DEGRADED, OFFLINE, MAINTENANCE',
    
    devices.risk_level AS devices.RISK_LEVEL
      WITH SYNONYMS = ('risk', 'priority', 'risk category', 'urgency')
      COMMENT = 'Risk classification: LOW, MEDIUM, HIGH, CRITICAL',
    
    devices.primary_issue AS devices.PRIMARY_ISSUE
      WITH SYNONYMS = ('issue', 'problem', 'main issue', 'current problem')
      COMMENT = 'The primary issue affecting the device if any',
    
    devices.firmware_version AS devices.FIRMWARE_VERSION
      WITH SYNONYMS = ('firmware', 'software version', 'version')
      COMMENT = 'Current firmware version installed',
    
    devices.install_date AS devices.INSTALL_DATE
      WITH SYNONYMS = ('installation date', 'deployed date', 'setup date')
      COMMENT = 'Date the device was installed',
    
    devices.last_maintenance_date AS devices.LAST_MAINTENANCE_DATE
      WITH SYNONYMS = ('last service', 'last serviced', 'previous maintenance')
      COMMENT = 'Date of the most recent maintenance'
  )

  METRICS (
    devices.total_devices AS COUNT(DISTINCT devices.DEVICE_ID)
      WITH SYNONYMS = ('device count', 'number of devices', 'how many devices', 'fleet size')
      COMMENT = 'Total count of devices',
    
    devices.online_devices AS SUM(CASE WHEN devices.STATUS = 'ONLINE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('online count', 'devices online', 'working devices')
      COMMENT = 'Count of devices currently online',
    
    devices.offline_devices AS SUM(CASE WHEN devices.STATUS = 'OFFLINE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('offline count', 'devices offline', 'down devices')
      COMMENT = 'Count of devices currently offline',
    
    devices.degraded_devices AS SUM(CASE WHEN devices.STATUS = 'DEGRADED' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('degraded count', 'devices degraded')
      COMMENT = 'Count of devices with degraded performance',
    
    devices.devices_at_risk AS SUM(CASE WHEN devices.RISK_LEVEL IN ('HIGH', 'CRITICAL') THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('at risk devices', 'risky devices', 'high risk count')
      COMMENT = 'Count of devices with HIGH or CRITICAL risk level',
    
    devices.avg_health_score AS ROUND(AVG(devices.HEALTH_SCORE), 1)
      WITH SYNONYMS = ('average health', 'health score', 'fleet health', 'mean health')
      COMMENT = 'Average health score across devices (0-100)',
    
    devices.avg_cpu_temp AS ROUND(AVG(devices.CPU_TEMP_CELSIUS), 1)
      WITH SYNONYMS = ('average temperature', 'cpu temperature', 'mean temp')
      COMMENT = 'Average CPU temperature in Celsius',
    
    devices.avg_cpu_usage AS ROUND(AVG(devices.CPU_USAGE_PCT), 1)
      WITH SYNONYMS = ('cpu usage', 'processor usage', 'average cpu')
      COMMENT = 'Average CPU usage percentage',
    
    devices.avg_memory_usage AS ROUND(AVG(devices.MEMORY_USAGE_PCT), 1)
      WITH SYNONYMS = ('memory usage', 'ram usage', 'average memory')
      COMMENT = 'Average memory usage percentage',
    
    devices.total_errors AS SUM(devices.ERROR_COUNT)
      WITH SYNONYMS = ('error count', 'errors', 'total error count')
      COMMENT = 'Total error count across devices',
    
    devices.avg_days_since_maintenance AS ROUND(AVG(devices.DAYS_SINCE_MAINTENANCE), 0)
      WITH SYNONYMS = ('days since service', 'maintenance age', 'service gap')
      COMMENT = 'Average days since last maintenance'
  )

  COMMENT = 'Semantic view for device health monitoring and fleet analytics. Query device status, health scores, risk levels, and telemetry metrics.';

-- ============================================================================
-- SEMANTIC VIEW 2: MAINTENANCE ANALYTICS
-- For querying maintenance history, costs, and resolution metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MAINTENANCE_ANALYTICS

  TABLES (
    tickets AS V_MAINTENANCE_ANALYTICS PRIMARY KEY (TICKET_ID)
  )

  DIMENSIONS (
    tickets.ticket_id AS tickets.TICKET_ID
      WITH SYNONYMS = ('ticket', 'case', 'incident', 'case number')
      COMMENT = 'Unique identifier for the maintenance ticket',
    
    tickets.device_id AS tickets.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device that required maintenance',
    
    tickets.issue_type AS tickets.ISSUE_TYPE
      WITH SYNONYMS = ('problem type', 'issue category', 'failure type')
      COMMENT = 'Category of issue: DISPLAY_FREEZE, HIGH_CPU, NO_NETWORK, etc.',
    
    tickets.resolution_type AS tickets.RESOLUTION_TYPE
      WITH SYNONYMS = ('fix type', 'how fixed', 'resolution method', 'fix method')
      COMMENT = 'How resolved: REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT',
    
    tickets.was_remote_fix AS tickets.WAS_REMOTE_FIX
      WITH SYNONYMS = ('fixed remotely', 'remote resolution', 'remote fix')
      COMMENT = 'Whether the issue was resolved remotely',
    
    tickets.facility_name AS tickets.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site')
      COMMENT = 'Facility where the device is located',
    
    tickets.facility_type AS tickets.FACILITY_TYPE
      COMMENT = 'Type of healthcare facility',
    
    tickets.location AS tickets.LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state of the facility',
    
    tickets.created_at AS tickets.CREATED_AT
      WITH SYNONYMS = ('ticket date', 'incident date', 'when it happened', 'opened')
      COMMENT = 'When the maintenance ticket was created',
    
    tickets.resolved_at AS tickets.RESOLVED_AT
      WITH SYNONYMS = ('resolution date', 'fixed date', 'closed')
      COMMENT = 'When the ticket was resolved',
    
    tickets.ticket_month AS tickets.TICKET_MONTH
      WITH SYNONYMS = ('month')
      COMMENT = 'Month the ticket was created'
  )

  METRICS (
    tickets.total_tickets AS COUNT(DISTINCT tickets.TICKET_ID)
      WITH SYNONYMS = ('ticket count', 'number of incidents', 'how many tickets', 'incident count')
      COMMENT = 'Total count of maintenance tickets',
    
    tickets.remote_fix_count AS SUM(CASE WHEN tickets.RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('remote fixes', 'fixed remotely', 'remote resolutions')
      COMMENT = 'Number of issues resolved remotely',
    
    tickets.field_dispatch_count AS SUM(CASE WHEN tickets.RESOLUTION_TYPE = 'FIELD_DISPATCH' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('dispatches', 'field visits', 'technician visits', 'on-site fixes')
      COMMENT = 'Number of issues requiring field technician dispatch',
    
    tickets.total_cost AS SUM(COALESCE(tickets.COST_USD, 0))
      WITH SYNONYMS = ('maintenance cost', 'total spend', 'total expense')
      COMMENT = 'Total cost of maintenance in USD',
    
    tickets.avg_cost AS ROUND(AVG(COALESCE(tickets.COST_USD, 0)), 2)
      WITH SYNONYMS = ('average cost', 'cost per ticket')
      COMMENT = 'Average cost per maintenance ticket',
    
    tickets.total_cost_savings AS SUM(tickets.COST_SAVINGS_USD)
      WITH SYNONYMS = ('savings', 'money saved', 'cost savings', 'avoided costs')
      COMMENT = 'Total cost savings from remote fixes',
    
    tickets.avg_resolution_time AS ROUND(AVG(tickets.RESOLUTION_TIME_MINS), 0)
      WITH SYNONYMS = ('resolution time', 'time to fix', 'mttr', 'average fix time')
      COMMENT = 'Average time to resolve issues in minutes',
    
    tickets.remote_fix_rate AS ROUND(SUM(CASE WHEN tickets.RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1)
      WITH SYNONYMS = ('remote resolution rate', 'automation rate', 'remote fix percentage')
      COMMENT = 'Percentage of issues resolved remotely'
  )

  COMMENT = 'Semantic view for maintenance ticket analytics. Query issue types, resolution methods, costs, MTTR, and cost savings.';

-- ============================================================================
-- SEMANTIC VIEW 3: REVENUE & SATISFACTION
-- For querying business impact metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_BUSINESS_IMPACT

  TABLES (
    revenue AS V_REVENUE_IMPACT PRIMARY KEY (DEVICE_ID),
    satisfaction AS V_CUSTOMER_SATISFACTION PRIMARY KEY (DEVICE_ID)
  )

  RELATIONSHIPS (
    satisfaction (DEVICE_ID) REFERENCES revenue
  )

  DIMENSIONS (
    revenue.device_id AS revenue.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device identifier',
    
    revenue.facility_name AS revenue.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site')
      COMMENT = 'Healthcare facility name',
    
    revenue.facility_type AS revenue.FACILITY_TYPE
      COMMENT = 'Type of healthcare facility',
    
    revenue.location AS revenue.LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state location',
    
    satisfaction.nps_category AS satisfaction.NPS_CATEGORY
      WITH SYNONYMS = ('nps type', 'promoter status', 'satisfaction category')
      COMMENT = 'NPS classification: PROMOTER, PASSIVE, DETRACTOR'
  )

  METRICS (
    revenue.total_revenue_loss AS SUM(revenue.TOTAL_REVENUE_LOSS_USD)
      WITH SYNONYMS = ('lost revenue', 'revenue loss', 'money lost', 'revenue impact')
      COMMENT = 'Total revenue lost due to device downtime in USD',
    
    revenue.total_downtime_hours AS SUM(revenue.TOTAL_DOWNTIME_HOURS)
      WITH SYNONYMS = ('downtime', 'hours offline', 'outage hours', 'downtime hours')
      COMMENT = 'Total hours of device downtime',
    
    revenue.downtime_incidents AS SUM(revenue.DOWNTIME_INCIDENTS)
      WITH SYNONYMS = ('outages', 'incidents', 'downtime count')
      COMMENT = 'Number of downtime incidents',
    
    revenue.avg_uptime AS ROUND(AVG(revenue.UPTIME_PERCENTAGE), 2)
      WITH SYNONYMS = ('uptime', 'availability', 'uptime rate', 'uptime percentage')
      COMMENT = 'Average uptime percentage across devices',
    
    revenue.total_impressions_lost AS SUM(revenue.TOTAL_IMPRESSIONS_LOST)
      WITH SYNONYMS = ('lost impressions', 'missed impressions', 'ad impressions lost')
      COMMENT = 'Total advertising impressions lost due to downtime',
    
    revenue.potential_revenue AS SUM(revenue.POTENTIAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('max revenue', 'potential earnings', 'maximum revenue')
      COMMENT = 'Maximum possible monthly revenue if 100% uptime',
    
    revenue.actual_revenue AS SUM(revenue.ACTUAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('actual earnings', 'realized revenue')
      COMMENT = 'Actual monthly revenue after accounting for downtime',
    
    satisfaction.avg_nps_score AS ROUND(AVG(satisfaction.AVG_NPS_SCORE), 1)
      WITH SYNONYMS = ('nps', 'net promoter score', 'nps score', 'promoter score')
      COMMENT = 'Average Net Promoter Score (-100 to 100)',
    
    satisfaction.avg_satisfaction AS ROUND(AVG(satisfaction.AVG_SATISFACTION), 1)
      WITH SYNONYMS = ('satisfaction', 'rating', 'satisfaction score', 'happiness')
      COMMENT = 'Average satisfaction rating (1-5 stars)',
    
    satisfaction.avg_reliability_rating AS ROUND(AVG(satisfaction.AVG_RELIABILITY_RATING), 1)
      WITH SYNONYMS = ('reliability', 'reliability score', 'device reliability')
      COMMENT = 'Average device reliability rating (1-5)',
    
    satisfaction.positive_feedback AS SUM(satisfaction.POSITIVE_COUNT)
      WITH SYNONYMS = ('positive reviews', 'good feedback', 'happy customers')
      COMMENT = 'Number of positive feedback responses',
    
    satisfaction.negative_feedback AS SUM(satisfaction.NEGATIVE_COUNT)
      WITH SYNONYMS = ('negative reviews', 'bad feedback', 'complaints', 'unhappy customers')
      COMMENT = 'Number of negative feedback responses',
    
    satisfaction.pending_follow_ups AS SUM(satisfaction.FOLLOW_UPS_REQUIRED)
      WITH SYNONYMS = ('follow ups', 'pending actions', 'action items')
      COMMENT = 'Number of pending follow-up actions required'
  )

  COMMENT = 'Semantic view for business impact analytics. Query revenue loss, customer satisfaction, NPS scores, and downtime metrics.';

-- ============================================================================
-- SEMANTIC VIEW 4: OPERATIONS & WORK ORDERS
-- For operations center and field technician queries
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_OPERATIONS

  TABLES (
    work_orders AS V_ACTIVE_WORK_ORDERS PRIMARY KEY (WORK_ORDER_ID),
    technicians AS V_TECHNICIAN_WORKLOAD PRIMARY KEY (TECHNICIAN_ID)
  )

  RELATIONSHIPS (
    work_orders (ASSIGNED_TECHNICIAN_ID) REFERENCES technicians (TECHNICIAN_ID)
  )

  DIMENSIONS (
    work_orders.work_order_id AS work_orders.WORK_ORDER_ID
      WITH SYNONYMS = ('work order', 'job number', 'ticket')
      COMMENT = 'Unique work order identifier',
    
    work_orders.device_id AS work_orders.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device requiring service',
    
    work_orders.facility_name AS work_orders.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site', 'customer')
      COMMENT = 'Facility name',
    
    work_orders.location AS work_orders.LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state',
    
    work_orders.priority AS work_orders.PRIORITY
      WITH SYNONYMS = ('urgency', 'severity')
      COMMENT = 'Work order priority: CRITICAL, HIGH, MEDIUM, LOW',
    
    work_orders.status AS work_orders.STATUS
      WITH SYNONYMS = ('work order status', 'state')
      COMMENT = 'Current status: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED',
    
    work_orders.work_order_type AS work_orders.WORK_ORDER_TYPE
      WITH SYNONYMS = ('type', 'category')
      COMMENT = 'Type: PREDICTIVE, REACTIVE, PREVENTIVE, INSTALLATION',
    
    work_orders.source AS work_orders.SOURCE
      WITH SYNONYMS = ('origin', 'created by')
      COMMENT = 'How work order was created: AI_PREDICTION, MANUAL, PROVIDER_REQUEST',
    
    work_orders.scheduled_date AS work_orders.SCHEDULED_DATE
      WITH SYNONYMS = ('date', 'when scheduled')
      COMMENT = 'Scheduled service date',
    
    work_orders.assigned_technician AS work_orders.TECHNICIAN_NAME
      WITH SYNONYMS = ('tech', 'assigned to', 'engineer')
      COMMENT = 'Assigned technician name',
    
    technicians.technician_name AS technicians.TECHNICIAN_NAME
      WITH SYNONYMS = ('tech name', 'engineer name')
      COMMENT = 'Technician full name',
    
    technicians.technician_status AS technicians.CURRENT_STATUS
      WITH SYNONYMS = ('availability', 'tech status')
      COMMENT = 'Technician status: AVAILABLE, ON_CALL, DISPATCHED, OFF_DUTY',
    
    technicians.region AS technicians.REGION
      COMMENT = 'Geographic region covered',
    
    technicians.specialization AS technicians.SPECIALIZATION
      WITH SYNONYMS = ('expertise', 'skill')
      COMMENT = 'Technician specialization: Hardware, Software, Network',
    
    technicians.certification_level AS technicians.CERTIFICATION_LEVEL
      WITH SYNONYMS = ('level', 'seniority')
      COMMENT = 'Certification level: Junior, Senior, Lead'
  )

  METRICS (
    work_orders.total_work_orders AS COUNT(DISTINCT work_orders.WORK_ORDER_ID)
      WITH SYNONYMS = ('work order count', 'how many work orders', 'job count')
      COMMENT = 'Total count of active work orders',
    
    work_orders.critical_work_orders AS SUM(CASE WHEN work_orders.PRIORITY = 'CRITICAL' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('critical jobs', 'urgent work orders')
      COMMENT = 'Count of critical priority work orders',
    
    work_orders.unassigned_work_orders AS SUM(CASE WHEN work_orders.ASSIGNED_TECHNICIAN_ID IS NULL THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('unassigned jobs', 'open jobs', 'needs assignment')
      COMMENT = 'Count of work orders not yet assigned',
    
    work_orders.ai_generated_work_orders AS SUM(CASE WHEN work_orders.SOURCE = 'AI_PREDICTION' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('predictive work orders', 'ai work orders')
      COMMENT = 'Count of work orders generated by AI predictions',
    
    work_orders.avg_hours_open AS ROUND(AVG(work_orders.HOURS_SINCE_CREATED), 1)
      WITH SYNONYMS = ('average age', 'hours waiting')
      COMMENT = 'Average hours since work order was created',
    
    technicians.total_technicians AS COUNT(DISTINCT technicians.TECHNICIAN_ID)
      WITH SYNONYMS = ('tech count', 'team size', 'how many technicians')
      COMMENT = 'Total number of technicians',
    
    technicians.available_technicians AS SUM(CASE WHEN technicians.CURRENT_STATUS = 'AVAILABLE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('available techs', 'free technicians')
      COMMENT = 'Technicians currently available for dispatch',
    
    technicians.avg_technician_rating AS ROUND(AVG(technicians.AVG_RATING), 2)
      WITH SYNONYMS = ('average rating', 'team rating')
      COMMENT = 'Average technician performance rating',
    
    technicians.total_workload_mins AS SUM(technicians.TOTAL_ESTIMATED_MINS)
      WITH SYNONYMS = ('total work', 'workload')
      COMMENT = 'Total estimated work minutes across all technicians'
  )

  COMMENT = 'Semantic view for operations center. Query work orders, technician assignments, dispatch status, and field operations.';

-- ============================================================================
-- GRANT ACCESS TO SEMANTIC VIEWS
-- ============================================================================
GRANT SELECT ON SEMANTIC VIEW SV_DEVICE_FLEET TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_MAINTENANCE_ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_BUSINESS_IMPACT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_OPERATIONS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW SEMANTIC VIEWS IN SCHEMA DEVICE_OPS;

-- Test queries using the semantic views
SELECT * FROM SEMANTIC_VIEW(
    SV_DEVICE_FLEET
    DIMENSIONS device_status
    METRICS total_devices, avg_health_score
);

SELECT * FROM SEMANTIC_VIEW(
    SV_MAINTENANCE_ANALYTICS
    DIMENSIONS issue_type
    METRICS total_tickets, remote_fix_rate, avg_resolution_time
);

SELECT * FROM SEMANTIC_VIEW(
    SV_BUSINESS_IMPACT
    METRICS total_revenue_loss, avg_nps_score, avg_uptime
);

SELECT * FROM SEMANTIC_VIEW(
    SV_OPERATIONS
    DIMENSIONS priority, status
    METRICS total_work_orders, unassigned_work_orders
);

-- ============================================================================
-- ROI ANALYSIS SEMANTIC VIEW
-- Provides natural language access to cost baseline and savings projections
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_ROI_ANALYSIS
  TABLES (
    roi AS V_ROI_ANALYSIS PRIMARY KEY (DEMO_DEVICE_COUNT)
  )
  DIMENSIONS (
    roi.demo_device_count AS roi.DEMO_DEVICE_COUNT
      WITH SYNONYMS = ('demo devices', 'sample size')
      COMMENT = 'Number of devices in demo dataset',
    
    roi.production_device_count AS roi.PRODUCTION_DEVICE_COUNT
      WITH SYNONYMS = ('production devices', 'total devices', 'fleet size')
      COMMENT = 'Number of devices in production (500,000)'
  )
  METRICS (
    roi.avg_field_dispatch_cost AS MAX(roi.AVG_FIELD_DISPATCH_COST_USD)
      WITH SYNONYMS = ('dispatch cost', 'field visit cost')
      COMMENT = 'Average cost per field dispatch ($185)',
    
    roi.avg_remote_fix_cost AS MAX(roi.AVG_REMOTE_FIX_COST_USD)
      WITH SYNONYMS = ('remote cost', 'remote fix cost')
      COMMENT = 'Average cost per remote fix ($25)',
    
    roi.remote_fix_rate AS MAX(roi.REMOTE_FIX_RATE_PCT)
      WITH SYNONYMS = ('remote fix rate', 'remote resolution rate')
      COMMENT = 'Percentage of issues resolved remotely',
    
    roi.annual_dispatch_cost AS MAX(roi.PRODUCTION_ANNUAL_DISPATCH_COST_USD)
      WITH SYNONYMS = ('annual cost', 'yearly dispatch cost', 'current annual cost')
      COMMENT = 'Projected annual field dispatch cost at production scale ($185M)',
    
    roi.annual_savings AS MAX(roi.PROJECTED_ANNUAL_SAVINGS_USD)
      WITH SYNONYMS = ('annual savings', 'yearly savings', 'projected savings', 'cost reduction')
      COMMENT = 'Projected annual savings from remote fixes (~$96M)',
    
    roi.savings_to_date AS MAX(roi.ACTUAL_SAVINGS_TO_DATE_USD)
      WITH SYNONYMS = ('savings to date', 'current savings', 'achieved savings')
      COMMENT = 'Actual cost savings achieved from maintenance data',
    
    roi.dispatches_avoided AS MAX(roi.PROJECTED_ANNUAL_DISPATCHES_AVOIDED)
      WITH SYNONYMS = ('avoided dispatches', 'prevented dispatches')
      COMMENT = 'Number of field dispatches avoided annually through remote fixes'
  )
  COMMENT = 'ROI and cost analysis for executive decision-making. Shows annual cost baseline and projected savings from predictive maintenance.';

GRANT SELECT ON SEMANTIC VIEW SV_ROI_ANALYSIS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- EXTERNAL ACTIONS SEMANTIC VIEW
-- Provides natural language access to the action audit log
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_EXTERNAL_ACTIONS
  TABLES (
    actions AS V_RECENT_EXTERNAL_ACTIONS PRIMARY KEY (DEVICE_ID)
  )
  DIMENSIONS (
    actions.action_timestamp AS actions.TIMESTAMP
      WITH SYNONYMS = ('when', 'time', 'date')
      COMMENT = 'When the action was triggered',
    
    actions.action_type AS actions.ACTION_TYPE
      WITH SYNONYMS = ('type', 'category')
      COMMENT = 'Type of action: DEVICE_COMMAND, ALERT, or WORK_ORDER',
    
    actions.target_system AS actions.TARGET_SYSTEM
      WITH SYNONYMS = ('system', 'destination', 'platform')
      COMMENT = 'System the action was sent to: Device API, Slack, ServiceNow, etc.',
    
    actions.device_id AS actions.DEVICE_ID
      WITH SYNONYMS = ('device', 'unit')
      COMMENT = 'Device ID the action was for',
    
    actions.command AS actions.COMMAND
      WITH SYNONYMS = ('action', 'operation')
      COMMENT = 'Command or action that was executed',
    
    actions.status AS actions.STATUS
      WITH SYNONYMS = ('state', 'result')
      COMMENT = 'Status of the action: SIMULATED, PENDING, SENT, FAILED',
    
    actions.initiated_by AS actions.INITIATED_BY
      WITH SYNONYMS = ('source', 'triggered by', 'who')
      COMMENT = 'Who initiated the action: AI_AGENT, SCHEDULED_TASK, MANUAL',
    
    actions.api_endpoint AS actions.API_ENDPOINT
      WITH SYNONYMS = ('endpoint', 'url')
      COMMENT = 'API endpoint that would be called',
    
    actions.notes AS actions.NOTES
      WITH SYNONYMS = ('description', 'details')
      COMMENT = 'Additional notes about the action'
  )
  METRICS (
    actions.total_actions AS COUNT(*)
      WITH SYNONYMS = ('count', 'number of actions')
      COMMENT = 'Total number of actions in the log'
  )
  COMMENT = 'Audit log of automated actions triggered by the AI agent';

GRANT SELECT ON SEMANTIC VIEW SV_EXTERNAL_ACTIONS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- CURRENT DOWNTIME SEMANTIC VIEW
-- Shows devices currently offline with active revenue loss
-- This answers "How long have these devices been down and what's the cost?"
-- ============================================================================

CREATE OR REPLACE SEMANTIC VIEW SV_CURRENT_DOWNTIME
  TABLES (
    downtime AS V_CURRENT_DOWNTIME_IMPACT PRIMARY KEY (DEVICE_ID)
  )
  DIMENSIONS (
    downtime.device_id AS downtime.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'unit')
      COMMENT = 'Device ID currently experiencing downtime',
    
    downtime.facility_name AS downtime.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site', 'customer')
      COMMENT = 'Facility where the offline device is located',
    
    downtime.facility_type AS downtime.FACILITY_TYPE
      WITH SYNONYMS = ('type', 'category')
      COMMENT = 'Type of healthcare facility',
    
    downtime.location AS downtime.LOCATION
      WITH SYNONYMS = ('city', 'state', 'address')
      COMMENT = 'City and state of the facility',
    
    downtime.device_model AS downtime.DEVICE_MODEL
      WITH SYNONYMS = ('model', 'screen type')
      COMMENT = 'Model of the device',
    
    downtime.cause AS downtime.CAUSE
      WITH SYNONYMS = ('reason', 'issue', 'problem', 'root cause')
      COMMENT = 'Cause of the downtime (NETWORK_OUTAGE, HARDWARE_FAILURE, etc.)',
    
    downtime.ticket_id AS downtime.TICKET_ID
      WITH SYNONYMS = ('ticket', 'incident', 'case')
      COMMENT = 'Associated ticket or incident number',
    
    downtime.priority AS downtime.PRIORITY
      WITH SYNONYMS = ('urgency', 'severity')
      COMMENT = 'Priority level of the incident',
    
    downtime.estimated_resolution AS downtime.ESTIMATED_RESOLUTION
      WITH SYNONYMS = ('eta', 'expected fix', 'resolution plan')
      COMMENT = 'Estimated time or plan for resolution',
    
    downtime.downtime_start AS downtime.DOWNTIME_START
      WITH SYNONYMS = ('started', 'went down', 'offline since')
      COMMENT = 'When the device went offline'
  )
  METRICS (
    downtime.hours_offline AS SUM(downtime.HOURS_OFFLINE)
      WITH SYNONYMS = ('hours down', 'downtime hours', 'time offline', 'how long offline')
      COMMENT = 'Number of hours the device has been offline',
    
    downtime.revenue_lost AS SUM(downtime.REVENUE_LOST_SO_FAR)
      WITH SYNONYMS = ('revenue loss', 'money lost', 'cost', 'dollars lost', 'revenue impact')
      COMMENT = 'Revenue lost so far from this device being offline',
    
    downtime.impressions_lost AS SUM(downtime.IMPRESSIONS_LOST_SO_FAR)
      WITH SYNONYMS = ('lost impressions', 'missed ads', 'ad impressions lost')
      COMMENT = 'Ad impressions lost so far',
    
    downtime.daily_burn_rate AS SUM(downtime.DAILY_REVENUE_LOSS_RATE)
      WITH SYNONYMS = ('daily cost', 'daily loss', 'burn rate', 'daily revenue loss')
      COMMENT = 'Revenue being lost per day from this device',
    
    downtime.hourly_rate AS SUM(downtime.HOURLY_AD_REVENUE_USD)
      WITH SYNONYMS = ('hourly revenue', 'revenue per hour')
      COMMENT = 'Hourly ad revenue rate for this device'
  )
  COMMENT = 'Current active downtime for offline devices. Shows how long devices have been down and the revenue being lost RIGHT NOW. Use this to answer questions about current offline devices and their business impact.';

GRANT SELECT ON SEMANTIC VIEW SV_CURRENT_DOWNTIME TO ROLE SF_INTELLIGENCE_DEMO;

