# Predictive Device Maintenance Demo Script

**Duration:** 20 minutes  
**Audience:** IT Leadership, Operations, Field Services  
**Platform:** Snowflake Intelligence + Cortex Agents

---

## FOCUS Framework Alignment

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| Lost Advertising Revenue | AI Agent Implementation | Revenue Protection |
| High Operational Costs | Automated Remote Resolution | 40-60% Cost Reduction |
| 10%+ Device Offline Rate | AI/ML Predictive Models + Last Gasp Analysis | Target: 95% Uptime (Phase 1) |
| Wi-Fi Dependency (90%+) | Failure Classification | Smart Triage: Call Office vs Dispatch |

---

## KEY CONTEXT: Network Reality

> **CRITICAL CONTEXT (SAY THIS EARLY):** *"The company has 150,000 devices across 30,000 provider offices. Here's the challenge: 90%+ of these devices run on the PROVIDER'S Wi-Fi—not company-managed networks. When a device goes offline, the #1 cause is the provider changed their Wi-Fi password. This changes everything about how we triage and resolve issues."*

| Reality | Implication | Demo Feature |
|---------|-------------|-------------|
| 150K devices, 30K offices | ~5 devices per office avg | Realistic scale projections |
| 90%+ on provider Wi-Fi | No network control | Last gasp analysis for classification |
| 10%+ offline rate (~15K devices) | Major revenue impact | This is the problem we're solving |
| Target: 95% uptime (Phase 1) | Up from ~90% | Achievable, not aspirational |
| 7-8% provider churn | Device issues → lost contracts | Business case for reliability |

---

## Source Systems Being Simulated

> **SAY THIS at demo start:** *"Before we begin, let me briefly explain what we're simulating. These are the source systems that would connect to Snowflake in production:"*

| Source System | What We Simulate | Demo Data | Production Equivalent |
|---------------|------------------|-----------|------------------------|
| **IoT Platform** (AWS IoT, Azure IoT, Particle) | Device inventory, telemetry, heartbeat | `DEVICE_INVENTORY`, `DEVICE_TELEMETRY` | Your device management platform |
| **Ad Platform** (Google Ad Manager, direct contracts) | CPM rates, impressions, revenue | `HOURLY_AD_REVENUE_USD` column | GAM or pharma partner data |
| **Field Service** (ServiceNow, Salesforce FSL) | Work orders, dispatch, resolution | `WORK_ORDERS`, `MAINTENANCE_HISTORY` | ServiceNow or equivalent |
| **CRM/Surveys** (Qualtrics, Salesforce) | NPS, satisfaction, complaints | `PROVIDER_FEEDBACK` | Your survey/CRM system |
| **Knowledge Base** (Confluence, SharePoint) | Troubleshooting procedures | `TROUBLESHOOTING_KB` | Your documentation system |
| **HR/Scheduling** | Technician roster, skills, coverage | `TECHNICIANS` | Your workforce system |
| **Device Management API** | Remote commands (reboot, restart) | `SEND_DEVICE_COMMAND` procedure | Your device API |
| **Alerting** (Slack, PagerDuty) | Notifications, escalations | `SEND_ALERT` procedure | Your notification system |
| **Last Gasp Telemetry** (NEW) | Final readings before offline | `DEVICE_LAST_GASP` | Wi-Fi signal, failure classification |

---

## Attendee Mapping: Who Cares About What

| Attendee | Role | Primary Questions They Care About | Key Metrics | Prompts to Highlight |
|----------|------|-----------------------------------|-------------|---------------------|
| **Mike Walsh** | COO | "What's the operational impact? ROI?" | $29M savings, 52% cost reduction | Q1, Q3, Q4 |
| **Patrick Arnold** | CTO | "Does this scale? Architecture?" | 150K devices, governance, Snowflake native | Q1, Q9 (automated action) |
| **Sharon Patent** | CADO | "Data strategy? Governance?" | Data lineage, audit trail, RBAC | All (emphasize auditability) |
| **Jonathan Richman** | SVP Software & Engineering | "Integration complexity? Build effort?" | Source systems, APIs, implementation | Q9, Architecture diagram |
| **Liberty Holt** | VP Data & Analytics | "Is the data trustworthy? Models accurate?" | Prediction accuracy, SQL verification | Q1, Q8 (prediction accuracy) |
| **Jennifer Kelly** | Sr Director Data Engineering | "How do we build the pipelines?" | Ingestion methods, data hygiene | All (emphasize data sources) |
| **JT Grant** | VP Ad Tech | "How does this protect ad revenue?" | Revenue impact, uptime %, CPM data | Q2 (revenue loss) |
| **Drew Amwoza** | SVP Technology, Architecture & Strategy | "Strategic fit? Long-term vision?" | Cortex ML roadmap, scalability | Q8, Q9, closing |
| **Chloé Varennes** | Director Product Management, AdTech | "User experience? Product integration?" | Natural language, response quality | All prompts |

### 🎯 Engagement Strategy by Attendee

**For Mike Walsh (COO):**
> *"Mike, this next answer shows the annual cost baseline and savings projection—the headline number for your board."*

**For Patrick Arnold (CTO):**
> *"Patrick, notice this runs entirely within Snowflake—no external ML infrastructure to manage, same governance model you already have."*

**For Sharon Patent (CADO):**
> *"Sharon, every answer is auditable. I can show you the SQL the AI generated—complete lineage from question to data."*

**For Jonathan Richman (SVP Engineering):**
> *"Jonathan, the integration architecture uses Snowflake External Functions for API calls—no middleware required."*

**For Liberty Holt (VP Data & Analytics):**
> *"Liberty, let me verify this answer—here's the underlying SQL you'd use to validate the result."*

**For Jennifer Kelly (Sr Director Data Engineering):**
> *"Jennifer, this telemetry would come from your IoT platform via Snowpipe or Kafka. What does your current pipeline look like?"*

**For JT Grant (VP Ad Tech):**
> *"JT, this revenue calculation uses the CPM data from your ad platform. We'd connect to GAM or your direct contracts."*

**For Drew Amwoza (SVP Strategy):**
> *"Drew, the vision here is Cortex ML for predictions + Cortex Agents for orchestration—all native to Snowflake."*

**For Chloé Varennes (Director PM AdTech):**
> *"Chloé, notice how natural the interaction is—no SQL, no dashboard switching. How would this fit your product roadmap?"*

---

## 🏗️ Implementation Mindset: Data Acquisition, Governance, Hygiene

> **Use these talking points throughout the demo to frame the "how would we do this" conversation:**

### Data Acquisition
| Question to Ask | Why It Matters |
|------------------------------|----------------|
| "Where does your device telemetry live today?" | Determines ingestion method (Snowpipe, Kafka, batch) |
| "How frequently is data collected?" | Affects prediction accuracy and cost |
| "Who owns the ad revenue data?" | May require cross-team coordination |

### Data Governance
| Question to Ask | Why It Matters |
|------------------------------|----------------|
| "Who should have access to revenue data?" | RBAC configuration |
| "Are there HIPAA considerations?" | Data masking, row-level security |
| "What audit requirements exist?" | Logging, compliance reporting |

### Data Hygiene
| Question to Ask | Why It Matters |
|------------------------------|----------------|
| "How complete is your device inventory?" | Missing devices = blind spots |
| "Are telemetry values consistent across device types?" | May need normalization |
| "How often are work orders updated in ServiceNow?" | Stale data affects insights |

---

## 📋 Demo Overview

This demo tells a **cohesive story** through 4 personas, with each question flowing naturally to the next:

| Persona | Focus | Time |
|---------|-------|------|
| 🎯 **Executive (C-Suite)** | KPIs, ROI, strategic metrics | 4 min |
| 🖥️ **Operations Center** | Fleet monitoring, predictions, dispatch | 6 min |
| 🔧 **Field Technician** | Work orders, troubleshooting, repair guidance | 4 min |
| 🤖 **AI Agent Demo** | Natural language, conversational AI | 4 min |

---

## 🔑 Rehearsed Questions Checklist

> **These are the core questions we validated. Each one is designed to demonstrate a specific business outcome.**

| # | Question | Business Outcome | Attendees Who Care |
|---|----------|------------------|--------------------------------|
| **Q1** | "Give me a summary of our device fleet health and business impact" | Single pane of glass | Mike Walsh (COO), Patrick Arnold (CTO), Liberty Holt |
| **Q2** | "How much advertising revenue are we losing from device downtime?" | Revenue protection | Mike Walsh (COO), JT Grant (VP Ad Tech), Chloé Varennes |
| **Q3** | "What's our annual field service cost and projected savings?" | ROI justification | Mike Walsh (COO), Patrick Arnold (CTO), Drew Amwoza |
| **Q4** | "How much have we saved this month from remote fixes?" | Proof of value | Mike Walsh (COO), Jonathan Richman, Liberty Holt |
| **Q5** | "What is our customer satisfaction score?" | Retention risk | Mike Walsh (COO), Chloé Varennes |
| **Q6** | "Which devices have critical or high risk levels?" | Actionable intelligence | Jonathan Richman, Jennifer Kelly |
| **Q6b** | "Why did device DEV-025 go offline? Is it a Wi-Fi password change?" | **NEW: Failure classification** | All (key differentiator) |
| **Q7** | "Can any of these be fixed remotely?" | Cost optimization | Jonathan Richman, Jennifer Kelly |
| **Q8** | "Which devices are predicted to fail in 48 hours?" | Proactive maintenance | Drew Amwoza, Liberty Holt, Patrick Arnold |
| **Q9** | "Attempt a remote restart on device DEV-003" | Closed-loop operations | Patrick Arnold (CTO), Sharon Patent (CADO), Drew Amwoza |

### 📊 Expected Results from Rehearsal

