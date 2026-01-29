# 🏗️ Predictive Maintenance Architecture

**Purpose:** Drive implementation conversation with customer  
**Goal:** Identify gaps, confirm data sources, validate integration points

---

## 📊 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                    DATA SOURCES                                          │
│  (What the company needs to provide)                                                   │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │   IoT Platform   │  │   Ad Platform    │  │    ServiceNow    │  │   CRM/Surveys    │ │
│  │  (Device Mgmt)   │  │  (Revenue Data)  │  │  (Work Orders)   │  │   (Feedback)     │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘ │
│           │                     │                     │                     │           │
│           ▼                     ▼                     ▼                     ▼           │
│  • Device inventory     • CPM rates          • Maintenance tickets   • NPS surveys     │
│  • Telemetry stream     • Impression data    • Resolution notes      • Provider ratings│
│  • Heartbeat/status     • Contract terms     • Technician data       • Complaints      │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
                                          │
                                          │ Data Ingestion
                                          │ (Snowpipe, Kafka, Batch)
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              SNOWFLAKE DATA PLATFORM                                     │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                           RAW DATA LAYER (Bronze)                                   ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   ││
│  │  │   DEVICE_   │ │   DEVICE_   │ │MAINTENANCE_ │ │  AD_REVENUE │ │  PROVIDER_  │   ││
│  │  │  INVENTORY  │ │  TELEMETRY  │ │   HISTORY   │ │    DATA     │ │  FEEDBACK   │   ││
│  │  │   (100)     │ │   (72K)     │ │    (24)     │ │    (new)    │ │    (14)     │   ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
│                                          │                                               │
│                                          ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                         ANALYTICS LAYER (Silver)                                    ││
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   ││
│  │  │ V_DEVICE_HEALTH │ │ V_MAINTENANCE_  │ │  V_REVENUE_     │ │  V_CUSTOMER_    │   ││
│  │  │    _SUMMARY     │ │   ANALYTICS     │ │    IMPACT       │ │  SATISFACTION   │   ││
│  │  │ (Health scores, │ │ (MTTR, costs,   │ │ (Revenue loss,  │ │ (NPS, ratings,  │   ││
│  │  │  risk levels)   │ │  remote rate)   │ │  uptime %)      │ │  follow-ups)    │   ││
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘ └─────────────────┘   ││
│  │                                                                                      ││
│  │  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐                        ││
│  │  │ V_FAILURE_      │ │ V_ROI_ANALYSIS  │ │ V_EXECUTIVE_    │                        ││
│  │  │  PREDICTIONS    │ │ (Annual costs,  │ │   DASHBOARD     │                        ││
│  │  │ (48-hr predict) │ │  savings proj)  │ │ (All KPIs)      │                        ││
│  │  └─────────────────┘ └─────────────────┘ └─────────────────┘                        ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
│                                          │                                               │
│                                          ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                          AI/ML LAYER (Gold)                                         ││
│  │                                                                                      ││
│  │  ┌───────────────────────────────────────────────────────────────────────────────┐  ││
│  │  │                      SEMANTIC VIEWS (Cortex Analyst)                          │  ││
│  │  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐          │  ││
│  │  │  │ SV_DEVICE_   │ │SV_MAINTENANCE│ │SV_BUSINESS_  │ │ SV_ROI_      │          │  ││
│  │  │  │    FLEET     │ │  _ANALYTICS  │ │   IMPACT     │ │  ANALYSIS    │          │  ││
│  │  │  │ (NL→SQL)     │ │  (NL→SQL)    │ │  (NL→SQL)    │ │  (NL→SQL)    │          │  ││
│  │  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘          │  ││
│  │  └───────────────────────────────────────────────────────────────────────────────┘  ││
│  │                                                                                      ││
│  │  ┌───────────────────────────────────────────────────────────────────────────────┐  ││
│  │  │                      CORTEX SEARCH (Knowledge Base)                           │  ││
│  │  │  ┌────────────────────────────┐ ┌────────────────────────────┐                │  ││
│  │  │  │  TROUBLESHOOTING_SEARCH_SVC│ │ MAINTENANCE_HISTORY_SEARCH │                │  ││
│  │  │  │  (Fix procedures)          │ │ (Past incidents)           │                │  ││
│  │  │  └────────────────────────────┘ └────────────────────────────┘                │  ││
│  │  └───────────────────────────────────────────────────────────────────────────────┘  ││
│  │                                                                                      ││
│  │  ┌───────────────────────────────────────────────────────────────────────────────┐  ││
│  │  │                      CORTEX ML (Predictive Models)                            │  ││
│  │  │  ┌────────────────────────────┐ ┌────────────────────────────┐                │  ││
│  │  │  │  Failure Classification    │ │  Anomaly Detection         │                │  ││
│  │  │  │  (When will it fail?)      │ │  (What's unusual?)         │                │  ││
│  │  │  └────────────────────────────┘ └────────────────────────────┘                │  ││
│  │  └───────────────────────────────────────────────────────────────────────────────┘  ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
│                                          │                                               │
│                                          ▼                                               │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐│
│  │                         CORTEX AGENT (Orchestration)                                ││
│  │  ┌───────────────────────────────────────────────────────────────────────────────┐  ││
│  │  │                    DEVICE_MAINTENANCE_AGENT                                   │  ││
│  │  │                                                                               │  ││
│  │  │  Tools:                          Instructions:                                │  ││
│  │  │  • DeviceFleetAnalytics          • Business context                           │  ││
│  │  │  • MaintenanceAnalytics          • Tool selection logic                       │  ││
│  │  │  • BusinessImpactAnalytics       • Response formatting                        │  ││
│  │  │  • ROIAnalytics                  • Workflow orchestration                     │  ││
│  │  │  • TroubleshootingGuide                                                       │  ││
│  │  │  • PastIncidents                 Model:                                       │  ││
│  │  │  • SendDeviceCommand (action)    • Claude 4 Sonnet                            │  ││
│  │  │  • SendAlert (action)                                                         │  ││
│  │  │  • CreateServiceNowIncident      Profile:                                     │  ││
│  │  │                                  • "Device Maintenance Assistant"             │  ││
│  │  └───────────────────────────────────────────────────────────────────────────────┘  ││
│  └─────────────────────────────────────────────────────────────────────────────────────┘│
│                                          │                                               │
└──────────────────────────────────────────┼──────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              EXTERNAL INTEGRATIONS                                       │
│  (Actions triggered by the agent)                                                       │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Device Mgmt API │  │    ServiceNow    │  │   Slack/Teams    │  │    PagerDuty     │ │
│  │  (Remote cmds)   │  │  (Work orders)   │  │    (Alerts)      │  │  (Escalation)    │ │
│  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘ │
│           │                     │                     │                     │           │
│           └─────────────────────┴─────────────────────┴─────────────────────┘           │
│                                          │                                               │
│                              External Functions (Snowflake)                             │
│                              • Secure API calls                                          │
│                              • RBAC governed                                             │
│                              • Audit logged                                              │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                USER INTERFACES                                           │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐ │
│  │   Snowflake      │  │   Streamlit      │  │   Mobile App     │  │    API/SDK       │ │
│  │  Intelligence    │  │   (Custom UI)    │  │  (Technicians)   │  │  (Programmatic)  │ │
│  │  (Chat UI)       │  │                  │  │                  │  │                  │ │
│  └──────────────────┘  └──────────────────┘  └──────────────────┘  └──────────────────┘ │
│                                                                                          │
│  Personas: Executive | Operations | Field Tech | Data Analyst                           │
│                                                                                          │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Process Flow: Predictive Maintenance Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                           OBSERVE → ORIENT → DECIDE → ACT                               │
└─────────────────────────────────────────────────────────────────────────────────────────┘

     ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
     │   OBSERVE    │      │    ORIENT    │      │    DECIDE    │      │     ACT      │
     │              │      │              │      │              │      │              │
     │ Collect data │ ──▶  │ Analyze &    │ ──▶  │ AI recommends│ ──▶  │ Execute fix  │
     │ from devices │      │ predict      │      │ action       │      │ or dispatch  │
     └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
           │                     │                     │                     │
           ▼                     ▼                     ▼                     ▼
     ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
     │ • Telemetry  │      │ • Health     │      │ • Remote vs  │      │ • API call   │
     │   stream     │      │   scoring    │      │   dispatch   │      │   to device  │
     │ • Heartbeats │      │ • Risk       │      │ • Priority   │      │ • ServiceNow │
     │ • Errors     │      │   levels     │      │   ranking    │      │   ticket     │
     │ • Status     │      │ • Failure    │      │ • KB lookup  │      │ • Slack      │
     │              │      │   prediction │      │ • Past       │      │   alert      │
     │              │      │ • Pattern    │      │   incidents  │      │ • Audit log  │
     │              │      │   detection  │      │              │      │              │
     └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
           │                     │                     │                     │
           │                     │                     │                     │
     ┌─────┴─────────────────────┴─────────────────────┴─────────────────────┴─────┐
     │                                                                              │
     │                         CONTINUOUS LEARNING LOOP                             │
     │                                                                              │
     │   Outcome tracked → Model accuracy validated → Thresholds tuned              │
     │                                                                              │
     └──────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 Data Source Inventory

### What the Company Needs to Provide

| Data Source | System | Data Elements | Refresh Rate | Priority |
|-------------|--------|---------------|--------------|----------|
| **Device Inventory** | IoT Platform | Device ID, model, location, install date, firmware | Daily | 🔴 Critical |
| **Device Telemetry** | IoT Platform | CPU, memory, temp, network, errors, heartbeat | Hourly/Real-time | 🔴 Critical |
| **Maintenance History** | ServiceNow | Tickets, resolution notes, costs, technicians | Real-time | 🔴 Critical |
| **Ad Revenue** | Google Ad Manager | CPM rates, impressions, revenue per device | Daily | 🟡 High |
| **Provider Feedback** | CRM/Qualtrics | NPS, satisfaction, complaints | Weekly | 🟡 High |
| **Work Orders** | ServiceNow | Open tickets, assignments, priorities | Real-time | 🟡 High |
| **Technician Data** | HR/Scheduling | Roster, locations, availability, skills | Daily | 🟢 Medium |
| **Troubleshooting KB** | Confluence/SharePoint | Fix procedures, success rates | Monthly | 🟢 Medium |

---

## 🔧 Snowflake Features Used

### Core Platform

| Feature | Purpose | How We Use It |
|---------|---------|---------------|
| **Snowflake Tables** | Data storage | Device inventory, telemetry, maintenance history |
| **Views** | Analytics layer | Health summaries, ROI calculations, predictions |
| **Secure Views** | Row-level security | Limit data by facility/region if needed |
| **Time Travel** | Data recovery | Audit historical states, debug issues |

### AI/ML (Cortex)

| Feature | Purpose | How We Use It |
|---------|---------|---------------|
| **Cortex Analyst** | Natural language → SQL | Query device health, costs, revenue |
| **Semantic Views** | Business glossary | Define metrics, dimensions, relationships |
| **Cortex Search** | Document retrieval | Find troubleshooting procedures, past incidents |
| **Cortex ML (future)** | Predictive models | Failure classification, anomaly detection |
| **Cortex Agents** | Orchestration | Multi-tool reasoning, action execution |

### Data Integration

| Feature | Purpose | How We Use It |
|---------|---------|---------------|
| **Snowpipe** | Real-time ingestion | Stream telemetry from IoT platform |
| **External Functions** | API calls | Trigger device commands, create tickets |
| **Streams + Tasks** | Event-driven | React to new failures, trigger alerts |
| **Data Sharing** | Partner access | Share insights with pharma partners (optional) |

---

## 🔌 Integration Architecture

### Inbound Data (Into Snowflake)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INBOUND DATA INTEGRATION                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  IoT Platform ──────┐                                                        │
│  (AWS IoT/Azure)    │                                                        │
│                     ├──▶ Snowpipe (S3/Blob) ──▶ DEVICE_TELEMETRY            │
│                     │    or Kafka Connector                                  │
│                     │                                                        │
│  Device Heartbeat ──┘                                                        │
│                                                                              │
│  ServiceNow ────────────▶ Snowflake Native App ──▶ MAINTENANCE_HISTORY      │
│                           or REST → External Stage                           │
│                                                                              │
│  Google Ad Manager ─────▶ Scheduled ETL ──▶ AD_REVENUE_DATA                 │
│                           (Fivetran/Airbyte)                                 │
│                                                                              │
│  CRM (Salesforce) ──────▶ Snowflake Connector ──▶ PROVIDER_FEEDBACK         │
│                           or Data Cloud                                      │
│                                                                              │
│  HR System ─────────────▶ Batch Load ──▶ TECHNICIANS                        │
│                           (Daily CSV/API)                                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Outbound Actions (From Snowflake)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        OUTBOUND ACTION INTEGRATION                           │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  Cortex Agent ─────▶ External Function ─────▶ Device Management API         │
│  (SEND_DEVICE_CMD)   (HTTPS POST)             (Restart, clear cache)        │
│                                                                              │
│  Cortex Agent ─────▶ External Function ─────▶ ServiceNow API                │
│  (CREATE_INCIDENT)   (HTTPS POST)             (Create ticket)               │
│                                                                              │
│  Cortex Agent ─────▶ External Function ─────▶ Slack Webhook                 │
│  (SEND_ALERT)        (HTTPS POST)             (Channel notification)        │
│                                                                              │
│  Cortex Agent ─────▶ External Function ─────▶ PagerDuty API                 │
│  (ESCALATE)          (HTTPS POST)             (On-call alert)               │
│                                                                              │
│  ─────────────────────────────────────────────────────────────────────────  │
│                                                                              │
│  Alternative: Snowflake Tasks ─────▶ Event-driven automation                │
│               Stream on new failures ─────▶ Auto-create tickets              │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## ❓ Discovery Questions

### Data Sources

| Question | Why It Matters |
|----------|----------------|
| **What IoT platform manages your devices?** | Determines telemetry ingestion method |
| **What telemetry do you collect today?** | Identifies available health metrics |
| **How frequently is telemetry captured?** | Affects prediction accuracy |
| **Where is maintenance history stored?** | ServiceNow integration path |
| **Do you track ad revenue per device?** | Enables revenue impact calculations |
| **How do you collect provider feedback?** | NPS/satisfaction data source |

### Current State

| Question | Why It Matters |
|----------|----------------|
| **What's your current dispatch cost?** | Validates $185 assumption |
| **What's your remote fix rate today?** | Baseline for improvement |
| **How many devices are in the fleet?** | Scale considerations |
| **What's your current prediction capability?** | Gap assessment |
| **Who are the users of this system?** | Persona alignment |

### Integration Requirements

| Question | Why It Matters |
|----------|----------------|
| **What's your ServiceNow instance?** | Native app vs API integration |
| **Do you use Slack, Teams, or both?** | Alert channel setup |
| **Who approves automated device commands?** | Governance requirements |
| **What's your data residency requirement?** | Snowflake region selection |
| **Do you have an existing Snowflake account?** | Account setup vs existing |

### Success Criteria

| Question | Why It Matters |
|----------|----------------|
| **What would success look like in 6 months?** | Define measurable outcomes |
| **What's the biggest pain point today?** | Prioritize first use case |
| **Who needs to approve this investment?** | Stakeholder mapping |
| **What's your timeline for implementation?** | Resource planning |

---

## 🚧 Potential Gaps to Discuss

### Data Gaps

| Potential Gap | Impact | Mitigation |
|---------------|--------|------------|
| **No per-device ad revenue** | Can't calculate revenue impact | Use average revenue per device type |
| **Telemetry only daily** | Less accurate predictions | Start with daily, plan for real-time |
| **No historical failures** | Can't train ML models | Use rule-based predictions initially |
| **Incomplete KB** | Troubleshooting less effective | Capture knowledge from senior techs |

### Integration Gaps

| Potential Gap | Impact | Mitigation |
|---------------|--------|------------|
| **No device command API** | Can't trigger remote fixes | Alert only, manual action |
| **ServiceNow not accessible** | Manual work order creation | Use Slack/email instead |
| **Multiple IoT platforms** | Complex data integration | Prioritize primary platform |

### Organizational Gaps

| Potential Gap | Impact | Mitigation |
|---------------|--------|------------|
| **No ML/AI team** | Limited model customization | Use Snowflake Cortex managed models |
| **No data engineering** | Slow data pipeline setup | Snowflake Professional Services |
| **Security concerns** | Delayed approval | Early security review |

---

## 📅 Suggested POC Scope

### Week 1-2: Data Foundation
- [ ] Connect device inventory (1,000 devices)
- [ ] Stream telemetry (30 days history)
- [ ] Import maintenance history
- [ ] Create health score views

### Week 3-4: AI Layer
- [ ] Configure semantic views
- [ ] Set up Cortex Search for KB
- [ ] Create Cortex Agent
- [ ] Test 10 key prompts

### Week 5-6: Validation
- [ ] User testing with 5 stakeholders
- [ ] Measure query accuracy
- [ ] Document integration requirements
- [ ] Build business case

---

## 📊 Architecture Review Checklist

Use this checklist during customer conversation:

### Data Layer
- [ ] Device inventory source confirmed
- [ ] Telemetry stream method defined
- [ ] Maintenance history integration planned
- [ ] Revenue data availability confirmed
- [ ] Feedback/NPS source identified

### Analytics Layer
- [ ] Health score formula agreed
- [ ] Risk thresholds defined
- [ ] ROI calculation inputs confirmed
- [ ] KPI definitions aligned

### AI Layer
- [ ] Semantic model scope defined
- [ ] Knowledge base content identified
- [ ] Prediction requirements captured
- [ ] Model accuracy targets set

### Integration Layer
- [ ] Inbound data pipelines designed
- [ ] Outbound action endpoints confirmed
- [ ] Security/governance requirements captured
- [ ] User access model defined

### User Experience
- [ ] Personas validated
- [ ] Key prompts refined
- [ ] UI requirements captured
- [ ] Mobile needs identified

