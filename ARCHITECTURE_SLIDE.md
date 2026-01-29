# Snowflake Intelligence: Device Maintenance Assistant

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                     Device Maintenance Assistant on Snowflake Intelligence                   │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│  ┌──────────────────────────────────────────────────────────┐    ┌────────────────────────┐ │
│  │                                                          │    │    SI Native Tools     │ │
│  │                     Cortex Agents                        │    ├────────────────────────┤ │
│  │                                                          │    │ ┌──────────┐ ┌───────┐ │ │
│  │      Orchestration, Tool Use, Reflect, Monitor, Iterate  │    │ │Visualiz- │ │Coding │ │ │
│  │                                                          │    │ │  ation   │ │       │ │ │
│  └──────────────────────────────────────────────────────────┘    │ └──────────┘ └───────┘ │ │
│                              │                                   │ ┌──────────┐ ┌───────┐ │ │
│       ┌──────────────────────┼──────────────────────┐            │ │   Web    │ │Custom │ │ │
│       │                      │                      │            │ │  Search  │ │ Tools │ │ │
│       ▼                      ▼                      ▼            │ └──────────┘ └───────┘ │ │
│                                                                  └────────────────────────┘ │
├─────────────────┬─────────────────────┬─────────────────────┬───────────────────────────────┤
│                 │                     │                     │                               │
│  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐  ┌───────────────────┐ │
│  │  Cortex Analyst   │  │  Cortex Analyst   │  │  Cortex Analyst   │  │   Cortex Search   │ │
│  │ Device Analytics  │  │   Maintenance     │  │  Business Impact  │  │ Knowledge Base    │ │
│  │    Assistant      │  │    Assistant      │  │    Assistant      │  │    Assistant      │ │
│  ├───────────────────┤  ├───────────────────┤  ├───────────────────┤  ├───────────────────┤ │
│  │ SV_DEVICE_        │  │ SV_MAINTENANCE_   │  │ SV_BUSINESS_      │  │ Maintenance       │ │
│  │ ANALYTICS         │  │ OPERATIONS        │  │ IMPACT            │  │ Knowledge Base    │ │
│  ├───────────────────┤  ├───────────────────┤  ├───────────────────┤  ├───────────────────┤ │
│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│ │
│  ││Device  ││Device ││  ││Work    ││Maint- ││  ││Facility││Customer│  ││Trouble-││Device ││ │
│  ││Inven-  ││Tele-  ││  ││Orders  ││enance ││  ││Revenue ││Satisf- ││  ││shooting││Manuals││ │
│  ││tory    ││metry  ││  ││        ││History││  ││        ││action  ││  ││Guides  ││   📄  ││ │
│  │└────────┘└───────┘│  │└────────┘└───────┘│  │└────────┘└───────┘│  │└────────┘└───────┘│ │
│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│  │┌────────┐┌───────┐│ │
│  ││ML Pre- ││Last   ││  ││Techni- ││Resolu-││  ││ROI     ││SLA    ││  ││Error   ││Install-││ │
│  ││dictions││Gasp   ││  ││cians   ││tion   ││  ││Metrics ││Metrics││  ││Codes   ││ation  ││ │
│  ││        ││Events ││  ││        ││Actions││  ││        ││       ││  ││   📄   ││Guides ││ │
│  │└────────┘└───────┘│  │└────────┘└───────┘│  │└────────┘└───────┘│  │└────────┘└───────┘│ │
│  │┌────────┐         │  │┌────────┐         │  │                   │  │                   │ │
│  ││Device  │         │  ││Ticket  │         │  │                   │  │                   │ │
│  ││Downtime│         │  ││Queue   │         │  │                   │  │                   │ │
│  │└────────┘         │  │└────────┘         │  │                   │  │                   │ │
│  └───────────────────┘  └───────────────────┘  └───────────────────┘  └───────────────────┘ │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Slide Content (for PowerPoint/Keynote)

### Title
**Snowflake Intelligence: Device Maintenance Assistant**

### Subtitle Banner
Device Maintenance Assistant on Snowflake Intelligence

### Center Box - Cortex Agents
**Cortex Agents**
Orchestration, Tool Use, Reflect, Monitor, Iterate

### Right Box - SI Native Tools
| Visualization | Coding |
|---------------|--------|
| Web Search | Custom Tools |

---

### Bottom Row - Four Assistants

#### 1. Cortex Analyst: Device Analytics Assistant
**Semantic View:** SV_DEVICE_ANALYTICS

| Tables |
|--------|
| Device Inventory | Device Telemetry |
| ML Predictions | Last Gasp Events |
| Device Downtime | |

#### 2. Cortex Analyst: Maintenance Assistant  
**Semantic View:** SV_MAINTENANCE_OPERATIONS

| Tables |
|--------|
| Work Orders | Maintenance History |
| Technicians | Resolution Actions |
| Ticket Queue | |

#### 3. Cortex Analyst: Business Impact Assistant
**Semantic View:** SV_BUSINESS_IMPACT

| Tables |
|--------|
| Facility Revenue | Customer Satisfaction |
| ROI Metrics | SLA Metrics |

#### 4. Cortex Search: Knowledge Base Assistant
**Search Service:** Maintenance Knowledge Base

| Documents |
|-----------|
| Troubleshooting Guides 📄 | Device Manuals 📄 |
| Error Codes 📄 | Installation Guides 📄 |

---

## Color Scheme (matching Raven slide)

| Component | Color |
|-----------|-------|
| Title Banner | Magenta/Pink (#E91E8C) |
| Cortex Agents Box | Gray (#A0A0A0) |
| SI Native Tools | Orange (#FF9900) |
| Cortex Analyst Headers | Dark Blue (#1E3A5F) |
| Semantic View Bars | Teal/Cyan (#00B4D8) |
| Cortex Search Header | Teal (#008B8B) |
| Table Cells | Light Gray with grid lines |

---

## Key Differentiators for Device Maintenance Demo

| Feature | Implementation |
|---------|----------------|
| **Predictive ML** | XGBoost models predict failures 48h in advance |
| **Real-time Inference** | MODEL!PREDICT() in SQL views |
| **Multi-modal Analysis** | Structured data + unstructured docs |
| **Operational Integration** | Dynamic Tables auto-refresh predictions |