| Question | Key Numbers to Expect | Watch Out For |
|----------|----------------------|---------------|
| **Q1** | Health: 71/100, 85 online, 5 degraded, 10 offline (10%), ~90% uptime | 10% offline is the PROBLEM we're solving |
| **Q2** | ~$51K revenue at risk, 10+ devices affected | Explain this is why Phase 1 targets 95% |
| **Q3** | $55M annual cost (150K devices), $29M savings, 52% reduction | Scaled to 150K, not 500K |
| **Q4** | $1,200-1,500 saved this month, 60-70% remote rate | Monthly data may vary |
| **Q6b** | Wi-Fi password change: 92% confidence, SUDDEN_DROP pattern | **KEY DEMO MOMENT** |
| **Q9** | Action logged with timestamp, device ID, command | Show audit trail after |

---

## 🎬 Opening (0:00 - 2:00)

### Setting the Stage

**SAY THIS:**
> "The company operates 150,000 IoT devices—HealthScreen displays—across 30,000 provider offices nationwide. These screens generate **advertising revenue from pharmaceutical partners**. Here's the challenge:
> 
> 1. **10%+ Offline Rate**: About 15,000 devices are offline at any time—that's revenue walking out the door
> 2. **Wi-Fi Dependency**: 90%+ of devices run on the provider's Wi-Fi—when they change their password, the device goes dark
> 3. **Wrong Triage**: We're dispatching $185 technicians for problems that could be fixed with a phone call
> 
> Today I'll show you how Snowflake Intelligence and Cortex Agents solve this with **intelligent failure classification**—knowing whether to call the office or dispatch a tech."

**Actions:**
1. Open **Snowflake Intelligence** (AI & ML → Snowflake Intelligence)
2. Select the **Device Maintenance Assistant** agent
3. Briefly show the chat interface

---

## 🎯 Act 1: Executive Dashboard (2:00 - 6:00)

*Persona: C-Suite / VP of Operations*

### Scene Setup
> "Let's start with what executives care about: the big picture. Imagine you're the VP of Operations walking into a Monday morning meeting. You need instant answers—no waiting for reports, no switching between dashboards."

---

### 📌 Q1: Fleet Health & Business Impact Summary ⭐ REHEARSED

```
Give me a summary of our device fleet health and business impact
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Mike Walsh (COO)** | "How healthy is my fleet? What needs attention?" |
| **Patrick Arnold (CTO)** | "Can I get this insight without custom dashboards?" |
| **Liberty Holt (VP Data & Analytics)** | "Is this data accurate? Can I verify it?" |
| **Sharon Patent (CADO)** | "What's the data lineage? Is this auditable?" |

#### 🎯 WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **10x Faster Insights** | Instant answer vs. waiting for weekly report |
| **Reduced Downtime** | Proactive visibility into at-risk devices |
| **Executive Decision Support** | Board-ready metrics in natural language |

#### 📡 Source Systems Simulated
| Demo Data | Production Source | Integration Method |
|-----------|-------------------|-------------------|
| `DEVICE_INVENTORY` | IoT Platform (AWS IoT, Azure IoT) | Snowpipe or Kafka |
| `DEVICE_TELEMETRY` | Device heartbeat stream | Real-time ingestion |
| `V_REVENUE_IMPACT` | Ad Platform (GAM) | Daily batch or API |
| `PROVIDER_FEEDBACK` | Qualtrics/Salesforce | Scheduled sync |

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Single Pane of Glass** | Natural language replaces multiple BI tools |
| **Real-time Awareness** | Data as of current hour, not last week's report |
| **Risk Visibility** | At-risk devices surfaced proactively |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current health scores, risk levels | 100 devices |
| `V_EXECUTIVE_DASHBOARD` | Aggregated KPIs | 1 row |
| `V_REVENUE_IMPACT` | Uptime and revenue metrics | 100 devices |
| `V_CUSTOMER_SATISFACTION` | NPS and satisfaction scores | 14 facilities |

#### ✅ Auditability — How to Verify
> *"Everything you see here is queryable. If you want to drill into any number, I can show you the underlying SQL or run it directly in Snowsight."*

```sql
-- Verify fleet health summary
SELECT STATUS, COUNT(*) as DEVICE_COUNT, ROUND(AVG(HEALTH_SCORE),1) as AVG_HEALTH
FROM V_DEVICE_HEALTH_SUMMARY
GROUP BY STATUS;

-- Verify at-risk count
SELECT RISK_LEVEL, COUNT(*) FROM V_DEVICE_HEALTH_SUMMARY GROUP BY RISK_LEVEL;
```

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Demo: 100 devices** | **Production: 500,000 devices** from your device management system | Data pipeline from IoT platform |
| **Health Score formula** (CPU, memory, temp, errors) | Your actual **device health metrics** + custom weights | Configure in `V_DEVICE_HEALTH_SUMMARY` |
| **Risk thresholds** (CRITICAL >75°C, etc.) | Your **operational thresholds** based on historical failure data | Update risk classification logic |
| **Hourly telemetry** | Your **actual telemetry frequency** (could be 5-min, 15-min) | Adjust data ingestion pipeline |

#### 🏗️ Implementation Conversation Starters

> **ASK THE CUSTOMER:**
> - "Where does your device telemetry come from today? AWS IoT? Azure? Custom platform?"
> - "What health metrics do you currently track? CPU, memory, temperature—anything else?"
> - "What would your thresholds be for 'critical' vs 'high' risk?"

**SAY THIS:**
> *"This demo uses 100 representative devices. In production, this same query scales to your 500,000 devices—Snowflake handles the compute. The health score formula and risk thresholds are fully configurable based on your historical failure patterns."*

#### Expected Response Highlights
- **Fleet Health Score**: ~71/100 (Good performance)
- **Device Status**: ~85 online, 5 degraded, 10 offline (10% offline rate)
- **Risk Distribution**: 10 CRITICAL, 4 HIGH, 60 MEDIUM, 26 LOW
- **Uptime**: ~90% (Phase 1 target: 95%)
- **Network Type**: 90% PROVIDER_WIFI, 8% COMPANY_MANAGED, 2% CELLULAR
- **NPS Score**: +8.6

#### NEW: Network Dependency Context

**SAY THIS:**
> *"Notice the NETWORK_TYPE breakdown—90% of our devices run on provider Wi-Fi. This is why the 'last gasp' analysis is so critical. When a device goes offline, we need to know: Is this a Wi-Fi password change (call the office) or a hardware failure (dispatch a tech)?"*

#### ⚠️ Objection Handling

**IF ASKED: "Why is 67% of the fleet at MEDIUM risk?"**
> *"MEDIUM risk doesn't mean failure is imminent—it means these devices have one or more metrics slightly elevated that we're monitoring. This is exactly what predictive maintenance does: it identifies potential issues EARLY, before they become CRITICAL. The fact that only 7 devices (7%) are at HIGH or CRITICAL shows the system is working."*

**IF ASKED: "Why is uptime only 94.5%?"**
> *"The 94.5% includes our 3 offline and 5 degraded devices right now. This is a point-in-time snapshot showing current status. The important metric is that we're seeing these issues BEFORE they cause revenue impact. Let me show you the revenue picture..."*

**IF ASKED: "The health score of 71 seems low"**
> *"A health score of 71 means the fleet is in 'Good' condition. Perfect would be 100, but that's unrealistic for a 500K device fleet. What matters is identifying the devices that need attention—and the AI just surfaced exactly which 7 devices require action."*

#### 🔄 Transition
> *"Good overview—we see a fleet health score of 71, with 10% offline. That 10% is the problem we're solving. Let me show you exactly how long they've been down and WHY—this is where 'last gasp' analysis comes in..."*

---

### Q1c: Last Gasp Failure Classification (NEW - KEY DIFFERENTIATOR)

```
Why did device DEV-025 go offline? Show me the failure classification.
```

#### Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Patrick Arnold (CTO)** | "This is intelligent triage—not just alerting" |
| **Jonathan Richman (SVP Engineering)** | "How does it know Wi-Fi vs hardware?" |
| **Mike Walsh (COO)** | "So we don't waste $185 dispatches on phone calls" |

#### WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **Smart Triage** | Call office for Wi-Fi, dispatch for hardware |
| **Cost Avoidance** | $185 dispatch avoided when it's a password change |
| **Faster Resolution** | Phone call = 10 min vs dispatch = 4 hours |

#### Expected Response Highlights
- **Device**: DEV-025 (Appleton, WI)
- **Classified Cause**: WIFI_PASSWORD_CHANGE (92% confidence)
- **Signal Pattern**: SUDDEN_DROP (-45 to -88 dBm in <2 minutes)
- **Last Metrics**: CPU normal (52°C), Memory normal (45%), No errors
- **Recommendation**: CALL OFFICE to get new Wi-Fi password

#### Key Talking Points

**SAY THIS:**
> *"Watch this—the AI analyzed the 'last gasp' telemetry and classified this as a Wi-Fi password change with 92% confidence. How did it know? The signal dropped SUDDENLY from good (-45 dBm) to poor (-88 dBm) in under 2 minutes. But CPU, memory, and error count were all NORMAL. That pattern says: 'The device is healthy, but can't see the network.' Classic Wi-Fi password change."*

**For Mike Walsh (COO):**
> *"Mike, without this classification, we'd dispatch a $185 technician. Instead, we call the office, get the new password, and reconnect remotely. That's $185 saved per incident—and at 10% offline rate, that adds up fast."*

**Contrast with hardware failure:**
> *"Now compare that to DEV-031—it shows HARDWARE_FAILURE. Why? Signal was STABLE, but CPU was at 78°C with 47 errors logged. That device needs a technician. Same offline status, completely different resolution path."*

#### Transition
> *"That's the power of 'last gasp' analysis—intelligent failure classification. Now let me show you the full revenue picture..."*

---

### 📌 Q1b: Current Downtime Deep-Dive ⭐ REHEARSED (NEW)

```
How long have the offline devices been down and what's the revenue impact?
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Mike Walsh (COO)** | "How much is this costing us RIGHT NOW?" |
| **JT Grant (VP Ad Tech)** | "How many impressions are we losing?" |
| **Patrick Arnold (CTO)** | "Is this real-time data?" |

