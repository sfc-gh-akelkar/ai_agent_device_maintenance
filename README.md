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
│   ├── 06_enhanced_capabilities.sql       # Batch commands, triage, impact analysis
│   └── 07_expanded_training_data.sql      # Optional: 6 months training data
├── notebooks/
│   └── ML_Device_Failure_Prediction.ipynb # XGBoost training & Model Registry (REQUIRED)
├── ARCHITECTURE.md                        # Implementation architecture & diagrams
└── README.md                              # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with **Cortex** access
- ACCOUNTADMIN role (for initial setup)
- The demo uses the `SF_INTELLIGENCE_DEMO` role (created automatically)

### Step 1: Run SQL Setup Scripts

Execute these scripts in Snowsight **in order**:

```sql
-- 01_create_database_and_data.sql    -- Database, tables, sample data
-- 02_create_semantic_views.sql       -- Semantic views for Cortex Analyst
-- 03_create_cortex_search.sql        -- Search services for RAG
-- 04_create_agent.sql                -- Agent configuration
-- 05_predictive_simulation.sql       -- Base prediction views
```

### Step 2: Run the ML Notebook (Required - Before Demo)

Open and execute **all cells** in `notebooks/ML_Device_Failure_Prediction.ipynb`:

| What It Does | Snowflake Feature | Output |
|--------------|-------------------|--------|
| Feature engineering (29 features) | SQL window functions | `V_DEVICE_ML_FEATURES` view |
| Train XGBoost classifier | Snowpark ML | `DEVICE_FAILURE_CLASSIFIER` model |
| Train XGBoost regressor | Snowpark ML | `DEVICE_HOURS_TO_FAILURE` model |
| Train Last Gasp classifier | Snowpark ML | `LAST_GASP_CLASSIFIER` model |
| Log models to registry | Model Registry | Versioned, governed models |
| Materialize predictions | MODEL!PREDICT() → Table | **`T_ML_PREDICTIONS` table** |

> **Demo Note**: Run this notebook **before** the demo. During the demo, walk through the notebook to explain the ML pipeline, then use Snowflake Intelligence to query the pre-computed predictions stored in `T_ML_PREDICTIONS`.

### Step 3: Run Enhanced Capabilities

```sql
-- 06_enhanced_capabilities.sql       -- Batch commands, triage, impact analysis
```

### Optional: Expand Training Data

```sql
-- 07_expanded_training_data.sql      -- 6 months of data (DESTRUCTIVE!)
-- Then re-run the notebook for better model accuracy
```

### Step 4: Access via Snowflake Intelligence

1. Navigate to **AI & ML → Snowflake Intelligence**
2. Select **Device Maintenance Assistant**
3. Start asking questions!

---

## Try It Out

Once setup is complete, open **Snowflake Intelligence** and select the **Device Maintenance Assistant**. Here are sample questions organized by persona:

### Executive / Leadership

| Question | What It Shows |
|----------|---------------|
| Give me a summary of our device fleet health and business impact | Fleet overview: online/offline counts, health score, uptime, cost savings |
| How much advertising revenue are we losing from device downtime? | Revenue impact: monthly loss, opportunity cost per 1% uptime improvement |
| What's our annual field service cost and projected savings? | ROI story: $55M baseline, $29M projected savings (52% reduction) |
| How much have we saved this month from remote fixes? | Actual cost avoidance from remote resolutions vs. dispatches |
| What is our customer satisfaction score? | NPS, satisfaction ratings, provider feedback summary |

### Operations Center

| Question | What It Shows |
|----------|---------------|
| Which devices have critical or high risk levels? | Prioritized list of at-risk devices with health scores |
| Why did device DEV-025 go offline? Is it a Wi-Fi password change? | **Last Gasp failure classification** - the key differentiator: classifies cause with confidence level |
| How many offline devices are due to Wi-Fi changes vs hardware failures? | Failure cause breakdown across the fleet |
| Can any of these be fixed remotely? | Smart triage: call office vs. dispatch tech vs. wait and monitor |
| Which devices are predicted to fail in 48 hours? | Proactive maintenance: XGBoost predictions with risk levels |

### Field Technician

