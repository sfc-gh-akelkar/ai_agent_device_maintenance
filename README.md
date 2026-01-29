# Predictive Device Maintenance

**AI-Powered IoT Device Maintenance for HealthScreen Displays**

A Snowflake Cortex Agent demo for **Snowflake Intelligence** showcasing how AI can predict device failures, classify failure causes (Wi-Fi vs hardware), and recommend fixes—reducing manual field dispatches.

---

## Overview

The company operates **150,000 HealthScreen devices** across **30,000 provider offices** nationwide. 

### The Challenge

| Pain Point | Impact |
|------------|--------|
| **10%+ Offline Rate** | ~15,000 devices offline at any time |
| **Wi-Fi Dependency** | 90%+ devices run on provider Wi-Fi (not company-managed) |
| **Wrong Triage** | Dispatching technicians for Wi-Fi password changes |
| **High Costs** | Field technician dispatches cost $150-300+ per visit |
| **Lost Revenue** | Device downtime = lost advertising impressions |
| **Provider Churn** | 7-8% annual churn linked to device reliability |

### The Solution

| Capability | Technology |
|------------|------------|
| Natural language queries | Cortex Analyst + Semantic Views |
| Knowledge base search | Cortex Search |
| **Failure classification** | **"Last Gasp" telemetry analysis** |
| Automated actions | Custom stored procedures |
| Predictive analytics | ML-ready data foundation |

### Business Impact

| Metric | Value |
|--------|-------|
| Fleet Size | 150,000 devices across 30,000 offices |
| Annual Cost Baseline | $55M (field dispatches) |
| Projected Savings | $29M (52% reduction) |
| Phase 1 Target | 95% uptime (up from ~90%) |
| Remote Fix Rate | 60%+ |
| Prediction Accuracy | >85% |

### Key Innovation: "Last Gasp" Failure Classification

When a device goes offline, the AI analyzes its final telemetry readings to classify the cause:

| Signal Pattern | Classified Cause | Resolution Path |
|----------------|------------------|----------------|
| **SUDDEN_DROP** in Wi-Fi signal | Wi-Fi Password Change | **Call office** (10 min) |
| **STABLE** signal + high CPU/errors | Hardware Failure | **Dispatch tech** (4+ hrs) |
| **GRADUAL_DECLINE** + multiple devices | Network Outage | **Wait & monitor** |
| **STABLE** + instant disconnect | Power Loss | **Remote restart** |

> *"This is the key insight: 90%+ of devices run on provider Wi-Fi. When a provider changes their password, the device loses connection. Without failure classification, we'd dispatch a $185 technician for a problem that can be fixed with a 10-minute phone call."*

---

## Project Structure

```
ai_agent_device_maintenance/
├── setup/
│   ├── 01_create_database_and_data.sql    # Database, tables, sample data
│   ├── 02_create_semantic_views.sql       # Semantic views for Cortex Analyst
│   ├── 03_create_cortex_search.sql        # Knowledge base search services
│   ├── 04_create_agent.sql                # Agent configuration
│   ├── 05_predictive_simulation.sql       # Predictive analytics views
│   ├── 05b_ml_prediction_views.sql        # ML prediction views (bridge script)
│   ├── 06_enhanced_capabilities.sql       # Batch commands, triage, impact analysis
│   └── 07_expanded_training_data.sql      # Optional: 6 months training data
├── DEMO_SCRIPT.md                         # 20-minute demo walkthrough
├── ARCHITECTURE.md                        # Implementation architecture & diagrams
└── README.md                              # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with **Cortex** access
- ACCOUNTADMIN role (for initial setup)
- The demo uses the `SF_INTELLIGENCE_DEMO` role (created automatically)

### Step 1: Run SQL Scripts

Execute in order in Snowsight:

```sql
-- CORE SETUP (Required)
-- ======================
-- 1. Create role, database, tables, and sample data
-- Run: setup/01_create_database_and_data.sql

-- 2. Create Snowflake Semantic Views
-- Run: setup/02_create_semantic_views.sql

-- 3. Create Cortex Search services
-- Run: setup/03_create_cortex_search.sql

-- 4. Create the agent
-- Run: setup/04_create_agent.sql

-- 5. Create predictive failure detection views
-- Run: setup/05_predictive_simulation.sql

-- 5b. Create ML prediction views (bridges 05 to 06)
-- Run: setup/05b_ml_prediction_views.sql

-- 6. Create enhanced capabilities (batch commands, triage, impact)
-- Run: setup/06_enhanced_capabilities.sql