#### 📝 Expected Response Highlights
- **DEV-081 (Cleveland)**: 72 hours offline, ~$1,549 lost, $516/day burn rate
- **DEV-031 (Chicago)**: 36 hours offline, ~$450 lost, $300/day burn rate
- **DEV-025 (Appleton)**: 18 hours offline, ~$153 lost, $204/day burn rate
- **Total**: ~$2,152 lost, $1,020/day combined burn rate
- **3,277 impressions lost**

#### 💬 Key Talking Points

**For Mike Walsh (COO):**
> *"Mike, DEV-081 in Cleveland has been down for 72 hours—that's over $1,500 in lost ad revenue already. And it's burning $516 every day it stays down. This is the cost of reactive maintenance."*

**For JT Grant (VP Ad Tech):**
> *"JT, 3,277 impressions lost. That's pharma partner ads that didn't run. With predictive maintenance, we'd have caught DEV-081's degradation BEFORE it failed 3 days ago."*

**For Patrick Arnold (CTO):**
> *"Patrick, notice the agent calculated hours offline and revenue loss in real-time. This isn't a batch report—it's live data. The $1,549 for DEV-081 is accurate to this moment."*

#### 🔄 Transition
> *"That's $2,152 in active revenue loss from just 3 devices. Now let me show you the full revenue picture including the degraded devices..."*

---

### 📌 Q2: Revenue Loss from Device Downtime ⭐ REHEARSED

```
How much advertising revenue are we losing from device downtime?
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Mike Walsh (COO)** | "What's the dollar impact of device issues?" |
| **JT Grant (VP Ad Tech)** | "Are we meeting pharma partner SLAs?" |
| **Chloé Varennes (Director PM AdTech)** | "How does this connect to our ad platform?" |
| **Liberty Holt (VP Data & Analytics)** | "How is revenue per device calculated?" |

#### 🎯 WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **Revenue Protection** | Quantify exactly how much downtime costs |
| **Partner SLA Compliance** | Prove ad delivery reliability to pharma |
| **Investment Justification** | "We're losing $X, here's how to fix it" |

> **KEY INSIGHT FOR CFO:** *"Every hour a device is offline, we lose $8-$25 in ad revenue. At 500K devices, even 0.5% downtime = $25M+ annual impact."*

#### 📡 Source Systems Simulated
| Demo Data | Production Source | Integration Method |
|-----------|-------------------|-------------------|
| `HOURLY_AD_REVENUE_USD` | Google Ad Manager CPM data | Daily API sync |
| `DEVICE_DOWNTIME` | Monitoring/alerting system | Event-driven ingestion |
| `DEVICE_INVENTORY.STATUS` | IoT Platform device status | Real-time stream |

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Revenue Attribution** | Device health → ad impressions → dollars |
| **Zero Loss Target** | Predictive maintenance prevents revenue leakage |
| **Partner Confidence** | Reliable screens = reliable ad delivery |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_REVENUE_IMPACT` | Revenue loss per device, uptime % | 100 devices |
| `DEVICE_DOWNTIME` | Historical downtime incidents | 10 incidents |
| `DEVICE_INVENTORY` | Hourly ad revenue per device ($8-$25/hr) | 100 devices |

#### ✅ Auditability — How to Verify
```sql
-- See revenue loss by device
SELECT DEVICE_ID, FACILITY_NAME, TOTAL_REVENUE_LOSS_USD, UPTIME_PERCENTAGE
FROM V_REVENUE_IMPACT
WHERE TOTAL_REVENUE_LOSS_USD > 0
ORDER BY TOTAL_REVENUE_LOSS_USD DESC;

-- Verify downtime records
SELECT * FROM DEVICE_DOWNTIME ORDER BY DOWNTIME_START DESC;
```

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **$8-$25/hr ad revenue** | Your **actual CPM rates** by device type, location, pharma partner | Import from ad platform (e.g., GAM, direct contracts) |
| **Monthly impressions** (9K-27K) | Your **actual impression data** from ad server | Real-time or daily sync from ad platform |
| **Downtime tracking** | Your **actual outage data** from monitoring system | Connect to alerting/monitoring tool |

**Key Data Sources:**
- **Ad Revenue**: Google Ad Manager, direct pharma contracts, CPM by placement
- **Impressions**: Real-time ad server logs, viewability metrics
- **Downtime**: Device management platform alerts, heartbeat failures

**SAY THIS:**
> *"The revenue numbers here come from your ad platform data. We can connect directly to your ad server to pull actual CPM rates and impression counts per device. This means the AI calculates real revenue impact, not estimates."*

#### 📝 Expected Response Highlights
- **Revenue at Risk**: ~$51,660 (5% of potential)
- **Top 3 Offline Devices**: DEV-081 ($15K), DEV-031 ($9K), DEV-025 ($6K)
- **Devices Affected**: 8 out of 100 (92% healthy)
- **Geographic Pattern**: Cleveland facilities disproportionately affected
- **Production Scale**: ~$25.8M annual impact

#### ⚠️ Objection Handling

**IF ASKED: "Q1 said $0 revenue loss, now you're saying $51K?"**
> *"Great catch—these are different metrics. The $0 in Q1 was HISTORICAL downtime—incidents that have been recorded and resolved. The $51K here is CURRENT revenue at risk from devices that are offline or degraded RIGHT NOW. This is exactly why predictive maintenance matters—we can see the potential revenue impact BEFORE it becomes actual loss."*

**IF ASKED: "How do you calculate revenue per device?"**
> *"Each device has an hourly ad revenue rate based on its model and location—ranging from $8/hour for Lite 32s to $25/hour for Max 65s in high-traffic facilities. We multiply by hours offline to get revenue impact. In production, this would pull actual CPM rates from your ad platform."*

**IF ASKED: "Why are Cleveland facilities having issues?"**
> *"The AI identified a geographic pattern—this could indicate a regional network issue, a batch of devices from the same shipment, or even a facility-level infrastructure problem. This is the kind of insight that helps operations prioritize investigations."*

#### 🔄 Transition
> *"So we have $51K at risk from 8 devices right now. The good news? 92% of the fleet is healthy. This shows exactly why we need predictive maintenance—to catch these issues before they cause actual revenue loss. Let me show you the cost side..."*

---

### 📌 Q3: Annual Field Service Cost & ROI ⭐ REHEARSED

```
What's our annual field service cost and projected savings with predictive maintenance?
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Mike Walsh (COO)** | "What's the bottom-line impact? Justify the investment." |
| **Patrick Arnold (CTO)** | "What's the ROI timeline? Is this worth the build?" |
| **Drew Amwoza (SVP Strategy)** | "How does this fit our technology roadmap?" |
| **Jonathan Richman (SVP Engineering)** | "What's the implementation effort vs. payback?" |

#### 🎯 WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **Investment Justification** | $96M savings justifies implementation cost |
| **Operational Efficiency** | 52% reduction in field service costs |
| **ROI Timeline** | 4:1 return, typically payback in <1 year |

> **KEY INSIGHT FOR CFO:** *"This is your headline number: $29 million in annual savings from 52% reduction in field dispatches at 150K devices. Conservative estimate—doesn't include revenue protection."**

#### 📡 Source Systems Simulated
| Demo Data | Production Source | Integration Method |
|-----------|-------------------|-------------------|
| `V_ROI_ANALYSIS` | Calculated from ServiceNow costs | SQL aggregation |
| `$185/dispatch` | Actual dispatch costs (labor, travel, parts) | From field service system |
| `$25/remote fix` | Helpdesk/NOC labor costs | From support ticketing |
| `MAINTENANCE_HISTORY` | ServiceNow closed tickets | Native app or API |

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Cost Baseline Established** | $55M/year at 150K devices |
| **Savings Projection** | $29M/year (52% reduction) |
| **Remote Fix Economics** | $185 dispatch vs $25 remote = $160 saved per fix |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ROI_ANALYSIS` | Annual projections, per-unit costs | 1 row |
| `MAINTENANCE_HISTORY` | Actual resolution types | 24 tickets |
| `V_MAINTENANCE_ANALYTICS` | Cost savings achieved | 24 records |

#### ✅ Auditability — How to Verify
```sql
-- See the full ROI calculation
SELECT * FROM V_ROI_ANALYSIS;

-- Verify remote fix rate
SELECT RESOLUTION_TYPE, COUNT(*) as COUNT, SUM(COST_SAVINGS_USD) as TOTAL_SAVINGS
FROM V_MAINTENANCE_ANALYTICS
GROUP BY RESOLUTION_TYPE;
```

**SAY THIS:**
> *"This is the ROI story: we spend $55M annually on field dispatches at 150K devices across 30K offices. With 60%+ remote resolution, we're projecting $29M in annual savings—that's a 52% cost reduction. And with 'last gasp' failure classification, we can push remote resolution even higher by calling offices for Wi-Fi changes instead of dispatching techs."**

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **$185 avg dispatch cost** | Your **actual dispatch costs** (labor, travel, parts) | Import from ServiceNow/field service system |
| **$25 remote fix cost** | Your **actual remote support costs** (labor time) | Calculate from helpdesk data |
| **2 issues/device/year assumption** | Your **actual historical issue rate** | Analyze from maintenance history |

**Specific ROI Inputs:**
- **Labor costs**: Technician hourly rate × avg time on-site
- **Travel costs**: Mileage reimbursement, fleet costs
- **Parts costs**: Average parts per dispatch
- **Remote costs**: NOC hourly rate × avg resolution time

#### 🏗️ Implementation Conversation Starters

> **ASK THE CUSTOMER:**
> - "What's your actual cost per field dispatch? (We're using $185 as industry average)"
> - "What does a remote fix cost in labor time?"
> - "How many issues per device per year do you see today?"

> **DATA HYGIENE CHECK:**
> - "Do you track resolution type (remote vs dispatch) in ServiceNow?"
> - "Are costs captured at the ticket level or estimated?"

