/*******************************************************************************
 * PREDICTIVE DEVICE MAINTENANCE DEMO
 * Part 2: Consolidated Semantic Views for Cortex Analyst
 * 
 * Following Snowflake best practices:
 * - 3-5 tables per semantic view (star schema pattern)
 * - RELATIONSHIPS clause for proper joins
 * - FACTS for intermediate calculations
 * - Synonyms on tables AND dimensions
 * 
 * Reference: https://docs.snowflake.com/en/user-guide/views-semantic/sql
 * 
 * CONSOLIDATED VIEWS (3 total):
 * 1. SV_DEVICE_ANALYTICS - Device health, predictions, failure classification, triage
 * 2. SV_MAINTENANCE_OPERATIONS - Work orders, tickets, technicians, actions
 * 3. SV_BUSINESS_IMPACT - Revenue, satisfaction, ROI
 * 
 * Prerequisites: Run 01_create_database_and_data.sql first
 *                Run ML notebook for T_ML_PREDICTIONS table
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE DEVICE_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- SEMANTIC VIEW 1: DEVICE ANALYTICS (Star Schema)
-- Central fact: Device health
-- Dimensions: Predictions, Last Gasp, Downtime
-- Covers: Device health, ML predictions, failure classification, downtime
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_ANALYTICS

  TABLES (
    devices AS V_DEVICE_HEALTH_SUMMARY 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('screens', 'units', 'displays', 'fleet')
      COMMENT = 'Core device fleet with current health metrics and status',
    
    predictions AS T_ML_PREDICTIONS 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('forecasts', 'ml predictions', 'failure predictions')
      COMMENT = 'XGBoost model predictions: will fail in 48h, hours to failure, risk level',
    
    last_gasp AS DEVICE_LAST_GASP 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('failure analysis', 'offline analysis', 'last readings')
      COMMENT = 'Final telemetry before device went offline - classifies Wi-Fi password change vs hardware failure',
    
    downtime AS V_CURRENT_DOWNTIME_IMPACT 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('outages', 'offline devices', 'active downtime')
      COMMENT = 'Devices currently offline with revenue impact calculation'
  )

  RELATIONSHIPS (
    predictions_to_devices AS predictions (DEVICE_ID) REFERENCES devices,
    last_gasp_to_devices AS last_gasp (DEVICE_ID) REFERENCES devices,
    downtime_to_devices AS downtime (DEVICE_ID) REFERENCES devices
  )

  FACTS (
    devices.is_offline AS CASE WHEN devices.STATUS = 'OFFLINE' THEN 1 ELSE 0 END
      COMMENT = 'Flag: device is offline',
    devices.is_degraded AS CASE WHEN devices.STATUS = 'DEGRADED' THEN 1 ELSE 0 END
      COMMENT = 'Flag: device is degraded',
    devices.is_critical AS CASE WHEN devices.RISK_LEVEL = 'CRITICAL' THEN 1 ELSE 0 END
      COMMENT = 'Flag: device has critical risk level',
    devices.is_high_risk AS CASE WHEN devices.RISK_LEVEL IN ('HIGH', 'CRITICAL') THEN 1 ELSE 0 END
      COMMENT = 'Flag: device has high or critical risk',
    predictions.will_fail_soon AS CASE WHEN predictions.WILL_FAIL_48H = 1 THEN 1 ELSE 0 END
      COMMENT = 'Flag: ML predicts failure within 48 hours',
    predictions.is_critical_risk AS CASE WHEN predictions.RISK_LEVEL = 'CRITICAL' THEN 1 ELSE 0 END
      COMMENT = 'Flag: ML risk level is critical',
    last_gasp.is_wifi_issue AS CASE WHEN last_gasp.CLASSIFIED_CAUSE = 'WIFI_PASSWORD_CHANGE' THEN 1 ELSE 0 END
      COMMENT = 'Flag: classified as Wi-Fi password change (can call office to fix)',
    last_gasp.is_hardware_issue AS CASE WHEN last_gasp.CLASSIFIED_CAUSE = 'HARDWARE_FAILURE' THEN 1 ELSE 0 END
      COMMENT = 'Flag: classified as hardware failure (needs dispatch)',
    last_gasp.is_resolved AS CASE WHEN last_gasp.RESOLVED_TIMESTAMP IS NOT NULL THEN 1 ELSE 0 END
      COMMENT = 'Flag: incident has been resolved'
  )

  DIMENSIONS (
    devices.device_id AS devices.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen id', 'unit id', 'device identifier')
      COMMENT = 'Unique identifier for each HealthScreen device',
    devices.device_model AS devices.DEVICE_MODEL
      WITH SYNONYMS = ('model', 'screen type', 'product type', 'device type')
      COMMENT = 'Device model: HealthScreen Pro 55, Lite 32, or Max 65',
    devices.facility_name AS devices.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'clinic', 'hospital', 'office', 'site', 'customer')
      COMMENT = 'Name of the healthcare facility where device is installed',
    devices.facility_type AS devices.FACILITY_TYPE
      WITH SYNONYMS = ('facility category', 'type of facility', 'practice type')
      COMMENT = 'Type of healthcare facility: Hospital, Primary Care, Specialty, etc.',
    devices.city AS devices.LOCATION_CITY
      WITH SYNONYMS = ('city')
      COMMENT = 'City where the facility is located',
    devices.state AS devices.LOCATION_STATE
      WITH SYNONYMS = ('state', 'region')
      COMMENT = 'State where the facility is located (IL, OH, MI, etc.)',
    devices.location AS devices.LOCATION
      WITH SYNONYMS = ('full location', 'city and state', 'where')
      COMMENT = 'Combined city and state location',
    devices.device_status AS devices.STATUS
      WITH SYNONYMS = ('status', 'state', 'condition', 'operational status')
      COMMENT = 'Current device status: ONLINE, DEGRADED, OFFLINE, MAINTENANCE',
    devices.risk_level AS devices.RISK_LEVEL
      WITH SYNONYMS = ('risk', 'priority', 'risk category', 'urgency', 'risk level')
      COMMENT = 'Risk classification based on telemetry: LOW, MEDIUM, HIGH, CRITICAL',
    devices.primary_issue AS devices.PRIMARY_ISSUE
      WITH SYNONYMS = ('issue', 'problem', 'main issue', 'current problem')
      COMMENT = 'The primary issue affecting the device if any',
    devices.firmware_version AS devices.FIRMWARE_VERSION
      WITH SYNONYMS = ('firmware', 'software version', 'version')
      COMMENT = 'Current firmware version installed on device',
    devices.install_date AS devices.INSTALL_DATE
      WITH SYNONYMS = ('installation date', 'deployed date', 'setup date')
      COMMENT = 'Date the device was originally installed',
    devices.last_maintenance_date AS devices.LAST_MAINTENANCE_DATE
      WITH SYNONYMS = ('last service', 'last serviced', 'previous maintenance')
      COMMENT = 'Date of the most recent maintenance visit',
    devices.network_type AS devices.NETWORK_TYPE
      WITH SYNONYMS = ('connection type', 'wifi type', 'network')
      COMMENT = 'Network connection: PROVIDER_WIFI (90%+), COMPANY_MANAGED, CELLULAR',
    predictions.ml_risk_level AS predictions.RISK_LEVEL
      WITH SYNONYMS = ('predicted risk', 'ml risk', 'prediction risk level')
      COMMENT = 'ML model predicted risk level: CRITICAL, WARNING, CAUTION, HEALTHY',
    predictions.primary_risk_factor AS predictions.PRIMARY_RISK_FACTOR
      WITH SYNONYMS = ('risk reason', 'why at risk', 'risk explanation')
      COMMENT = 'Primary factor contributing to predicted failure risk',
    last_gasp.signal_trend AS last_gasp.SIGNAL_TREND
      WITH SYNONYMS = ('pattern', 'signal pattern', 'wifi trend')
      COMMENT = 'WiFi signal trend before offline: SUDDEN_DROP (password change), GRADUAL_DECLINE, STABLE',
    last_gasp.classified_cause AS last_gasp.CLASSIFIED_CAUSE
      WITH SYNONYMS = ('cause', 'failure cause', 'reason', 'classification', 'why offline', 'root cause')
      COMMENT = 'AI-classified cause: WIFI_PASSWORD_CHANGE, HARDWARE_FAILURE, NETWORK_OUTAGE, POWER_LOSS',
    last_gasp.classification_reason AS last_gasp.CLASSIFICATION_REASON
      WITH SYNONYMS = ('explanation', 'classification reason')
      COMMENT = 'Human-readable explanation of why the device went offline',
    last_gasp.resolution_action AS last_gasp.RESOLUTION_ACTION
      WITH SYNONYMS = ('fix', 'action taken', 'resolution', 'how fixed')
      COMMENT = 'Action that resolved the issue: CALL_OFFICE, DISPATCH_TECH, REMOTE_RESTART',
    downtime.cause AS downtime.CAUSE
      WITH SYNONYMS = ('downtime cause', 'outage reason')
      COMMENT = 'Cause of current downtime',
    downtime.priority AS downtime.PRIORITY
      WITH SYNONYMS = ('urgency', 'severity', 'downtime priority')
      COMMENT = 'Priority level of the downtime incident'
  )

  METRICS (
    devices.total_devices AS COUNT(DISTINCT devices.DEVICE_ID)
      WITH SYNONYMS = ('device count', 'number of devices', 'how many devices', 'fleet size', 'total count')
      COMMENT = 'Total count of devices in the fleet',
    devices.online_devices AS SUM(CASE WHEN devices.STATUS = 'ONLINE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('online count', 'devices online', 'working devices', 'operational')
      COMMENT = 'Count of devices currently online and operational',
    devices.offline_devices AS SUM(devices.is_offline)
      WITH SYNONYMS = ('offline count', 'devices offline', 'down devices', 'not working')
      COMMENT = 'Count of devices currently offline',
    devices.degraded_devices AS SUM(devices.is_degraded)
      WITH SYNONYMS = ('degraded count', 'devices degraded', 'impaired')
      COMMENT = 'Count of devices with degraded performance',
    devices.devices_at_risk AS SUM(devices.is_high_risk)
      WITH SYNONYMS = ('at risk devices', 'risky devices', 'high risk count', 'critical count')
      COMMENT = 'Count of devices with HIGH or CRITICAL risk level',
    devices.avg_health_score AS ROUND(AVG(devices.HEALTH_SCORE), 1)
      WITH SYNONYMS = ('average health', 'health score', 'fleet health', 'mean health')
      COMMENT = 'Average health score across devices (0-100, higher is better)',
    devices.avg_cpu_temp AS ROUND(AVG(devices.CPU_TEMP_CELSIUS), 1)
      WITH SYNONYMS = ('average temperature', 'cpu temperature', 'mean temp')
      COMMENT = 'Average CPU temperature in Celsius (normal: 40-55, high: >65)',
    devices.avg_cpu_usage AS ROUND(AVG(devices.CPU_USAGE_PCT), 1)
      WITH SYNONYMS = ('cpu usage', 'processor usage', 'average cpu')
      COMMENT = 'Average CPU usage percentage (normal: <70%, high: >85%)',
    devices.avg_memory_usage AS ROUND(AVG(devices.MEMORY_USAGE_PCT), 1)
      WITH SYNONYMS = ('memory usage', 'ram usage', 'average memory')
      COMMENT = 'Average memory usage percentage (normal: <75%, high: >90%)',
    devices.total_errors AS SUM(devices.ERROR_COUNT)
      WITH SYNONYMS = ('error count', 'errors', 'total error count')
      COMMENT = 'Total error count across all devices',
    devices.avg_days_since_maintenance AS ROUND(AVG(devices.DAYS_SINCE_MAINTENANCE), 0)
      WITH SYNONYMS = ('days since service', 'maintenance age', 'service gap')
      COMMENT = 'Average days since last maintenance',
    predictions.predicted_failures AS SUM(predictions.will_fail_soon)
      WITH SYNONYMS = ('will fail', 'predicted to fail', 'failure predictions', 'at risk of failure')
      COMMENT = 'Devices predicted to fail within 48 hours by XGBoost model',
    predictions.critical_predictions AS SUM(predictions.is_critical_risk)
      WITH SYNONYMS = ('critical risk', 'critical predictions')
      COMMENT = 'Devices with CRITICAL ML risk level',
    predictions.avg_hours_to_failure AS ROUND(AVG(predictions.PREDICTED_HOURS_TO_FAILURE), 1)
      WITH SYNONYMS = ('time to failure', 'hours until failure', 'failure timeline')
      COMMENT = 'Average predicted hours until failure for at-risk devices',
    last_gasp.wifi_password_issues AS SUM(last_gasp.is_wifi_issue)
      WITH SYNONYMS = ('password changes', 'wifi issues', 'credential issues')
      COMMENT = 'Offline incidents classified as Wi-Fi password changes (can call office)',
    last_gasp.hardware_failures AS SUM(last_gasp.is_hardware_issue)
      WITH SYNONYMS = ('hardware issues', 'hardware problems')
      COMMENT = 'Offline incidents classified as hardware failures (need dispatch)',
    last_gasp.avg_classification_confidence AS ROUND(AVG(last_gasp.CLASSIFICATION_CONFIDENCE), 2)
      WITH SYNONYMS = ('confidence', 'accuracy', 'classification accuracy')
      COMMENT = 'Average confidence of failure classification (0-1)',
    last_gasp.resolved_incidents AS SUM(last_gasp.is_resolved)
      WITH SYNONYMS = ('fixed', 'resolved')
      COMMENT = 'Number of offline incidents that have been resolved',
    last_gasp.unresolved_incidents AS SUM(CASE WHEN last_gasp.RESOLVED_TIMESTAMP IS NULL THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('open', 'pending', 'unresolved')
      COMMENT = 'Number of offline incidents still unresolved',
    downtime.total_downtime_hours AS SUM(downtime.HOURS_OFFLINE)
      WITH SYNONYMS = ('hours down', 'downtime hours', 'time offline')
      COMMENT = 'Total hours of current active downtime',
    downtime.current_revenue_loss AS SUM(downtime.REVENUE_LOST_SO_FAR)
      WITH SYNONYMS = ('revenue lost', 'money lost', 'current loss', 'dollars lost')
      COMMENT = 'Revenue lost so far from currently offline devices',
    downtime.daily_burn_rate AS SUM(downtime.DAILY_REVENUE_LOSS_RATE)
      WITH SYNONYMS = ('daily loss', 'burn rate', 'daily cost')
      COMMENT = 'Revenue being lost per day from currently offline devices'
  )

  COMMENT = 'Unified device analytics: health status, ML predictions, failure classification, and triage recommendations. Use this for ALL device-related questions.';

-- ============================================================================
-- SEMANTIC VIEW 2: MAINTENANCE OPERATIONS (Star Schema)
-- Central fact: Work orders
-- Dimensions: Tickets, Technicians, Actions
-- Covers: Work orders, maintenance history, technician dispatch, action audit
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MAINTENANCE_OPERATIONS

  TABLES (
    work_orders AS V_ACTIVE_WORK_ORDERS 
      PRIMARY KEY (WORK_ORDER_ID)
      WITH SYNONYMS = ('jobs', 'service orders', 'dispatches')
      COMMENT = 'Active maintenance work orders and their status',
    tickets AS V_MAINTENANCE_ANALYTICS 
      PRIMARY KEY (TICKET_ID)
      WITH SYNONYMS = ('incidents', 'cases', 'service tickets', 'maintenance history')
      COMMENT = 'Historical maintenance tickets with resolution details and costs',
    technicians AS V_TECHNICIAN_WORKLOAD 
      PRIMARY KEY (TECHNICIAN_ID)
      WITH SYNONYMS = ('engineers', 'techs', 'field team', 'service team')
      COMMENT = 'Field technicians with their current workload and availability',
    actions AS V_RECENT_EXTERNAL_ACTIONS 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('audit log', 'action log', 'automation log')
      COMMENT = 'Log of automated actions triggered by the AI agent'
  )

  RELATIONSHIPS (
    work_orders_to_technicians AS work_orders (ASSIGNED_TECHNICIAN_ID) REFERENCES technicians (TECHNICIAN_ID)
  )

  FACTS (
    work_orders.is_critical AS CASE WHEN work_orders.PRIORITY = 'CRITICAL' THEN 1 ELSE 0 END
      COMMENT = 'Flag: work order has critical priority',
    work_orders.is_unassigned AS CASE WHEN work_orders.ASSIGNED_TECHNICIAN_ID IS NULL THEN 1 ELSE 0 END
      COMMENT = 'Flag: work order not yet assigned to technician',
    work_orders.is_ai_generated AS CASE WHEN work_orders.SOURCE = 'AI_PREDICTION' THEN 1 ELSE 0 END
      COMMENT = 'Flag: work order created by AI prediction',
    tickets.was_remote_fix AS CASE WHEN tickets.RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 ELSE 0 END
      COMMENT = 'Flag: issue was resolved remotely (no dispatch needed)',
    tickets.was_dispatch AS CASE WHEN tickets.RESOLUTION_TYPE = 'FIELD_DISPATCH' THEN 1 ELSE 0 END
      COMMENT = 'Flag: required field technician dispatch',
    technicians.is_available AS CASE WHEN technicians.CURRENT_STATUS = 'AVAILABLE' THEN 1 ELSE 0 END
      COMMENT = 'Flag: technician is available for dispatch'
  )

  DIMENSIONS (
    work_orders.work_order_id AS work_orders.WORK_ORDER_ID
      WITH SYNONYMS = ('work order', 'job number', 'wo number')
      COMMENT = 'Unique work order identifier',
    work_orders.device_id AS work_orders.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device requiring service',
    work_orders.facility_name AS work_orders.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site', 'customer')
      COMMENT = 'Facility name where device is located',
    work_orders.location AS work_orders.LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state of the facility',
    work_orders.priority AS work_orders.PRIORITY
      WITH SYNONYMS = ('urgency', 'severity', 'work order priority')
      COMMENT = 'Work order priority: CRITICAL, HIGH, MEDIUM, LOW',
    work_orders.status AS work_orders.STATUS
      WITH SYNONYMS = ('work order status', 'state', 'wo status')
      COMMENT = 'Current status: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED, CANCELLED',
    work_orders.work_order_type AS work_orders.WORK_ORDER_TYPE
      WITH SYNONYMS = ('type', 'category', 'wo type')
      COMMENT = 'Type: PREDICTIVE (AI-generated), REACTIVE, PREVENTIVE, INSTALLATION',
    work_orders.source AS work_orders.SOURCE
      WITH SYNONYMS = ('origin', 'created by', 'source')
      COMMENT = 'How work order was created: AI_PREDICTION, MANUAL, PROVIDER_REQUEST, SCHEDULED',
    work_orders.scheduled_date AS work_orders.SCHEDULED_DATE
      WITH SYNONYMS = ('date', 'when scheduled', 'service date')
      COMMENT = 'Scheduled service date',
    work_orders.assigned_technician AS work_orders.TECHNICIAN_NAME
      WITH SYNONYMS = ('tech', 'assigned to', 'engineer', 'technician')
      COMMENT = 'Name of assigned technician',
    work_orders.issue_summary AS work_orders.ISSUE_SUMMARY
      WITH SYNONYMS = ('issue', 'problem', 'description')
      COMMENT = 'Summary of the issue requiring service',
    work_orders.ai_diagnosis AS work_orders.AI_DIAGNOSIS
      WITH SYNONYMS = ('diagnosis', 'ai analysis', 'root cause')
      COMMENT = 'AI-generated diagnosis of the issue',
    tickets.ticket_id AS tickets.TICKET_ID
      WITH SYNONYMS = ('ticket', 'case', 'incident', 'case number')
      COMMENT = 'Unique identifier for the maintenance ticket',
    tickets.issue_type AS tickets.ISSUE_TYPE
      WITH SYNONYMS = ('problem type', 'issue category', 'failure type')
      COMMENT = 'Category: DISPLAY_FREEZE, HIGH_CPU, NO_NETWORK, OVERHEATING, etc.',
    tickets.resolution_type AS tickets.RESOLUTION_TYPE
      WITH SYNONYMS = ('fix type', 'how fixed', 'resolution method')
      COMMENT = 'How resolved: REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT',
    tickets.created_at AS tickets.CREATED_AT
      WITH SYNONYMS = ('ticket date', 'incident date', 'opened')
      COMMENT = 'When the maintenance ticket was created',
    tickets.resolved_at AS tickets.RESOLVED_AT
      WITH SYNONYMS = ('resolution date', 'fixed date', 'closed')
      COMMENT = 'When the ticket was resolved',
    technicians.technician_name AS technicians.TECHNICIAN_NAME
      WITH SYNONYMS = ('tech name', 'engineer name', 'name')
      COMMENT = 'Technician full name',
    technicians.technician_status AS technicians.CURRENT_STATUS
      WITH SYNONYMS = ('availability', 'tech status')
      COMMENT = 'Current status: AVAILABLE, ON_CALL, DISPATCHED, OFF_DUTY',
    technicians.region AS technicians.REGION
      WITH SYNONYMS = ('territory', 'coverage area')
      COMMENT = 'Geographic region covered by technician',
    technicians.specialization AS technicians.SPECIALIZATION
      WITH SYNONYMS = ('expertise', 'skill', 'specialty')
      COMMENT = 'Technician specialization: Hardware, Software, Network',
    technicians.certification_level AS technicians.CERTIFICATION_LEVEL
      WITH SYNONYMS = ('level', 'seniority', 'certification')
      COMMENT = 'Certification level: Junior, Senior, Lead',
    actions.action_type AS actions.ACTION_TYPE
      WITH SYNONYMS = ('type', 'action category')
      COMMENT = 'Type of action: DEVICE_COMMAND, ALERT, WORK_ORDER',
    actions.target_system AS actions.TARGET_SYSTEM
      WITH SYNONYMS = ('system', 'destination')
      COMMENT = 'Target system: Device API, Slack, ServiceNow, PagerDuty',
    actions.command AS actions.COMMAND
      WITH SYNONYMS = ('action', 'operation')
      COMMENT = 'Command executed: RESTART_SERVICES, CLEAR_CACHE, SEND_NOTIFICATION',
    actions.initiated_by AS actions.INITIATED_BY
      WITH SYNONYMS = ('source', 'triggered by')
      COMMENT = 'Who initiated: AI_AGENT, SCHEDULED_TASK, MANUAL'
  )

  METRICS (
    work_orders.total_work_orders AS COUNT(DISTINCT work_orders.WORK_ORDER_ID)
      WITH SYNONYMS = ('work order count', 'how many work orders', 'job count', 'open jobs')
      COMMENT = 'Total count of active work orders',
    work_orders.critical_work_orders AS SUM(work_orders.is_critical)
      WITH SYNONYMS = ('critical jobs', 'urgent work orders', 'critical count')
      COMMENT = 'Count of critical priority work orders',
    work_orders.unassigned_work_orders AS SUM(work_orders.is_unassigned)
      WITH SYNONYMS = ('unassigned jobs', 'needs assignment', 'unassigned count')
      COMMENT = 'Count of work orders not yet assigned to a technician',
    work_orders.ai_generated_work_orders AS SUM(work_orders.is_ai_generated)
      WITH SYNONYMS = ('predictive work orders', 'ai work orders', 'predicted jobs')
      COMMENT = 'Count of work orders generated by AI predictions',
    work_orders.avg_hours_open AS ROUND(AVG(work_orders.HOURS_SINCE_CREATED), 1)
      WITH SYNONYMS = ('average age', 'hours waiting', 'wait time')
      COMMENT = 'Average hours since work order was created',
    tickets.total_tickets AS COUNT(DISTINCT tickets.TICKET_ID)
      WITH SYNONYMS = ('ticket count', 'incident count', 'how many tickets', 'case count')
      COMMENT = 'Total count of maintenance tickets',
    tickets.remote_fix_count AS SUM(tickets.was_remote_fix)
      WITH SYNONYMS = ('remote fixes', 'fixed remotely', 'remote resolutions')
      COMMENT = 'Number of issues resolved remotely without dispatch',
    tickets.field_dispatch_count AS SUM(tickets.was_dispatch)
      WITH SYNONYMS = ('dispatches', 'field visits', 'technician visits', 'on-site fixes')
      COMMENT = 'Number of issues requiring field technician dispatch',
    tickets.total_maintenance_cost AS SUM(COALESCE(tickets.COST_USD, 0))
      WITH SYNONYMS = ('maintenance cost', 'total spend', 'total expense', 'cost')
      COMMENT = 'Total cost of maintenance in USD',
    tickets.avg_ticket_cost AS ROUND(AVG(COALESCE(tickets.COST_USD, 0)), 2)
      WITH SYNONYMS = ('average cost', 'cost per ticket')
      COMMENT = 'Average cost per maintenance ticket',
    tickets.total_cost_savings AS SUM(tickets.COST_SAVINGS_USD)
      WITH SYNONYMS = ('savings', 'money saved', 'cost savings', 'avoided costs')
      COMMENT = 'Total cost savings from remote fixes vs dispatch',
    tickets.avg_resolution_time AS ROUND(AVG(tickets.RESOLUTION_TIME_MINS), 0)
      WITH SYNONYMS = ('resolution time', 'time to fix', 'mttr', 'average fix time')
      COMMENT = 'Mean Time To Resolve (MTTR) in minutes',
    tickets.remote_fix_rate AS ROUND(SUM(tickets.was_remote_fix) * 100.0 / NULLIF(COUNT(tickets.TICKET_ID), 0), 1)
      WITH SYNONYMS = ('remote resolution rate', 'automation rate', 'remote fix percentage')
      COMMENT = 'Percentage of issues resolved remotely',
    technicians.total_technicians AS COUNT(DISTINCT technicians.TECHNICIAN_ID)
      WITH SYNONYMS = ('tech count', 'team size', 'how many technicians', 'engineer count')
      COMMENT = 'Total number of field technicians',
    technicians.available_technicians AS SUM(technicians.is_available)
      WITH SYNONYMS = ('available techs', 'free technicians', 'available count')
      COMMENT = 'Technicians currently available for dispatch',
    technicians.avg_technician_rating AS ROUND(AVG(technicians.AVG_RATING), 2)
      WITH SYNONYMS = ('average rating', 'team rating', 'tech rating')
      COMMENT = 'Average technician performance rating (1-5)',
    technicians.total_workload_mins AS SUM(technicians.TOTAL_ESTIMATED_MINS)
      WITH SYNONYMS = ('total work', 'workload', 'estimated work')
      COMMENT = 'Total estimated work minutes across all technicians',
    actions.total_actions AS COUNT(DISTINCT actions.DEVICE_ID)
      WITH SYNONYMS = ('action count', 'automation count')
      COMMENT = 'Total number of automated actions triggered'
  )

  COMMENT = 'Maintenance and field operations: work orders, service tickets, technician assignments, and automated actions. Use for operations center and technician queries.';

-- ============================================================================
-- SEMANTIC VIEW 3: BUSINESS IMPACT (Star Schema)
-- Central fact: Revenue impact
-- Dimensions: Customer satisfaction, ROI analysis
-- Covers: Revenue loss, NPS, satisfaction, ROI projections
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_BUSINESS_IMPACT

  TABLES (
    revenue AS V_REVENUE_IMPACT 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('earnings', 'income', 'financial impact')
      COMMENT = 'Revenue impact per device including downtime losses and potential earnings',
    satisfaction AS V_CUSTOMER_SATISFACTION 
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('nps', 'feedback', 'customer feedback')
      COMMENT = 'Provider satisfaction scores and feedback by device/facility',
    roi AS V_ROI_ANALYSIS 
      PRIMARY KEY (DEMO_DEVICE_COUNT)
      WITH SYNONYMS = ('return on investment', 'cost analysis', 'savings projection')
      COMMENT = 'ROI projections comparing remote fix vs dispatch costs at scale'
  )

  RELATIONSHIPS (
    satisfaction_to_revenue AS satisfaction (DEVICE_ID) REFERENCES revenue
  )

  FACTS (
    satisfaction.is_promoter AS CASE WHEN satisfaction.NPS_CATEGORY = 'PROMOTER' THEN 1 ELSE 0 END
      COMMENT = 'Flag: customer is a promoter (NPS 9-10)',
    satisfaction.is_detractor AS CASE WHEN satisfaction.NPS_CATEGORY = 'DETRACTOR' THEN 1 ELSE 0 END
      COMMENT = 'Flag: customer is a detractor (NPS 0-6)',
    satisfaction.is_passive AS CASE WHEN satisfaction.NPS_CATEGORY = 'PASSIVE' THEN 1 ELSE 0 END
      COMMENT = 'Flag: customer is passive (NPS 7-8)'
  )

  DIMENSIONS (
    revenue.device_id AS revenue.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'unit')
      COMMENT = 'Device identifier',
    revenue.facility_name AS revenue.FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site', 'customer', 'provider')
      COMMENT = 'Healthcare facility name',
    revenue.facility_type AS revenue.FACILITY_TYPE
      WITH SYNONYMS = ('type', 'category', 'facility category')
      COMMENT = 'Type of healthcare facility',
    revenue.location AS revenue.LOCATION
      WITH SYNONYMS = ('city state', 'where', 'address')
      COMMENT = 'City and state location',
    satisfaction.nps_category AS satisfaction.NPS_CATEGORY
      WITH SYNONYMS = ('nps type', 'promoter status', 'satisfaction category')
      COMMENT = 'NPS classification: PROMOTER (9-10), PASSIVE (7-8), DETRACTOR (0-6)',
    roi.demo_device_count AS roi.DEMO_DEVICE_COUNT
      WITH SYNONYMS = ('demo devices', 'sample size')
      COMMENT = 'Number of devices in demo dataset (100)',
    roi.production_device_count AS roi.PRODUCTION_DEVICE_COUNT
      WITH SYNONYMS = ('production devices', 'total fleet', 'fleet size')
      COMMENT = 'Number of devices in production (150,000 across 30,000 offices)'
  )

  METRICS (
    revenue.total_revenue_loss AS SUM(revenue.TOTAL_REVENUE_LOSS_USD)
      WITH SYNONYMS = ('lost revenue', 'revenue loss', 'money lost', 'revenue impact', 'total loss')
      COMMENT = 'Total revenue lost due to device downtime in USD',
    revenue.total_downtime_hours AS SUM(revenue.TOTAL_DOWNTIME_HOURS)
      WITH SYNONYMS = ('downtime', 'hours offline', 'outage hours', 'total downtime')
      COMMENT = 'Total hours of device downtime',
    revenue.downtime_incidents AS SUM(revenue.DOWNTIME_INCIDENTS)
      WITH SYNONYMS = ('outages', 'incidents', 'downtime count')
      COMMENT = 'Total number of downtime incidents',
    revenue.avg_uptime AS ROUND(AVG(revenue.UPTIME_PERCENTAGE), 2)
      WITH SYNONYMS = ('uptime', 'availability', 'uptime rate', 'uptime percentage')
      COMMENT = 'Average uptime percentage across devices (target: 95%+)',
    revenue.total_impressions_lost AS SUM(revenue.TOTAL_IMPRESSIONS_LOST)
      WITH SYNONYMS = ('lost impressions', 'missed impressions', 'ad impressions lost')
      COMMENT = 'Total advertising impressions lost due to downtime',
    revenue.potential_monthly_revenue AS SUM(revenue.POTENTIAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('max revenue', 'potential earnings', 'maximum revenue')
      COMMENT = 'Maximum possible monthly revenue if 100% uptime',
    revenue.actual_monthly_revenue AS SUM(revenue.ACTUAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('actual earnings', 'realized revenue', 'current revenue')
      COMMENT = 'Actual monthly revenue after accounting for downtime',
    satisfaction.avg_nps_score AS ROUND(AVG(satisfaction.AVG_NPS_SCORE), 1)
      WITH SYNONYMS = ('nps', 'net promoter score', 'nps score', 'promoter score')
      COMMENT = 'Average Net Promoter Score (-100 to 100)',
    satisfaction.avg_satisfaction AS ROUND(AVG(satisfaction.AVG_SATISFACTION), 1)
      WITH SYNONYMS = ('satisfaction', 'rating', 'satisfaction score', 'csat')
      COMMENT = 'Average satisfaction rating (1-5 stars)',
    satisfaction.avg_reliability_rating AS ROUND(AVG(satisfaction.AVG_RELIABILITY_RATING), 1)
      WITH SYNONYMS = ('reliability', 'reliability score', 'device reliability')
      COMMENT = 'Average device reliability rating (1-5)',
    satisfaction.positive_feedback AS SUM(satisfaction.POSITIVE_COUNT)
      WITH SYNONYMS = ('positive reviews', 'good feedback', 'happy customers', 'promoters')
      COMMENT = 'Number of positive feedback responses',
    satisfaction.negative_feedback AS SUM(satisfaction.NEGATIVE_COUNT)
      WITH SYNONYMS = ('negative reviews', 'bad feedback', 'complaints', 'detractors')
      COMMENT = 'Number of negative feedback responses',
    satisfaction.pending_follow_ups AS SUM(satisfaction.FOLLOW_UPS_REQUIRED)
      WITH SYNONYMS = ('follow ups', 'pending actions', 'action items')
      COMMENT = 'Number of pending follow-up actions required',
    roi.avg_dispatch_cost AS MAX(roi.AVG_FIELD_DISPATCH_COST_USD)
      WITH SYNONYMS = ('dispatch cost', 'field visit cost', 'technician cost')
      COMMENT = 'Average cost per field dispatch ($185)',
    roi.avg_remote_fix_cost AS MAX(roi.AVG_REMOTE_FIX_COST_USD)
      WITH SYNONYMS = ('remote cost', 'remote fix cost')
      COMMENT = 'Average cost per remote fix ($25)',
    roi.remote_fix_rate AS MAX(roi.REMOTE_FIX_RATE_PCT)
      WITH SYNONYMS = ('remote fix rate', 'remote resolution rate', 'automation rate')
      COMMENT = 'Percentage of issues that can be resolved remotely',
    roi.annual_dispatch_cost AS MAX(roi.PRODUCTION_ANNUAL_DISPATCH_COST_USD)
      WITH SYNONYMS = ('annual cost', 'yearly dispatch cost', 'current annual cost', 'baseline cost')
      COMMENT = 'Projected annual field dispatch cost at production scale (~$55M for 150K devices)',
    roi.projected_annual_savings AS MAX(roi.PROJECTED_ANNUAL_SAVINGS_USD)
      WITH SYNONYMS = ('annual savings', 'yearly savings', 'projected savings', 'cost reduction')
      COMMENT = 'Projected annual savings from remote fixes (~$29M for 150K devices)',
    roi.actual_savings_to_date AS MAX(roi.ACTUAL_SAVINGS_TO_DATE_USD)
      WITH SYNONYMS = ('savings to date', 'current savings', 'achieved savings')
      COMMENT = 'Actual cost savings achieved from maintenance data so far',
    roi.dispatches_avoided AS MAX(roi.PROJECTED_ANNUAL_DISPATCHES_AVOIDED)
      WITH SYNONYMS = ('avoided dispatches', 'prevented dispatches', 'saved trips')
      COMMENT = 'Number of field dispatches avoided annually through remote fixes'
  )

  COMMENT = 'Business impact analytics: revenue loss, customer satisfaction, NPS scores, and ROI projections. Use for executive dashboards and financial impact questions.';

-- ============================================================================
-- GRANT ACCESS TO CONSOLIDATED SEMANTIC VIEWS
-- ============================================================================
GRANT SELECT ON SEMANTIC VIEW SV_DEVICE_ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_MAINTENANCE_OPERATIONS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT SELECT ON SEMANTIC VIEW SV_BUSINESS_IMPACT TO ROLE SF_INTELLIGENCE_DEMO;

-- Also grant REFERENCES for Cortex Analyst
GRANT REFERENCES ON SEMANTIC VIEW SV_DEVICE_ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT REFERENCES ON SEMANTIC VIEW SV_MAINTENANCE_OPERATIONS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT REFERENCES ON SEMANTIC VIEW SV_BUSINESS_IMPACT TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW SEMANTIC VIEWS IN SCHEMA DEVICE_OPS;

-- Test the consolidated semantic views
SELECT * FROM SEMANTIC_VIEW(
    SV_DEVICE_ANALYTICS
    DIMENSIONS device_status, ml_risk_level
    METRICS total_devices, predicted_failures, wifi_password_issues
);

SELECT * FROM SEMANTIC_VIEW(
    SV_MAINTENANCE_OPERATIONS
    DIMENSIONS priority, issue_type
    METRICS total_work_orders, remote_fix_rate, total_cost_savings
);

SELECT * FROM SEMANTIC_VIEW(
    SV_BUSINESS_IMPACT
    METRICS total_revenue_loss, avg_nps_score, projected_annual_savings
);

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- 
-- BEFORE (10 views): SV_DEVICE_FLEET, SV_MAINTENANCE_ANALYTICS, SV_BUSINESS_IMPACT,
--                    SV_OPERATIONS, SV_ROI_ANALYSIS, SV_EXTERNAL_ACTIONS, 
--                    SV_CURRENT_DOWNTIME, SV_LAST_GASP_ANALYSIS, SV_DEVICE_TRIAGE,
--                    SV_ML_PREDICTIONS
--
-- AFTER (3 views):
--   1. SV_DEVICE_ANALYTICS - All device queries (health, predictions, failure classification)
--   2. SV_MAINTENANCE_OPERATIONS - All service queries (work orders, tickets, technicians)
--   3. SV_BUSINESS_IMPACT - All financial queries (revenue, satisfaction, ROI)
--
-- Benefits:
--   - Fewer views = LLM chooses correctly more often
--   - RELATIONSHIPS enable cross-entity queries within a view
--   - FACTS provide computed columns for aggregation
--   - Synonyms on tables improve discoverability
--   - Star schema pattern per Snowflake best practices
--