-- OPTIONAL (for more training data - DESTRUCTIVE)
-- ================================================
-- 7. Expand training data to 6 months (replaces telemetry/maintenance data)
-- Run: setup/07_expanded_training_data.sql
-- Then re-run: setup/05b_ml_prediction_views.sql
```

### Step 2: Access via Snowflake Intelligence

1. Navigate to **AI & ML → Snowflake Intelligence**
2. Select **Device Maintenance Assistant**
3. Start asking questions!

---

## 🎬 Demo Script

For the complete **20-minute demo script** with talking points and prompts, see:

📄 **[DEMO_SCRIPT.md](DEMO_SCRIPT.md)**

### Key Personas

| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | ROI, fleet health, revenue protection |
| Operations Center | Risk triage, predictions, dispatch decisions |
| Field Technician | Work orders, troubleshooting, repair guidance |

## Sample Prompts

```
# Executive
Give me a summary of our device fleet health and business impact
What's our annual field service cost and projected savings?

# Operations - Failure Classification (KEY DIFFERENTIATOR)
Why did device DEV-025 go offline? Is it a Wi-Fi password change?
How many offline devices are due to Wi-Fi changes vs hardware failures?

# Operations - Triage
Which devices have critical or high risk levels right now?
Can any of these be fixed remotely?

# Technician
What work orders are assigned to Marcus Johnson today?
What's wrong with device DEV-003 and how do I fix it?
```

---

## Predictive Capabilities

### Tables

| Table | Records (Base) | Records (Expanded*) | Description |
|-------|----------------|---------------------|-------------|
| DEVICE_INVENTORY | 100 | 100 | Device master data with NETWORK_TYPE |
| DEVICE_TELEMETRY | ~72,000 | ~432,000 | Hourly health metrics + Wi-Fi signal |
| DEVICE_LAST_GASP | 5 | 5 | Final readings before offline (failure classification) |
| MAINTENANCE_HISTORY | 24 | ~250 | Service tickets |
| TROUBLESHOOTING_KB | 14 | 14 | Fix procedures (incl. Wi-Fi troubleshooting) |
| WORK_ORDERS | 8 | 8 | Active work orders |
| TECHNICIANS | 6 | 6 | Field team |

*Run `07_expanded_training_data.sql` for 6 months of ML-ready training data

### Key Views

| View | Purpose |
|------|---------|
| V_DEVICE_HEALTH_SUMMARY | Current health with risk scores |
| V_MAINTENANCE_ANALYTICS | Ticket analytics with cost savings |
| V_FAILURE_PREDICTIONS | AI-predicted failures |
| V_LAST_GASP_ANALYSIS | **Failure cause classification** |
| V_ROI_ANALYSIS | Cost baseline and savings |
| V_ML_FAILURE_PREDICTIONS | ML model predictions with risk levels |
| V_DEVICE_ML_FEATURES | Current feature values for each device |
| V_DEVICE_TRIAGE | Remote fix vs dispatch classification |
| V_PREDICTED_IMPACT_SUMMARY | Business impact of predicted failures |
| V_COST_BY_FAILURE_CAUSE | Cost breakdown by failure type |

### Agent Tools

| Tool | Type | Purpose |
|------|------|---------|
| DeviceFleetAnalytics | Cortex Analyst | Device health & telemetry |
| MaintenanceAnalytics | Cortex Analyst | Ticket history & costs |
| **LastGaspAnalytics** | **Cortex Analyst** | **Failure classification** |
| ROIAnalytics | Cortex Analyst | Annual costs & ROI |
| TroubleshootingGuide | Cortex Search | Fix procedures |
| PastIncidents | Cortex Search | Historical resolutions |
| SendDeviceCommand | Custom Procedure | Remote device commands |
| SendAlert | Custom Procedure | Slack/PagerDuty alerts |
| CreateServiceNowIncident | Custom Procedure | Work order creation |

---

## 🔮 Predictive Capabilities

### What We Prove

| Capability | How It's Demonstrated |
|------------|----------------------|
| Historical Data for ML | 30+ days of telemetry, maintenance history |
| Feature Engineering | Trend detection, spike flags, derived features |
| Prediction Accuracy | >85% detection rate on historical data |
| 24-48 Hour Lead Time | Advance warning before failures |

### Sample Queries

```sql
-- Devices predicted to fail within 48 hours
SELECT * FROM V_FAILURE_PREDICTIONS 
WHERE PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY FAILURE_PROBABILITY_PCT DESC;

-- Prediction accuracy analysis
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;
```

---

## 💰 Value Drivers

### Operational Cost Reduction

| Benefit | Impact |
|---------|--------|
| Reduced Downtime | Predict issues before they occur |
| Optimized Scheduling | Eliminate unnecessary maintenance |
| Lower Field Costs | Remote fixes vs $185/dispatch |

### Performance Improvements

| Metric | Value |
|--------|-------|
| Faster Insights | 10x faster than batch reporting |
| Query Accuracy | 90% with Cortex AI |
| Extended Asset Life | Proactive maintenance |

### Customer Success Examples

| Customer | Results |
|----------|---------|
| FIIX | 10x improvement in maintenance insights |
| Toyota | Extended equipment life, reduced disruptions |
| Telecom | Reduced field costs, improved SLA compliance |

---

## 📚 References

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Best Practices for Building Cortex Agents](https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/best-practices-to-building-cortex-agents/best-practices-to-building-cortex-agents.md)

---

**Built with ❄️ Snowflake Cortex**