**SAY THIS (if asked about the numbers):**
> *"These cost assumptions are configurable. In a POC, we'd plug in your actual dispatch costs from ServiceNow and your remote support costs from your helpdesk system. The ROI calculation updates automatically."*

#### Expected Response Highlights
- **Annual Field Service Cost**: $55M (at 150K devices across 30K offices)
- **Avg Dispatch Cost**: $185 per incident
- **Avg Remote Fix Cost**: $25 per incident
- **Projected Annual Savings**: $29M (52% reduction)
- **Dispatches Avoided**: ~180,000 annually
- **Remote Fix Rate**: 60-75%
- **ROI**: ~4:1 return

#### ⚠️ Objection Handling

**IF ASKED: "Where does $185 per dispatch come from?"**
> *"That's an industry average for field service visits—includes technician labor (2-4 hours), travel costs, vehicle expenses, and parts markup. In a POC, we'd plug in your actual dispatch costs from ServiceNow or your field service system."*

**IF ASKED: "How did you calculate 4:1 ROI?"**
> *"$96M in annual savings versus an estimated $20-25M for implementation and operations. The exact ROI depends on your infrastructure, but field service companies typically see 3-5x return. Some customers like FIIX have seen 10x improvement in maintenance insights."*

**IF ASKED: "Is 75% remote fix rate realistic?"**
> *"Based on the demo data, we're seeing 60-70% remote resolution. 75% is achievable as the AI learns your failure patterns and the knowledge base matures. For software issues, some customers see 80%+. Hardware issues like display failures will always require dispatch."*

**IF ASKED: "What's not included in these savings?"**
> *"This is conservative—it only counts dispatch avoidance. It doesn't include: revenue protection from faster resolution, customer satisfaction gains, extended device lifespan from proactive maintenance, or reduced emergency overtime costs."*

#### 📐 How to Explain the Math (If Challenged)

**The calculation:**
```
$55M = 150,000 devices × 2 issues/device/year × $185/dispatch
$29M = 300,000 dispatches × 60% remote × ($185 - $25) saved
```

**The assumptions to validate:**
| Assumption | Our Value | Question to Ask |
|------------|-----------|-----------------|
| Issues per device/year | 2 | "How many issues per device do you see today?" |
| Dispatch cost | $185 | "What's your actual cost per dispatch?" |
| Remote fix cost | $25 | "What does a remote fix cost in labor time?" |
| Remote fix rate | 60% | "What's your remote fix rate today?" |

**SAY THIS if numbers are questioned:**
> *"These are industry benchmarks. The formula is simple—the inputs are what matter. In a POC, we plug in YOUR numbers and recalculate. If your dispatch cost is $150, savings are lower. If it's $250, they're higher. The model is the same."*

#### 🎤 Executive Talking Point
**SAY THIS after the response:**
> *"This is the headline number for your CFO: $29 million in annual savings from a 52% reduction in field dispatches at 150K devices. And this is conservative—it doesn't include revenue protection from faster resolution, the customer satisfaction gains from proactive maintenance, or the churn reduction from happier providers."**

#### 🔄 Transition
> *"That's the projection at scale. Let me show you the actual savings we're achieving right now in the demo data..."*

---

### 📌 Q4: Monthly Cost Savings Achieved ⭐ REHEARSED

```
How much money have we saved this month from remote fixes vs field dispatches?
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Mike Walsh (COO)** | "Proof that this works—actual savings, not projections" |
| **Jonathan Richman (SVP Engineering)** | "Is the remote fix capability delivering?" |
| **Liberty Holt (VP Data & Analytics)** | "Can we track this trend over time?" |

#### 🎯 WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **Proof Over Promise** | Actual dollars saved, not projections |
| **Trend Visibility** | Monthly tracking validates strategy |
| **Operational Accountability** | Clear attribution: remote fix → savings |

> **KEY INSIGHT FOR MIKE (COO):** *"This is the proof point—we're not just projecting savings, we're tracking actual realized savings month over month. This is how you'd measure success post-implementation."*

#### 📡 Source Systems Simulated
| Demo Data | Production Source | Integration Method |
|-----------|-------------------|-------------------|
| `MAINTENANCE_HISTORY` | ServiceNow closed tickets | Native app sync |
| `RESOLUTION_TYPE` | Ticket classification field | Map from your categories |
| `COST_USD` | Actual or estimated cost per ticket | From field service costing |

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Realized Savings** | Actual dollars saved (not projected) |
| **Remote Fix Rate** | 60-70% of issues resolved without dispatch |
| **Dispatch Avoidance** | Each remote fix = $185 saved |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_MAINTENANCE_ANALYTICS` | Ticket-level cost data | 24 tickets |
| `MAINTENANCE_HISTORY` | Resolution type, technician, timestamp | 24 records |

#### ✅ Auditability — How to Verify
```sql
-- See savings by ticket
SELECT TICKET_ID, DEVICE_ID, FACILITY_NAME, RESOLUTION_TYPE, 
       COST_USD, COST_SAVINGS_USD, RESOLUTION_TIME_MINS
FROM V_MAINTENANCE_ANALYTICS
WHERE DATE_TRUNC('month', CREATED_AT) = DATE_TRUNC('month', CURRENT_DATE())
ORDER BY CREATED_AT DESC;
```

#### 📝 Expected Response Highlights
- **$1,295 saved** this month (actual, not projected)
- **7 remote fixes**, 0 field dispatches
- **100% remote fix rate** (for this demo period)
- **$185 average savings** per avoided dispatch
- Issue types: CONNECTIVITY, DISPLAY_FREEZE, HIGH_CPU, MEMORY_LEAK, SLOW_RESPONSE, SOFTWARE_UPDATE

#### 💬 Key Talking Points

**For Mike Walsh (COO):**
> *"Mike, $1,295 saved in 2 weeks from 7 tickets—all resolved remotely. That's not a projection, that's actual cost avoidance. 100% remote fix rate on software and network issues."*

**For Jonathan Richman (SVP Engineering):**
> *"Jonathan, look at the issue types: CONNECTIVITY, HIGH_CPU, MEMORY_LEAK. These are exactly the kinds of issues that don't need a truck roll. The AI triaged correctly every time."*

**Connect the unit economics:**
> *"Let me connect the numbers: $185 saved per remote fix × 7 tickets = $1,295. At production scale with 600,000 avoided dispatches, that's the $96M. Same math, bigger scale."*

#### 🏗️ Implementation Conversation Starters

> **ASK JENNIFER (Data Engineering):**
> - "Do you track resolution type (remote vs dispatch) in ServiceNow today?"
> - "Are costs captured at the ticket level, or would we need to calculate from averages?"

> **DATA HYGIENE CHECK:**
> - "How consistently is resolution type populated in your tickets?"
> - "Do you have a standard taxonomy for issue types?"

#### 🔄 Transition
> *"That's real savings happening now—on track for 40-60% reduction in field service costs. But I noticed we track NPS. Let's check customer satisfaction..."*

---

### 📌 Prompt 5: Customer Satisfaction

```
What is our customer satisfaction score and which facilities need follow-up?
```

#### 🎯 Why This Matters to the Customer
- **Retention driver** — Happy providers renew contracts
- **Early warning system** — Negative feedback = churn risk
- **Closed-loop service** — Issues flagged for follow-up

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **NPS Tracking** | Net Promoter Score by facility |
| **Proactive Follow-up** | Negative feedback triggers action |
| **Service Quality Correlation** | Device uptime → satisfaction |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_CUSTOMER_SATISFACTION` | NPS, ratings by facility | 14 facilities |
| `PROVIDER_FEEDBACK` | Individual feedback records | 14 records |

#### ✅ Auditability — How to Verify
```sql
-- See facilities needing follow-up
SELECT FACILITY_NAME, AVG_NPS_SCORE, FEEDBACK_CATEGORY, FOLLOW_UPS_REQUIRED
FROM V_CUSTOMER_SATISFACTION
WHERE FOLLOW_UPS_REQUIRED > 0;

-- See all feedback
SELECT * FROM PROVIDER_FEEDBACK ORDER BY FEEDBACK_DATE DESC;
```

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **NPS Score (0-10)** | Your **actual provider NPS surveys** | Import from survey tool (Qualtrics, etc.) |
| **Satisfaction ratings** | Your **CRM feedback data** | Sync from Salesforce/HubSpot |
| **Follow-up flags** | Your **customer success workflow** | Connect to CS platform |

**Data Sources:**
- **Provider Surveys**: Qualtrics, SurveyMonkey, or in-app feedback
- **CRM Data**: Salesforce, HubSpot provider records
- **Support Tickets**: Zendesk, ServiceNow customer complaints
- **Contract Data**: Renewal risk indicators, account health

**SAY THIS:**
> *"We're correlating device health with provider satisfaction. The insight here is: facilities with more device issues have lower NPS. This helps your customer success team prioritize which accounts need attention—before they churn."*

#### 🔄 Transition
> *"I see Springfield Urgent Care flagged for follow-up—they had a negative experience. Let's hand this over to Operations to understand what's happening with their device..."*

---

### Executive Act Summary

| FOCUS Result | Metric Shown | Demo Value | Production Scale (150K) |
|--------------|--------------|------------|-------------------------|
| **Revenue Protection** | Ad revenue loss | $0 when fixed fast | Millions protected |
| **40-60% Cost Reduction** | Annual savings | $2,500+/month | **$29M+/year** |
| **Intelligent Triage** | Failure classification | Wi-Fi vs Hardware | Call Office vs Dispatch |
| **Customer Satisfaction** | NPS Score | 8.6 | Reduce 7-8% churn |

---

## 🖥️ Act 2: Operations Center (6:00 - 12:00)

*Persona: IT Manager / Facilities Operations*

### Scene Setup
> "Now let's switch to the Operations Center. The executive just flagged Springfield Urgent Care. But as an ops manager, you need to see the full picture of what's at risk today—and make dispatch decisions."

---

### 📌 Prompt 1: Top Facilities by Revenue

```
Show me device health across our top 10 facilities by ad revenue
```

#### 🎯 Why This Matters to the Customer
- **Prioritize by business impact** — Not all devices are equal
- **Revenue-weighted decisions** — Fix high-revenue devices first
- **Resource allocation** — Where should techs focus?

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Revenue-Based Prioritization** | Operations decisions tied to business value |
| **Risk Concentration** | Are high-revenue facilities also high-risk? |
| **Portfolio View** | Facility-level health at a glance |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Health scores, facility names | 100 devices |
| `DEVICE_INVENTORY` | Hourly ad revenue per device | 100 devices |

#### ✅ Auditability — How to Verify
```sql
-- Top 10 facilities by revenue
SELECT FACILITY_NAME, SUM(HOURLY_AD_REVENUE_USD * 720) as MONTHLY_REVENUE,
       AVG(HEALTH_SCORE) as AVG_HEALTH, COUNT(*) as DEVICE_COUNT
