# 🏗️ Predictive Maintenance Architecture Overview

**For: Executive Presentation**

---

## Solution Architecture (One Page)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           YOUR DATA SOURCES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   📡 IoT Platform    💰 Ad Platform    🔧 ServiceNow    📊 CRM/Surveys      │
│   ─────────────────  ─────────────────  ─────────────────  ─────────────────│
│   • Device inventory • CPM rates       • Work orders     • NPS scores       │
│   • Telemetry stream • Impressions     • Ticket history  • Satisfaction     │
│   • Heartbeat/status • Revenue data    • Technician data • Complaints       │
│                                                                              │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE DATA CLOUD                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  📊 DATA LAYER                                                      │    │
│  │  ───────────────────────────────────────────────────────────────────│    │
│  │  Device Inventory │ Telemetry │ Maintenance │ Revenue │ Feedback   │    │
│  │      (100)        │  (72K)    │    (24)     │   ($)   │   (14)     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  🧠 CORTEX AI LAYER                                                 │    │
│  │  ───────────────────────────────────────────────────────────────────│    │
│  │                                                                     │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │    │
│  │  │   CORTEX    │  │   CORTEX    │  │   CORTEX    │                 │    │
│  │  │   ANALYST   │  │   SEARCH    │  │     ML      │                 │    │
│  │  │─────────────│  │─────────────│  │─────────────│                 │    │
│  │  │ Natural     │  │ Knowledge   │  │ Failure     │                 │    │
│  │  │ Language    │  │ Base        │  │ Prediction  │                 │    │
│  │  │ → SQL       │  │ Retrieval   │  │ Models      │                 │    │
│  │  └─────────────┘  └─────────────┘  └─────────────┘                 │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                    │                                         │
│                                    ▼                                         │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  🤖 CORTEX AGENT                                                    │    │
│  │  ───────────────────────────────────────────────────────────────────│    │
│  │                                                                     │    │
│  │  "Device Maintenance Assistant"                                     │    │
│  │                                                                     │    │
│  │  Tools:                        Capabilities:                        │    │
│  │  • Fleet Analytics             • Answer questions in English        │    │
│  │  • Maintenance Analytics       • Query structured data              │    │
│  │  • Revenue Impact              • Search knowledge base              │    │
│  │  • Troubleshooting Guide       • Trigger automated actions          │    │
│  │  • Device Commands             • Log all actions for audit          │    │
│  │                                                                     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└───────────────────────────────────┬─────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AUTOMATED ACTIONS                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   📱 Device API      📋 ServiceNow     💬 Slack/Teams    🚨 PagerDuty       │
│   ─────────────────  ─────────────────  ─────────────────  ─────────────────│
│   Remote restart     Create ticket     Alert ops team    Escalate critical  │
│   Clear cache        Assign tech       Notify manager    On-call page       │
│   Reset network      Track status      Post updates      Incident mgmt      │
│                                                                              │
│                    ↓ All via Snowflake External Functions ↓                 │
│                    ↓ Same RBAC • Same Audit Trail • Secure ↓                │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔧 Snowflake Components Used

| Component | What It Does | Demo Example |
|-----------|--------------|--------------|
| **Cortex Analyst** | Natural language → SQL queries | "Show me devices at risk" |
| **Semantic Views** | Business glossary for AI | Health score, revenue impact definitions |
| **Cortex Search** | Semantic search over documents | Find troubleshooting procedures |
| **Cortex Agents** | Orchestrate tools + take actions | Query data + send device commands |
| **External Functions** | Secure API calls to external systems | Restart device, create ServiceNow ticket |

---

## 📊 Data Used in Demo

| Data | Records | Source System | What It Enables |
|------|---------|---------------|-----------------|
| **Device Inventory** | 100 devices | IoT Platform | Fleet overview, location, model |
| **Device Telemetry** | 72,000 readings | IoT Platform | Health scores, risk prediction |
| **Maintenance History** | 24 tickets | ServiceNow | Cost analysis, MTTR tracking |
| **Downtime Records** | 10 incidents | Monitoring | Revenue impact calculation |
| **Provider Feedback** | 14 responses | CRM/Surveys | NPS, satisfaction tracking |
| **Troubleshooting KB** | 10 procedures | Confluence | Fix instructions, success rates |

---

## 🎯 Key Questions This Enables

| Persona | Question | Snowflake Component |
|---------|----------|---------------------|
| **Executive** | "What's our fleet health and revenue impact?" | Cortex Analyst → Semantic View |
| **Operations** | "Which devices will fail in 48 hours?" | Cortex Analyst → Prediction View |
| **Field Tech** | "How do I fix this display issue?" | Cortex Search → Knowledge Base |
| **Automated** | "Restart services on device DEV-018" | Cortex Agent → External Function |

---

## 🔄 The OODA Loop

```
    ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
    │   OBSERVE    │      │    ORIENT    │      │    DECIDE    │      │     ACT      │
    │              │      │              │      │              │      │              │
    │ Collect      │ ──▶  │ Analyze &    │ ──▶  │ AI recommends│ ──▶  │ Execute fix  │
    │ telemetry    │      │ predict      │      │ action       │      │ or dispatch  │
    └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
          │                     │                     │                     │
          ▼                     ▼                     ▼                     ▼
    ┌──────────────┐      ┌──────────────┐      ┌──────────────┐      ┌──────────────┐
    │ IoT stream   │      │ Health score │      │ Remote vs    │      │ API call     │
    │ Heartbeats   │      │ Risk level   │      │ dispatch     │      │ ServiceNow   │
    │ Errors       │      │ Prediction   │      │ KB lookup    │      │ Slack alert  │
    └──────────────┘      └──────────────┘      └──────────────┘      └──────────────┘
```

---

## 💰 Business Outcomes

| Outcome | Metric | How Achieved |
|---------|--------|--------------|
| **Revenue Protection** | $0 downtime loss | Predict failures before they happen |
| **Cost Reduction** | 52% ($96M/year) | Remote fixes instead of dispatches |
| **Faster Resolution** | 8x faster MTTR | 30 min remote vs 4+ hr dispatch |
| **Prediction Accuracy** | >85% | ML on 30 days of telemetry |

---

## ❓ Discussion Points

1. **Data Sources**: What IoT platform manages your 500K devices?
2. **Integration**: Do you have APIs for remote device commands?
3. **Governance**: What approval workflow for automated actions?
4. **Gaps**: What's missing from this architecture?