| Question | What It Shows |
|----------|---------------|
| What work orders are assigned to Marcus Johnson today? | Technician-specific work queue |
| What's wrong with device DEV-003 and how do I fix it? | Diagnosis + troubleshooting steps from knowledge base |
| Attempt a remote restart on device DEV-003 | Closed-loop action: agent executes command and logs audit trail |

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

### Semantic Views (Consolidated Architecture)

Following [Snowflake best practices](https://www.snowflake.com/en/developers/guides/best-practices-to-building-cortex-agents/#semantic-views-data-level), we use **3 consolidated semantic views** with 3-5 tables each:

| Semantic View | Tables Joined | Use Cases |
|---------------|---------------|-----------|
| **SV_DEVICE_ANALYTICS** | devices, predictions, last_gasp, downtime | Fleet health, ML predictions, failure classification, active downtime |
| **SV_MAINTENANCE_OPERATIONS** | work_orders, tickets, technicians, actions | Work orders, tickets, MTTR, technician dispatch, action audit |
| **SV_BUSINESS_IMPACT** | revenue, satisfaction, roi | Revenue loss, NPS, ROI projections |

> *"Fewer views = LLM chooses correctly more often. Each view uses RELATIONSHIPS for proper joins."*

### Agent Tools

| Tool | Type | Purpose |
|------|------|---------|
| **DeviceAnalytics** | Cortex Analyst | Device health, predictions, failure classification, downtime |
| **MaintenanceOperations** | Cortex Analyst | Work orders, tickets, technicians, action audit |
| **BusinessImpact** | Cortex Analyst | Revenue, satisfaction, ROI |
| TroubleshootingGuide | Cortex Search | Fix procedures |
| PastIncidents | Cortex Search | Historical resolutions |
| SendDeviceCommand | Custom Procedure | Remote device commands |
| SendAlert | Custom Procedure | Slack/PagerDuty alerts |
| CreateServiceNowIncident | Custom Procedure | Work order creation |
| BatchDeviceCommand | Custom Procedure | Bulk device commands |

---

## 🤖 ML Model Showcase (Notebook)

The Jupyter notebook `notebooks/ML_Device_Failure_Prediction.ipynb` is a **complete ML pipeline**:

### Feature Engineering (29 Features)

| Category | Features | Why They Matter |
|----------|----------|-----------------|
| **Current State** | CPU temp, usage, memory, errors | Snapshot of device health |
| **24h Rolling Stats** | Averages, max, min over 24 hours | Smooths noise, captures sustained issues |
| **7-day Baseline** | Longer-term averages | Establishes normal behavior |
| **TREND Features** | CPU_TEMP_TREND, MEMORY_TREND, ERROR_ACCELERATION | **CRITICAL**: Degradation patterns predict failures |
| **Device Attributes** | Age, days since maintenance, network type | Static risk factors |

### XGBoost Models

| Model | Type | Purpose | Metrics |
|-------|------|---------|---------|
| `DEVICE_FAILURE_CLASSIFIER` | Binary Classification | Will device fail in 48h? | Accuracy, F1, ROC-AUC |
| `DEVICE_HOURS_TO_FAILURE` | Regression | Hours until failure | MAE, RMSE, R² |
| `LAST_GASP_CLASSIFIER` | Multi-class | Why did device go offline? | Accuracy per cause |

### Model Registry & Operationalization

```python
# Training (in notebook)
clf_model = xgb.XGBClassifier(...)
clf_model.fit(X_train, y_train)

# Log to Snowflake Model Registry
registry.log_model(clf_model, model_name="DEVICE_FAILURE_CLASSIFIER", ...)
```

```sql
-- Inference (in SQL views)
SELECT 
    DEVICE_ID,
    DEVICE_FAILURE_CLASSIFIER!PREDICT(
        CPU_TEMP, CPU_USAGE, MEMORY_PCT, ...
    ):output_feature_0 as WILL_FAIL_48H
FROM V_DEVICE_ML_FEATURES
```

### Key Insight

> *"TREND features (CPU_TEMP_TREND, ERROR_ACCELERATION) are the most predictive because they capture DEGRADATION patterns 24-48 hours before failure!"*

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