FROM V_DEVICE_HEALTH_SUMMARY
GROUP BY FACILITY_NAME
ORDER BY MONTHLY_REVENUE DESC
LIMIT 10;
```

#### 🔄 Transition
> *"Good overview of our highest-value facilities. Now let me see what's actually at risk across the entire fleet right now..."*

---

### 📌 Prompt 2: Current Risk Assessment

```
Which devices have critical or high risk levels right now?
```

#### 🎯 Why This Matters to the Customer
- **Actionable intelligence** — Not just data, but prioritized action items
- **Failure prevention** — Address issues before they cause downtime
- **Dispatch optimization** — Know which devices need attention TODAY

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Real-time Risk Scoring** | Devices ranked by failure probability |
| **Root Cause Visibility** | Each risk level shows the primary issue |
| **Proactive Operations** | See problems before customers report them |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Risk level, primary issue | 100 devices |
| `DEVICE_TELEMETRY` | Real-time CPU, memory, temp, errors | 72,000 readings |

**Risk Classification Logic:**
```
CRITICAL: Device offline
HIGH: Degraded + (CPU temp > 65°C OR CPU usage > 80%)
MEDIUM: Degraded OR (CPU temp > 75°C OR CPU usage > 95%)
LOW: All metrics within normal range
```

#### ✅ Auditability — How to Verify
```sql
-- See all at-risk devices with details
SELECT DEVICE_ID, FACILITY_NAME, LOCATION, HEALTH_SCORE, RISK_LEVEL,
       PRIMARY_ISSUE, CPU_TEMP_CELSIUS, CPU_USAGE_PCT, MEMORY_USAGE_PCT,
       DAYS_SINCE_MAINTENANCE
FROM V_DEVICE_HEALTH_SUMMARY
WHERE RISK_LEVEL IN ('CRITICAL', 'HIGH')
ORDER BY CASE RISK_LEVEL WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 END;
```

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **CPU temp thresholds** (65°C, 75°C) | Your **device specs** and historical failure temps | Analyze past failures to set thresholds |
| **Risk classification rules** | Your **operational SLAs** (e.g., hospital vs clinic) | Business logic in view definition |
| **Telemetry metrics** | Your **actual IoT data points** (could include ambient temp, display brightness) | Map to existing telemetry schema |

**Specific Considerations:**
- **Device Models**: Different thresholds for Pro 55, Lite 32, Max 65?
- **Facility Types**: Hospitals might have stricter SLAs than clinics
- **Geographic Factors**: Higher acceptable temps in warm climates?
- **Age of Device**: Older devices may need different thresholds

**SAY THIS:**
> *"These risk thresholds are based on industry standards, but you'd tune them using your historical failure data. For example, if your devices typically fail at 80°C, we'd set the CRITICAL threshold there. The AI learns from your patterns."*

#### 🔄 Transition
> *"I see 7 devices flagged—including DEV-005 at Springfield Urgent Care that the executive mentioned. Before I dispatch technicians, let me see if any of these can be fixed remotely..."*

---

### 📌 Prompt 3: Remote Fix Triage

```
Can any of these critical or high risk devices be fixed remotely?
```

#### 🎯 Why This Matters to the Customer
- **Cost optimization** — Remote fix = $25 vs dispatch = $185
- **Faster resolution** — Remote in 30 min vs dispatch in 4+ hours
- **Intelligent triage** — AI recommends most cost-effective action

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Automated Triage** | AI classifies remote vs on-site |
| **Success Rate Prediction** | Each issue type has known fix rate |
| **Decision Support** | Ops manager gets recommendation, not just data |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `TROUBLESHOOTING_KB` | Success rates by issue type | 10 categories |
| `V_DEVICE_HEALTH_SUMMARY` | Current issues per device | 100 devices |

**Remote Fix Success Rates:**
| Issue Type | Remote Success Rate |
|------------|---------------------|
| HIGH_CPU | 92% |
| MEMORY_LEAK | 94% |
| DISPLAY_FREEZE | 87.5% |
| CONNECTIVITY | 70% |
| OVERHEATING | 15% (usually requires dispatch) |

#### ✅ Auditability — How to Verify
```sql
-- See success rates from knowledge base
SELECT ISSUE_CATEGORY, SUCCESS_RATE_PCT, REQUIRES_DISPATCH,
       ESTIMATED_REMOTE_FIX_TIME_MINS
FROM TROUBLESHOOTING_KB
ORDER BY SUCCESS_RATE_PCT DESC;
```

#### 🔄 Transition
> *"Great—the agent identified that HIGH_CPU and MEMORY_LEAK issues can be fixed remotely with 92%+ success rate. Let me dig into Springfield specifically..."*

---

### 📌 Prompt 4: Device Deep Dive

```
What's the status of device DEV-005 at Springfield Urgent Care and what's causing the issue?
```

#### 🎯 Why This Matters to the Customer
- **Full context for dispatch** — Don't send techs blind
- **Pattern recognition** — Is this a recurring issue at this location?
- **Root cause analysis** — Understand why, not just what

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Device-Level Detail** | Complete health profile on demand |
| **Historical Context** | Past issues at this facility |
| **Actionable Diagnosis** | Not just symptoms, but recommended actions |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current device status | 1 device |
| `MAINTENANCE_HISTORY` | Past tickets for this device | Variable |
| `TROUBLESHOOTING_KB` | Fix procedures | 10 categories |

#### ✅ Auditability — How to Verify
```sql
-- Full device profile
SELECT * FROM V_DEVICE_HEALTH_SUMMARY WHERE DEVICE_ID = 'DEV-005';

-- Historical issues at this location
SELECT * FROM MAINTENANCE_HISTORY 
WHERE DEVICE_ID = 'DEV-005' 
ORDER BY CREATED_AT DESC;
```

#### 🔄 Transition
> *"I see it's a network connectivity issue—and this facility has had 3 network issues in 60 days. Let me check if we already have work orders created..."*

---

### 📌 Prompt 5: Work Order Status

```
Show me all active work orders and their priority
```

#### 🎯 Why This Matters to the Customer
- **Dispatch coordination** — What's already being worked?
- **Priority management** — Critical vs routine work
- **AI-generated vs manual** — See predictive maintenance in action

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Work Order Visibility** | All active jobs in one view |
| **AI-Initiated Work** | Predictive system creates proactive tickets |
| **Technician Utilization** | Who's assigned to what |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ACTIVE_WORK_ORDERS` | Active work orders with details | 5 active |
| `WORK_ORDERS` | Full work order records | 8 total |
| `TECHNICIANS` | Technician assignments | 6 techs |

#### ✅ Auditability — How to Verify
```sql
-- See all active work orders
SELECT WORK_ORDER_ID, DEVICE_ID, FACILITY_NAME, PRIORITY, STATUS,
       SOURCE, ASSIGNED_TECHNICIAN_ID, AI_DIAGNOSIS
FROM V_ACTIVE_WORK_ORDERS
ORDER BY URGENCY_SCORE DESC;

-- See AI-generated vs manual
SELECT SOURCE, COUNT(*) FROM WORK_ORDERS GROUP BY SOURCE;
```

#### 🔄 Transition
> *"I see there's already a CRITICAL work order for DEV-005—created by AI prediction. Now let me show you the predictive intelligence..."*

---

### 📌 Prompt 6: Predictive Failure Detection

```
Which devices are predicted to fail in the next 48 hours?
```

#### 🎯 Why This Matters to the Customer
- **24-48 hour advance warning** — Time to prevent failures
- **Proactive dispatch** — Schedule before emergency
- **Confidence scoring** — Know how reliable the prediction is

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Predictive Lead Time** | 24-48 hour advance warning |
| **Failure Probability** | Confidence % for each prediction |
| **Contributing Factors** | Which metrics drove the prediction |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_FAILURE_PREDICTIONS` | Predicted failures with probability | Variable |
| `V_DEVICE_HEALTH_SUMMARY` | Current risk levels | 100 devices |
| `DEVICE_TELEMETRY` | 30 days of trend data | 72,000 readings |

**Prediction Model Inputs:**
- CPU temperature trend (rising = higher risk)
- Memory usage trend (approaching limit)
- Error count acceleration
- Days since last maintenance
- Historical failure patterns at this location

#### ✅ Auditability — How to Verify
```sql
-- See predictions (requires script 05)
SELECT DEVICE_ID, FACILITY_NAME, RISK_LEVEL, 
       PREDICTED_HOURS_TO_FAILURE, FAILURE_PROBABILITY_PCT,
       RISK_FACTORS
FROM V_FAILURE_PREDICTIONS
WHERE PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY FAILURE_PROBABILITY_PCT DESC;
```

**SAY THIS:**
> *"This is the power of predictive maintenance—we can see failures before they happen. The model looks at 30 days of telemetry: temperature trends, memory patterns, error acceleration. This gives us time to schedule proactive maintenance instead of reacting to emergencies."*

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **30-day telemetry window** | Your **optimal prediction window** (could be 7, 14, 60 days) | Tune based on failure patterns |
| **Rule-based prediction** | Your choice: **Cortex ML models** for higher accuracy | Train on historical failure data |
| **Failure probability %** | Your **confidence thresholds** for action | Business rule configuration |

**ML Model Options for Production:**
1. **Rule-Based (Current)**: Simple threshold logic, ~85% accuracy
2. **Cortex ML Classification**: Train on historical failures, ~90%+ accuracy
3. **Anomaly Detection**: Identify unusual patterns automatically
4. **Time-Series Forecasting**: Predict when metrics will cross thresholds

**ML Data Requirements:**
- **Positive Examples**: Historical failures with telemetry before failure
- **Negative Examples**: Devices that didn't fail (for contrast)
- **Minimum Data**: 6-12 months of telemetry + failure records

**SAY THIS:**
> *"In the demo, we're using rule-based predictions. In production, you could train a Cortex ML model on your historical failure data—devices that actually failed, correlated with their telemetry leading up to failure. This typically pushes accuracy above 90%."*

#### 🔄 Transition
> *"But how accurate are these predictions? Let me prove it..."*

---

### 📌 Prompt 7: Prediction Accuracy

```
What's our prediction accuracy based on historical failure data?
```

#### 🎯 Why This Matters to the Customer
- **Credibility** — Predictions are only useful if accurate
- **Continuous improvement** — Track accuracy over time
- **Trust building** — Data scientists can validate the model

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Validated Accuracy** | >85% predictions match actual failures |
| **False Positive Rate** | Minimized unnecessary dispatches |
| **Model Performance** | Precision and recall metrics |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_PREDICTION_ACCURACY_ANALYSIS` | Accuracy metrics | 1 row |
| `MAINTENANCE_HISTORY` | Actual failures for validation | 24 tickets |
| `V_FAILURE_PREDICTIONS` | Historical predictions | Variable |

#### ✅ Auditability — How to Verify
```sql
-- See accuracy analysis (requires script 05)
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;

-- Manual validation: compare predictions to actual failures
SELECT COUNT(*) as PREDICTED_ISSUES,
       SUM(CASE WHEN EXISTS (
           SELECT 1 FROM MAINTENANCE_HISTORY m 
           WHERE m.DEVICE_ID = p.DEVICE_ID 
           AND m.CREATED_AT > p.PREDICTION_TIMESTAMP
       ) THEN 1 ELSE 0 END) as ACTUAL_FAILURES
FROM V_FAILURE_PREDICTIONS p;
```

**SAY THIS:**
> *"This is the proof point—we're not just making predictions, we're validating them against actual outcomes. >85% accuracy means 8 out of 10 predictions are correct. Snowflake customers consistently see 90% query accuracy with Cortex AI."*

#### 🔄 Transition
> *"Strong accuracy. Now let me show you how fast we're resolving issues when they do occur..."*

---

### 📌 Prompt 8: Resolution Performance

```
What's our mean time to resolution and how does it compare by resolution type?
```

#### 🎯 Why This Matters to the Customer
- **MTTR is a key SLA metric** — Contractual obligations
- **Remote vs dispatch comparison** — Proves the ROI of remote fixes
- **Continuous improvement** — Track performance over time

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **8x Faster Resolution** | Remote fixes in 30 min vs 4+ hours |
| **SLA Compliance** | Meeting contractual response times |
| **Efficiency Gains** | Doing more with the same team |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_MAINTENANCE_ANALYTICS` | Resolution times by ticket | 24 tickets |
| `V_EXECUTIVE_DASHBOARD` | Aggregated MTTR | 1 row |

#### ✅ Auditability — How to Verify
```sql
-- MTTR by resolution type
SELECT RESOLUTION_TYPE,
       COUNT(*) as TICKET_COUNT,
       ROUND(AVG(RESOLUTION_TIME_MINS), 1) as AVG_MTTR_MINS,
       ROUND(AVG(RESOLUTION_TIME_MINS)/60, 1) as AVG_MTTR_HOURS
FROM V_MAINTENANCE_ANALYTICS
GROUP BY RESOLUTION_TYPE;
```

**SAY THIS:**
> *"Remote fixes average 30 minutes. Field dispatches take 4+ hours. That's 8x faster resolution—which directly impacts uptime and revenue. This is 10x faster insights than traditional batch reporting."*

#### 🔄 Transition
> *"Now watch this—the agent can also trigger actions automatically. This is the 'act' in observe-orient-decide-ACT..."*

---

### 📌 Q9: Automated Remediation ⭐ REHEARSED ⭐ KEY MOMENT

```
Can you attempt a remote restart on device DEV-003 to fix the high CPU issue?
```

#### 👔 Who In The Room Cares
| Attendee | What They're Listening For |
|-----------------------|---------------------------|
| **Patrick Arnold (CTO)** | "This is agentic AI—it can take action, not just answer questions" |
| **Jonathan Richman (SVP Engineering)** | "How does this integrate with our device API?" |
| **Drew Amwoza (SVP Strategy)** | "This is the future—closed-loop autonomous operations" |
| **Sharon Patent (CADO)** | "Is this auditable? What controls exist?" |

#### 🎯 WHY This Matters (Business Outcomes)
| Business Outcome | How This Prompt Demonstrates It |
|------------------|--------------------------------|
| **Closed-Loop Operations** | AI doesn't just recommend—it acts |
| **Speed to Resolution** | No human delay between diagnosis and fix |
| **Scalability** | Automated fixes across 500K devices |
| **Governance** | Every action logged for audit |

> **KEY INSIGHT FOR PATRICK (CTO):** *"This is the difference between a chatbot and an AI agent. It's not just answering questions—it's taking action. Same RBAC, same audit trail, same governance you already have."*

> **KEY INSIGHT FOR SHARON (CADO):** *"Every action is logged with timestamp, who initiated it, what command was sent, and the outcome. Complete audit trail for compliance."*

#### 📡 Source Systems Simulated
| Demo Data | Production Source | Integration Method |
|-----------|-------------------|-------------------|
| `SEND_DEVICE_COMMAND` procedure | Device Management API | External Function (HTTPS) |
| `EXTERNAL_ACTION_LOG` | Audit/compliance system | Write to Splunk/Datadog optional |
| Device API | Your IoT platform SDK | REST API calls |

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Automated Remediation** | Agent triggers device commands |
| **Audit Trail** | Every action is logged |
| **Integration Capability** | Connects to external systems |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `SEND_DEVICE_COMMAND` procedure | Triggers remote command | N/A |
| `EXTERNAL_ACTION_LOG` | Audit trail of actions | Growing |
| `V_RECENT_EXTERNAL_ACTIONS` | Recent action history | 20 max |

#### ✅ Auditability — How to Verify

**Follow-up prompt:**
```
Show me recent external actions that were triggered
```

```sql
-- See the audit log
SELECT TIMESTAMP, ACTION_TYPE, TARGET_SYSTEM, DEVICE_ID, 
       COMMAND, STATUS, INITIATED_BY
FROM V_RECENT_EXTERNAL_ACTIONS
ORDER BY TIMESTAMP DESC;
```

**SAY THIS:**
> *"Notice what just happened—the agent didn't just recommend an action, it triggered a simulated API call to the device management system. In production, this would actually restart the device via External Functions. Every action is logged for compliance and audit. Cortex Agents aren't just chatbots—they can execute actions."*

#### 🔧 Customization Notes

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Simulated API calls** | **Real External Functions** to your systems | Snowflake External Functions setup |
| **Log table for audit** | Your **compliance/audit system** | Could write to Splunk, Datadog |
| **Device commands** | Your **device management API** commands | Map to your IoT platform SDK |

**Integration Points:**

| System | Integration Method | What It Does |
|--------|-------------------|--------------|
| **Device Management Platform** | External Function → REST API | Send reboot, restart, clear cache commands |
| **ServiceNow** | Native App or External Function | Create incidents, work orders |
| **Slack/Teams** | External Function → Webhook | Alert operations team |
| **PagerDuty** | External Function → API | Escalate critical issues |
| **Your IoT Platform** (AWS IoT, Azure IoT) | External Function | Device twin updates, commands |

**Production Architecture:**
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Cortex Agent   │────▶│ External Function │────▶│ Device Mgmt API │
│  (Snowflake)    │     │  (Snowflake)      │     │ (Your Platform) │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│  Audit Log      │
│  (Snowflake)    │
└─────────────────┘
```

#### 🏗️ Implementation Conversation Starters

> **ASK JONATHAN (SVP Engineering):**
> - "What's your device management platform? AWS IoT? Azure? Custom?"
> - "Do you have an API for sending commands to devices (reboot, restart)?"
> - "What's your current process for triggering remote fixes?"

> **ASK DREW (SVP Strategy):**
> - "How does this fit with your automation roadmap?"
> - "Are there other actions beyond device commands you'd want to automate?"

> **GOVERNANCE CHECK FOR SHARON (CADO):**
> - "What approval workflow would you want before automated actions?"
> - "Who should have permission to trigger device commands via AI?"

**SAY THIS:**
> *"In production, the stored procedure would be replaced with an External Function that calls your device management API. Snowflake External Functions provide secure, governed API access—same RBAC, same audit trail. We can integrate with ServiceNow, Slack, PagerDuty, or any REST API."*

#### 🔄 Transition
> *"The agent just demonstrated the full loop: detect → diagnose → act. Now let's see this from the technician's perspective when a dispatch IS required..."*

---

### ✅ Operations Act Summary

| Capability | Demo Evidence | Business Value |
|------------|---------------|----------------|
| 🏢 Revenue prioritization | Top 10 by ad revenue | Focus on what matters |
| 🎯 Real-time risk | 7 devices flagged | Prevent failures |
| 🔧 Remote fix triage | 92% success rate | Avoid $185/dispatch |
| 📊 Prediction accuracy | >85% validated | Trust the AI |
| ⏱️ MTTR tracking | 8x faster remote | SLA compliance |
| 🤖 Automated action | Triggered restart | Closed-loop ops |

---

## 🔧 Act 3: Field Technician View (12:00 - 16:00)

*Persona: Field Service Technician*

### Scene Setup
> "Now let's see this from the technician's perspective. Marcus Johnson just got assigned the Springfield Urgent Care job. He's in his truck, opening the mobile app. He needs to know: What am I walking into?"

---

### 📌 Prompt 1: My Assignments

```
What work orders are assigned to Marcus Johnson today?
```

#### 🎯 Why This Matters to the Customer
- **Technician productivity** — No wasted trips to the office
- **Priority clarity** — Know which job is most urgent
- **Mobile-first** — Works from anywhere

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Personalized View** | Each tech sees their assignments |
| **Priority Ranking** | Critical jobs surfaced first |
| **Full Context** | Issue summary visible before arrival |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ACTIVE_WORK_ORDERS` | Work orders by technician | 5 active |
| `TECHNICIANS` | Technician profiles | 6 techs |

#### ✅ Auditability — How to Verify
```sql
-- Marcus's assignments
SELECT wo.WORK_ORDER_ID, wo.DEVICE_ID, d.FACILITY_NAME, 
       wo.PRIORITY, wo.ISSUE_SUMMARY
FROM V_ACTIVE_WORK_ORDERS wo
WHERE wo.TECHNICIAN_NAME = 'Marcus Johnson'
AND wo.SCHEDULED_DATE = CURRENT_DATE();
```

#### 🔄 Transition
> *"Marcus sees the Springfield job—it's marked CRITICAL. Before he drives out, he wants to know exactly what he's dealing with..."*

---

### 📌 Prompt 2: Diagnosis & Fix Instructions

```
What's wrong with device DEV-005 and how do I fix it?
```

#### 🎯 Why This Matters to the Customer
- **First-time fix rate** — Come prepared, fix it once
- **Reduced training burden** — Knowledge base on demand
- **Consistent quality** — Same procedures regardless of tech experience

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Step-by-Step Guidance** | No guesswork in the field |
| **Knowledge Base Access** | Institutional knowledge preserved |
| **Skill Augmentation** | Junior techs perform like seniors |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current device status | 1 device |
| `TROUBLESHOOTING_KB` | Fix procedures | 10 categories |
| Cortex Search: `TROUBLESHOOTING_SEARCH_SVC` | Semantic search | 10 docs |

#### ✅ Auditability — How to Verify
```sql
-- Device current status
SELECT * FROM V_DEVICE_HEALTH_SUMMARY WHERE DEVICE_ID = 'DEV-005';

-- Relevant KB article
SELECT ISSUE_CATEGORY, DIAGNOSTIC_STEPS, REMOTE_FIX_PROCEDURE,
       REQUIRES_DISPATCH, ESTIMATED_REMOTE_FIX_TIME_MINS
FROM TROUBLESHOOTING_KB
WHERE ISSUE_CATEGORY = 'NO_NETWORK';
```

#### 🔄 Transition
> *"The agent pulled troubleshooting steps from the knowledge base. But this is a recurring issue at this facility. Let me check what worked last time..."*

---

### 📌 Prompt 3: Historical Learning

```
Find past incidents at Springfield Urgent Care and how they were resolved
```

#### 🎯 Why This Matters to the Customer
- **Pattern recognition** — Is there a systemic issue at this location?
- **Proven solutions** — What actually worked before?
- **Facility-specific knowledge** — Every location is different

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Institutional Memory** | Learn from past successes |
| **Root Cause Patterns** | Identify recurring issues |
| **Facility Intelligence** | Location-specific insights |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `MAINTENANCE_HISTORY` | Past tickets with resolution notes | 24 records |
| Cortex Search: `MAINTENANCE_HISTORY_SEARCH_SVC` | Semantic search | 24 docs |

#### ✅ Auditability — How to Verify
```sql
-- Past incidents at this facility
SELECT TICKET_ID, DEVICE_ID, ISSUE_TYPE, RESOLUTION_TYPE,
       RESOLUTION_NOTES, TECHNICIAN_ID, CREATED_AT
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID
WHERE d.FACILITY_NAME = 'Springfield Urgent Care'
ORDER BY CREATED_AT DESC;
```

**SAY THIS:**
> *"I can see two previous network issues—both required network cable replacement. That's valuable intel—there might be a wiring problem in that facility. Now Marcus knows exactly what to bring..."*

#### 🔄 Transition
> *"Let me make sure I have the right parts..."*

---

### 📌 Prompt 4: Parts Preparation

```
What parts might I need for a network connectivity issue?
```

#### 🎯 Why This Matters to the Customer
- **First-time fix rate** — Right parts = one trip
- **Inventory optimization** — Know what to stock in trucks
- **Customer experience** — No "I'll come back with the part"

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Parts Prediction** | AI suggests based on past fixes |
| **Truck Stock Optimization** | Data-driven inventory |
| **Reduced Return Trips** | Fix it right the first time |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `TROUBLESHOOTING_KB` | Standard parts by issue | 10 categories |
| `WORK_ORDERS.PARTS_REQUIRED` | Historical parts used | 8 records |

#### ✅ Auditability — How to Verify
```sql
-- Parts typically needed for network issues
SELECT ISSUE_CATEGORY, REMOTE_FIX_PROCEDURE
FROM TROUBLESHOOTING_KB
WHERE ISSUE_CATEGORY IN ('NO_NETWORK', 'CONNECTIVITY_INTERMITTENT');

-- Parts from past similar work orders
SELECT WORK_ORDER_ID, ISSUE_SUMMARY, PARTS_REQUIRED
FROM WORK_ORDERS
WHERE ISSUE_SUMMARY LIKE '%network%' OR ISSUE_SUMMARY LIKE '%connectivity%';
```

**SAY THIS:**
> *"Perfect—the agent recommends ethernet cable and USB network adapter based on past fixes. Marcus is now fully prepared for the job."*

---

### ✅ Field Tech Act Summary

| Feature | Benefit | Business Value |
|---------|---------|----------------|
| 📋 My work queue | Know assignments from anywhere | Productivity |
| 🔧 Fix instructions | Step-by-step from KB | First-time fix rate |
| 📖 Historical learning | What worked at this location | Pattern recognition |
| 🧰 Parts list | Come prepared | No return trips |

#### 🔧 Customization Notes (Field Tech Section)

| What We Used | What You Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Work Orders table** | **ServiceNow / Field Service system** | Bi-directional sync |
| **Technician roster** | **HR/scheduling system** | Import technician data |
| **Troubleshooting KB** | **Your knowledge base** (Confluence, SharePoint) | Ingest into Cortex Search |
| **Parts inventory** | **Inventory management system** | Connect to parts database |

**Knowledge Base Sources:**
- **Existing Documentation**: Device manuals, troubleshooting guides
- **Tribal Knowledge**: Capture from senior technicians
- **Vendor Resources**: Manufacturer documentation
- **Past Tickets**: Resolution notes from ServiceNow

**SAY THIS:**
> *"The knowledge base is powered by Cortex Search—it does semantic search, not just keyword matching. You'd load your existing troubleshooting docs, and the AI finds the most relevant procedures. Technicians can ask questions in natural language."*

---

## 🤖 Act 4: AI Agent Capabilities (16:00 - 18:00)

*Persona: All stakeholders*

### Scene Setup
> "We've seen the agent serve three different personas with three different needs. Let me show a few more examples of what's possible—these are the kinds of ad-hoc questions that would normally require a data analyst."

---

### 📌 Prompt 1: Analytical Comparison

```
Compare average resolution time for remote fixes vs field dispatches
```

**Why it matters:** *"This proves the ROI—remote fixes in minutes vs dispatches in hours. No SQL required."*

---

### 📌 Prompt 2: Geographic Filtering

```
Which facilities in Ohio have devices needing attention?
```

**Why it matters:** *"Operations can filter by region, state, or city—natural language, no dashboard switching."*

---

### 📌 Prompt 3: Trend Analysis

```
What's the most common issue type this month and how are we resolving it?
```

**Why it matters:** *"The agent identifies trends—maybe we need a fleet-wide firmware update."*

---

### 📌 Prompt 4: ML Readiness (for technical audience)

```
What training data do we have available for building ML models?
```

**Why it matters:** *"72K telemetry records, 30 days of history—Snowflake is your ML platform, not just storage."*

---

## 🎬 Closing (18:00 - 20:00)

### The Story We Just Told

> "In 20 minutes, we followed a single issue from the executive dashboard all the way to the technician's truck:
> 
> 1. **Executive** saw fleet health, revenue protection, and flagged a satisfaction issue at Springfield
> 2. **Operations** identified at-risk devices, triaged for remote fix, triggered an automated restart, and validated prediction accuracy
> 3. **Technician** got the assignment, learned from past incidents, and came prepared with the right parts
> 
> All from natural language questions. No SQL. No dashboard switching. No waiting for reports. Every answer traceable to source data."

### Business Impact at Scale (FOCUS Results Delivered)

> "With Snowflake Intelligence and Cortex Agents, you achieve all three FOCUS results:
> 
> **RESULT 1: 40-60% Cost Reduction** 
> - 70%+ issues resolved remotely → 180,000+ avoided dispatches annually
> - $185 saved per remote fix → **$29M+/year in avoided costs**
> - PLUS: 'Last gasp' classification saves additional dispatches by identifying Wi-Fi changes
> 
> **RESULT 2: Phase 1 Target: 95% Uptime** 
> - Current: ~90% (10% offline rate)
> - Intelligent failure classification enables faster resolution
> - Call office for Wi-Fi = 10 min vs dispatch for hardware = 4+ hours
> 
> **RESULT 3: Reduced Provider Churn** 
> - Current: 7-8% annual churn
> - Device reliability directly impacts provider satisfaction
> - Proactive maintenance = happier providers = better retention
> 
> All running natively in Snowflake—Cortex for AI, full governance through your existing security model, complete audit trail."

### 🎯 Closing Remarks by Attendee Interest

**For Mike Walsh (COO):**
> *"Mike, the bottom line: $29M in projected annual savings from a 52% reduction in field dispatches at 150K devices. Plus, 'last gasp' classification means even more savings by routing Wi-Fi issues to phone calls, not truck rolls."**

**For Patrick Arnold (CTO):**
> *"Patrick, this runs entirely in Snowflake—no external ML infrastructure, same governance model, same security perimeter. Cortex Agents are the orchestration layer."*

**For Sharon Patent (CADO):**
> *"Sharon, every answer is auditable, every action is logged. The data lineage is complete from question to source table."*

**For JT Grant (VP Ad Tech):**
> *"JT, we can connect directly to your ad platform to calculate actual revenue impact per device. Pharma partners see real uptime metrics."*

**For Drew Amwoza (SVP Strategy):**
> *"Drew, the roadmap here is Cortex ML for predictions, Cortex Agents for orchestration, and eventually autonomous operations. All native to Snowflake."*

**For Jennifer Kelly (Sr Director Data Engineering):**
> *"Jennifer, the data pipelines use Snowpipe for streaming, or batch ingestion—whatever fits your current architecture. We'd map to your existing schemas."*

### Call to Action
> "Would you like to see how this could work with your data? We can set up a proof-of-concept with your actual device telemetry in days, not months."

### 🤔 Discovery Questions

> **Before we wrap, I'd love to understand:**
> 1. "What does your device telemetry pipeline look like today?" *(Jennifer)*
> 2. "What's your current dispatch cost per incident?" *(Mike/Jonathan)*
> 3. "Do you track revenue impact per device from your ad platform?" *(JT)*
> 4. "What governance requirements would apply to automated actions?" *(Sharon)*
> 5. "Where do you see the biggest gap in the architecture I showed?" *(Drew/Patrick)*

---

## 🛠️ Pre-Demo Checklist

- [ ] SQL scripts 01-05 executed successfully
- [ ] Agent created in Snowsight (AI & ML → Agents)
- [ ] Semantic views added to agent
- [ ] Cortex Search services added
- [ ] **Test the full flow once before demo**
- [ ] Snowflake Intelligence accessible

---

## Data Inventory (For Auditability Questions)

> **Note:** Demo uses 100 representative devices. Production scales to 150,000 across 30,000 offices.

| Table | Demo Records | Production Scale | Purpose | Key Columns |
|-------|--------------|------------------|---------|-------------|
| `DEVICE_INVENTORY` | 100 | 150,000 | Device master data | DEVICE_ID, STATUS, NETWORK_TYPE, HOURLY_AD_REVENUE_USD |
| `DEVICE_TELEMETRY` | ~72,000 | ~108M/month | Health metrics (hourly) | CPU_TEMP, CPU_USAGE, MEMORY_USAGE, WIFI_SIGNAL_STRENGTH |
| `DEVICE_LAST_GASP` | 5 | ~15,000/month | Failure classification | CLASSIFIED_CAUSE, SIGNAL_TREND, CLASSIFICATION_CONFIDENCE |
| `MAINTENANCE_HISTORY` | 24 | ~15,000/month | Past service tickets | ISSUE_TYPE, RESOLUTION_TYPE, COST_USD |
| `TROUBLESHOOTING_KB` | 14 | 100+ | Fix procedures | ISSUE_CATEGORY, SUCCESS_RATE_PCT |
| `WORK_ORDERS` | 8 | ~3,000/day | Active jobs | PRIORITY, STATUS, AI_DIAGNOSIS |
| `TECHNICIANS` | 6 | 500+ | Field team | COVERAGE_STATES, SPECIALIZATION |
| `PROVIDER_FEEDBACK` | 14 | ~100,000 | Customer satisfaction | NPS_SCORE, SATISFACTION_RATING |
| `DEVICE_DOWNTIME` | 10 | ~7,500/month | Revenue impact | DOWNTIME_HOURS, REVENUE_LOSS_USD |
| `EXTERNAL_ACTION_LOG` | Variable | Growing | Action audit trail | ACTION_TYPE, TIMESTAMP, PAYLOAD |

---

## 🔒 Governance & Compliance Talking Points

If asked about security, governance, or compliance:

> "Everything runs inside Snowflake's security perimeter:
> - **Role-based access control** — Same RBAC you use for all Snowflake data
> - **Data never leaves Snowflake** — Cortex processes data in-place
> - **Complete audit trail** — Every query, every action logged
> - **No data copying** — AI operates on live data, not exports
> - **SOC 2, HIPAA eligible** — Snowflake's certifications apply"

---

## 💬 Objection Handling

### "How is this different from our current monitoring tool?"
> "Traditional monitoring tools show you WHAT happened. Cortex Agents tell you WHAT, WHY, and WHAT TO DO—in natural language. Plus, they can take action, not just alert."

### "What if the AI gives a wrong answer?"
> "Every answer is grounded in your data—you can see the SQL it generated. The semantic model constrains the AI to your business logic. And for actions, everything is logged for audit."

### "How long does implementation take?"
> "We can have a proof-of-concept running on your data in 1-2 weeks. Production deployment depends on integration complexity—typically 4-8 weeks."

### "What about data we have outside Snowflake?"
> "Snowflake's data sharing and integration capabilities can bring in data from almost any source. The agent works on whatever data is in Snowflake."

---

## 🗺️ Implementation Roadmap

### Phase 0: Discovery (Week 0) — Questions to Answer

| Area | Questions to Ask | Who to Ask |
|------|---------------------------|------------|
| **Data Acquisition** | Where is device telemetry stored today? What format? | Jennifer Kelly |
| **Data Acquisition** | How frequently is telemetry captured? (5-min, hourly?) | Jennifer Kelly |
| **Data Acquisition** | What's the pipeline from IoT platform to warehouse? | Jennifer Kelly |
| **Data Governance** | Who owns device data? Ad revenue data? | Sharon Patent |
| **Data Governance** | What RBAC model applies? HIPAA considerations? | Sharon Patent |
| **Data Governance** | What audit requirements exist? | Sharon Patent |
| **Data Hygiene** | How complete is device inventory? Missing devices? | Liberty Holt |
| **Data Hygiene** | Are telemetry values consistent across device types? | Liberty Holt |
| **Data Hygiene** | How current is ServiceNow data? Lag? | Jonathan Richman |
| **Integration** | What's the device management API? Can we send commands? | Jonathan Richman |
| **Integration** | What ticketing system? ServiceNow? | Jonathan Richman |
| **Business** | What's actual dispatch cost? (We used $185) | Mike Walsh |
| **Business** | What's the remote fix rate today? | Mike Walsh |

### Phase 1: Data Foundation (Week 1-2)

| Task | Data Source | Snowflake Target | Owner |
|------|-------------|------------------|-------|
| Device inventory | IoT Platform | `DEVICE_INVENTORY` | IoT Team |
| Telemetry stream | IoT Platform | `DEVICE_TELEMETRY` | Data Engineering |
| Maintenance history | ServiceNow | `MAINTENANCE_HISTORY` | IT Ops |
| Ad revenue data | Ad Platform (GAM) | `AD_REVENUE` | Ad Ops |
| Provider feedback | CRM/Surveys | `PROVIDER_FEEDBACK` | Customer Success |

### Phase 2: Analytics Layer (Week 2-3)

| Task | Deliverable | Customization Needed |
|------|-------------|---------------------|
| Health score formula | `V_DEVICE_HEALTH_SUMMARY` | Tune weights for your devices |
| Risk thresholds | Risk classification logic | Analyze historical failures |
| ROI calculations | `V_ROI_ANALYSIS` | Input actual cost data |
| Semantic views | Cortex Analyst models | Map to your business terms |

### Phase 3: AI Agent (Week 3-4)

| Task | Deliverable | Effort |
|------|-------------|--------|
| Knowledge base ingestion | Cortex Search service | Load troubleshooting docs |
| Agent configuration | `DEVICE_MAINTENANCE_AGENT` | Customize instructions |
| Tool setup | Semantic views + Search | Map to your data |
| Testing | End-to-end validation | Refine responses |

### Phase 4: Integrations (Week 4-6)

| Integration | Method | Priority |
|-------------|--------|----------|
| Device Management API | External Function | High |
| ServiceNow | Native App or External Function | High |
| Slack/Teams Alerts | External Function (Webhook) | Medium |
| PagerDuty Escalation | External Function | Medium |
| ML Model Training | Cortex ML | Phase 2 |

### Quick Win: Proof of Concept Scope

**For a 2-week POC, focus on:**
1. ✅ 1,000 devices (subset of fleet)
2. ✅ 30 days of telemetry
3. ✅ Basic health score formula
4. ✅ 5-10 executive/ops prompts
5. ✅ No external integrations (simulated actions)

**This proves:**
- Natural language querying works
- Data model scales
- AI provides accurate, actionable insights

---

## 📊 Data Mapping Quick Reference

| Demo Data | Production Equivalent | Notes |
|-----------|------------------------|-------|
| `DEVICE_ID` (DEV-001) | Your device serial numbers | Primary key for all joins |
| `FACILITY_NAME` | Provider account name | From CRM/master data |
| `HOURLY_AD_REVENUE_USD` | CPM × impressions/hour | From ad platform |
| `CPU_TEMP_CELSIUS` | Your telemetry field name | Map 1:1 or transform |
| `HEALTH_SCORE` | Calculated field | Formula is customizable |
| `TICKET_ID` | ServiceNow incident number | For correlation |
| `TECHNICIAN_ID` | Employee ID | From HR system |

---

## 🎯 Success Metrics for POC

| Metric | Demo Baseline | POC Target | Production Target |
|--------|---------------|------------|-------------------|
| Query accuracy | 90% | 85% | 90%+ |
| Response time | <5 sec | <10 sec | <5 sec |
| User adoption | N/A | 5 pilot users | 50+ users |
| Remote fix rate | 60% | Measure baseline | 60%+ |
| Prediction accuracy | 85% | Measure baseline | 85%+ |
