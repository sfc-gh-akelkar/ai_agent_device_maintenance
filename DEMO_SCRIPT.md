# Predictive Device Maintenance Demo Script

**Duration:** 20 minutes  
**Audience:** Data Engineers, Data Scientists, Senior Leadership  
**Platform:** Snowflake Intelligence + Cortex Agents

---

## Audience Focus

| Audience | What They Care About | What Impresses Them |
|----------|---------------------|---------------------|
| **Data Engineers** | SQL quality, data architecture, pipeline integration, semantic model design | "Show me the SQL", lineage, how sources connect |
| **Data Scientists** | ML model accuracy, feature engineering, model operationalization, inference pipeline | XGBoost details, prediction confidence, model registry |
| **Sr Leadership** | ROI, strategic value, competitive advantage, time-to-value | Business impact numbers, cost savings |

---

## FOCUS Framework Alignment

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| Lost Advertising Revenue | AI Agent Implementation | Revenue Protection |
| High Operational Costs | Automated Remote Resolution | 52% Cost Reduction |
| 10%+ Device Offline Rate | AI/ML Predictive Models + Last Gasp Analysis | Target: 95% Uptime |
| Wi-Fi Dependency (90%+) | Failure Classification | Smart Triage: Call Office vs Dispatch |

---

## KEY CONTEXT: Network Reality

> **SAY THIS EARLY:** *"The company has 150,000 devices across 30,000 provider offices. Here's the challenge: 90%+ of these devices run on the PROVIDER'S Wi-Fi—not company-managed networks. When a device goes offline, the #1 cause is the provider changed their Wi-Fi password. This changes everything about how we triage and resolve issues."*

---

## 🎯 Demo Questions Quick Reference

| # | Question | Key Highlight | Grade |
|---|----------|---------------|-------|
| **Q1** | Fleet health & business impact | Comprehensive executive summary | A+ |
| **Q2** | Revenue loss from downtime | Focused on demo data, 1% = $10K/month | A |
| **Q3** | Annual cost & projected savings | **$55M baseline, $29M savings, 52%** | A+ |
| **Q4** | Monthly savings from remote fixes | $3,515 saved, 79% remote rate | A |
| **Q5** | Customer satisfaction score | 4.5/5, NPS 8.6 | A |
| **Q6** | Critical/high risk devices | Table + prioritization | A+ |
| **Q6b** | DEV-025 failure classification | **🌟 DEMO CENTERPIECE** - 92% Wi-Fi | A+ |
| **Q7** | Remote fix analysis | Smart triage, honest uncertainty | A+ |
| **Q8** | Predicted failures in 48 hours | Proactive maintenance showcase | A+ |
| **Q9** | Remote restart action | Closed loop + audit trail | A |

---

## 🎬 Opening (2 minutes)

### What to Say

> *"The company operates 150,000 IoT devices—HealthScreen displays—across 30,000 provider offices nationwide. These screens generate advertising revenue from pharmaceutical partners.*
>
> *Here's the challenge:*
> 1. **10%+ Offline Rate**: About 15,000 devices are offline at any time—that's revenue walking out the door
> 2. **Wi-Fi Dependency**: 90%+ of devices run on the provider's Wi-Fi—when they change their password, the device goes dark
> 3. **Wrong Triage**: We're dispatching $185 technicians for problems that could be fixed with a phone call
>
> *Today I'll show you how Snowflake Intelligence and Cortex Agents solve this with intelligent failure classification—knowing whether to call the office or dispatch a tech."*

### What to Do
1. Open **Snowflake Intelligence** (AI & ML → Snowflake Intelligence)
2. Select the **Device Maintenance Assistant** agent
3. Briefly show the chat interface

---

## 📌 Q1: Fleet Health & Business Impact Summary

### Before You Ask

> *"Let's start with what executives care about: the big picture. Imagine you're the VP of Operations walking into a Monday morning meeting. You need instant answers—no waiting for reports, no switching between dashboards."*
>
> *"Watch what happens when I ask a simple question..."*

### The Question

```
Give me a summary of our device fleet health and business impact
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| Total Devices | 100 (representing 150K production) |
| Online | 88 devices (88%) |
| Offline | 8 devices (8%) |
| Health Score | 77.9/100 (Good) |
| Uptime | 89.97% (target: 95%) |
| Annual Field Dispatch Cost | $55.5M baseline |
| Projected Annual Savings | $28.8M (52% reduction) |
| Remote Fix Rate | 70.2% |
| NPS Score | 8.6 |

### After the Response

**For Data Engineers:**
> *"This pulls from 4 integrated semantic views in a single query: device health, ML predictions, customer satisfaction, and ROI analysis. The semantic model handles all the joins—the user just asks a question."*

**For Data Scientists:**
> *"Notice '9 devices at risk of failure.' That's coming from our XGBoost model running batch inference on telemetry features. The model is trained on 6 months of failure history."*

**For Sr Leadership:**
> *"From question to board-ready metrics in 3 seconds. $55M baseline, $29M projected savings—that's your ROI story. And the 70% remote fix rate means we're exceeding targets."*

### Transition

> *"Good overview. Let me show you the revenue picture more specifically..."*

---

## 📌 Q2: Revenue Loss from Downtime

### Before You Ask

> *"The 8% offline rate isn't just a technical problem—it's a revenue problem. Every hour a device is down, we lose advertising revenue. Let me show you exactly how much..."*

### The Question

```
How much advertising revenue are we losing from device downtime?
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| Monthly Revenue Loss | $91,429 (8.8% gap) |
| Potential Monthly Revenue | $1,040,940 |
| Actual Monthly Revenue | $949,511 |
| Downtime | 21 hours across 2 incidents |
| Key Insight | 1% uptime improvement = ~$10,400/month |

### After the Response

**For Data Engineers:**
> *"The revenue calculation joins device inventory (CPM rates) with downtime records. It's not a hardcoded number—it's calculated live from the data. I can show you the SQL if you'd like."*

**For Data Scientists:**
> *"Notice it calculated the opportunity cost automatically. Every 1% improvement in uptime is worth $10,400/month. That's a derived metric the semantic model exposes."*

**For Sr Leadership:**
> *"$91K monthly loss, ~$1.1M annually from current downtime. Reaching our 95% uptime target would recover $64K monthly. That's the business case for predictive maintenance."*

### Transition

> *"That's the revenue impact. Now let's look at the cost side—what are we spending on field service, and how much can we save?"*

---

## 📌 Q3: Annual Field Service Cost & Savings

### Before You Ask

> *"This is the ROI question. We spend millions on field dispatches every year. What if we could cut that in half by fixing problems remotely?"*

### The Question

```
What's our annual field service cost and projected savings?
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| Annual Field Dispatch Cost | $55.5M (at 150K devices) |
| Average Dispatch Cost | $185 per incident |
| Average Remote Fix Cost | $25 per incident |
| Projected Annual Savings | $28.8M (52% reduction) |
| Dispatches Avoided | 180,000 annually |
| Remote Fix Rate | 70.2% |

### After the Response

**For Data Engineers:**
> *"The math is simple: 150K devices × 2 issues/device/year × $185/dispatch = $55M. The view pre-calculates this so the AI returns consistent numbers."*

**For Data Scientists:**
> *"Those 180,000 avoided dispatches are driven by the ML model's ability to predict which issues can be fixed remotely. The model learns from resolution history."*

**For Sr Leadership:**
> *"This is your headline for the board: $55M baseline, $29M savings, 52% reduction. Conservative estimate—doesn't include revenue protection or customer satisfaction gains."*

### Transition

> *"That's the projection at scale. Let me show you the actual savings we're achieving right now..."*

---

## 📌 Q4: Monthly Savings Achieved

### Before You Ask

> *"Projections are great, but what about actual results? Let me show you real savings from this month's data..."*

### The Question

```
How much have we saved this month from remote fixes?
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| This Month's Savings | $3,515 |
| Remote Fixes Completed | 19 |
| Total Maintenance Activities | 24 |
| Remote Fix Rate | 79% (exceeds 70% target) |
| Savings per Remote Fix | $160 ($185 - $25) |

### After the Response

**For Data Engineers:**
> *"This comes from the maintenance history table. Each ticket has a resolution type—remote vs dispatch—and we calculate savings per ticket. Full audit trail."*

**For Data Scientists:**
> *"79% remote fix rate this month—that's exceeding our 70% target. The triage model is working. We can track this trend over time to measure improvement."*

**For Sr Leadership:**
> *"$3,515 saved this month from 19 remote fixes. That's not a projection, that's actual cost avoidance. Annualized, that's on track for our $29M target."*

### Transition

> *"Good—we're saving real money. But let's also check customer satisfaction..."*

---

## 📌 Q5: Customer Satisfaction

### Before You Ask

> *"Cost savings matter, but so does customer experience. Device reliability directly impacts provider satisfaction and churn. Let me check our NPS..."*

### The Question

```
What is our customer satisfaction score?
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| Satisfaction Score | 4.5/5 stars |
| NPS Score | 8.6 (Promoter territory) |
| Device Reliability Rating | 4.6/5 |
| Positive Feedback | 11 |
| Negative Feedback | 1 |
| Follow-ups Pending | 1 |

### After the Response

**For Data Engineers:**
> *"This pulls from the provider feedback table—would connect to Qualtrics or Salesforce in production. Same semantic model, real customer data."*

**For Data Scientists:**
> *"NPS of 8.6 is in promoter territory. We can correlate this with device uptime to prove that reliability drives satisfaction."*

**For Sr Leadership:**
> *"High satisfaction despite the 8% offline rate. Imagine what we could achieve at 95% uptime. That 1 negative feedback? Probably related to a device issue we can fix."*

### Transition

> *"Good customer health. Now let's get operational—which devices need attention right now?"*

---

## 📌 Q6: Critical & High Risk Devices

### Before You Ask

> *"Time to get tactical. As an ops manager, I need to know: what's at risk TODAY? What needs immediate attention?"*

### The Question

```
Which devices have critical or high risk levels?
```

### Expected Response Highlights

| Category | Count | Details |
|----------|-------|---------|
| Critical Risk | 8 devices | All currently offline |
| High Risk | 1 device | DEV-018 - performance degradation |
| Worst Health Score | DEV-071 (10) | Requires urgent attention |
| Best Transition Device | DEV-025 | Good candidate for investigation |

### After the Response

**For Data Engineers:**
> *"This is pulling from the ML predictions table joined with device inventory. The table format makes it actionable—device IDs, health scores, install dates."*

**For Data Scientists:**
> *"The health scores come from our XGBoost model. DEV-071 at 10 means high failure probability. DEV-018 at 65 with 'performance degradation' shows the model catching issues before complete failure."*

**For Sr Leadership:**
> *"9 devices need attention. 8 are already offline—that's the problem. But 1 (DEV-018) is still online and degrading. That's the power of predictive maintenance—we can act before it fails."*

### Transition

> *"I see DEV-025 in the list—an offline device in Appleton, WI. Let me show you something powerful: WHY did it go offline?"*

---

## 🌟 Q6b: Last Gasp Failure Classification (DEMO CENTERPIECE)

### Before You Ask

> *"This is the key differentiator. Traditional monitoring tells you a device is offline. Our system tells you WHY—and that changes everything about how you respond."*
>
> *"Watch this..."*

### The Question

```
Why did device DEV-025 go offline? Is it a Wi-Fi password change?
```

### Expected Response Highlights

| Metric | Expected Value |
|--------|----------------|
| Classified Cause | WIFI_PASSWORD_CHANGE |
| Confidence Level | 92% (Very High) |
| Signal Pattern | SUDDEN_DROP |
| Signal Change | -45 to -88 dBm in <2 minutes |
| CPU/Memory | Normal (rules out hardware) |
| Recommendation | **DO NOT dispatch technician** |
| Action | Call the provider office for new Wi-Fi password |

### After the Response — THE KEY MOMENT

**Pause and emphasize:**
> *"THIS is the differentiator. We're not just saying 'device offline.' We're classifying WHY it's offline with 92% confidence."*

**For Data Engineers:**
> *"The 'Last Gasp' analysis looks at the final telemetry before disconnect. Signal dropped suddenly from -45 dBm (strong) to -88 dBm (poor) in under 2 minutes. CPU and memory were normal. That pattern screams 'Wi-Fi password change,' not hardware failure."*

**For Data Scientists:**
> *"The classification model was trained on 6 months of failure patterns. Sudden signal drops with normal CPU/memory correlate 92% with credential changes. GRADUAL signal decline would suggest hardware. STABLE signal with high CPU suggests overheating. Different patterns, different actions."*

**For Sr Leadership:**
> *"Here's the ROI: Without this classification, we dispatch a $185 technician. Instead, we call the office, get the new password, reconnect remotely for $25. That's $160 saved per incident. At 10% offline rate with 90% being Wi-Fi issues... that's millions."*

### The Business Impact Statement

> *"Let me be clear: this one classification just saved $160. The device went offline. Traditional monitoring would create a ticket and dispatch a technician. Our system analyzed the 'Last Gasp' telemetry and determined with 92% confidence this is a Wi-Fi password change.*
>
> *The recommended action? Call the office. That's a $25 phone call instead of a $185 truck roll. At scale, this is a $29 million annual savings."*

### Transition

> *"Now that we know WHY devices are offline, let me show you the full triage picture—which of the 9 at-risk devices can be fixed remotely?"*

---

## 📌 Q7: Remote Fix Analysis

### Before You Ask

> *"Not all offline devices are the same. Some need a technician. Some need a phone call. Some we should just wait and monitor. The AI should tell us which is which..."*

### The Question

```
Can any of these be fixed remotely?
```

### Expected Response Highlights

| Category | Devices | Action |
|----------|---------|--------|
| Remote Fix (Wi-Fi) | DEV-025 | Call Appleton Walk-In Care |
| Monitor & Wait | DEV-081 | Network outage - will self-resolve |
| Requires Dispatch | DEV-031 | Hardware failure (high CPU, errors) |
| Need Investigation | 6 devices | Insufficient classification data |

### After the Response

**For Data Engineers:**
> *"Notice it correlated DEV-081 with other devices at the same facility to detect a network outage. That's multi-device pattern recognition, not just single-device analysis."*

**For Data Scientists:**
> *"The model is honest about uncertainty—6 devices need more telemetry before classification. That builds trust. It's not hallucinating answers for devices it can't classify."*

**For Sr Leadership:**
> *"Look at the cost breakdown: 2 devices we don't dispatch ($370 saved), 1 device we do dispatch ($185 spent), 6 we investigate further. Smart triage, not blanket dispatch."*

### Transition

> *"Good triage. But what about devices that are ABOUT to fail? Can we catch them before they go offline?"*

---

## 📌 Q8: Predicted Failures in 48 Hours

### Before You Ask

> *"This is predictive maintenance in action. We're not just reacting to failures—we're predicting them 24-48 hours in advance. Watch..."*

### The Question

```
Which devices are predicted to fail in 48 hours?
```

### Expected Response Highlights

| Category | Count | Details |
|----------|-------|---------|
| Critical (Already Offline) | 8 devices | 0 hours to failure |
| Warning (Predicted) | 4 devices | 24 hours to failure |
| Primary Risk Factor | Performance degradation | CPU/memory trends |

### After the Response

**For Data Engineers:**
> *"This comes from the XGBoost model running batch inference on telemetry features. The predictions are materialized to a table for performance—no live inference during queries."*

**For Data Scientists:**
> *"The 4 WARNING devices are the value here—they're still online but predicted to fail. The model detected early degradation patterns. If we intervene now, we prevent the failure entirely. That's the shift from reactive to proactive."*

**For Sr Leadership:**
> *"Those 4 devices still work. The ML model detected early warning signs. If we fix them now, we prevent 4 outages, save 4 dispatches, protect 4 revenue streams. That's predictive maintenance."*

### Transition

> *"We've diagnosed issues. We've predicted failures. Now watch this—the agent can actually TAKE ACTION..."*

---

## 📌 Q9: Remote Restart Action (Closed Loop)

### Before You Ask

> *"This is the difference between a chatbot and an AI agent. A chatbot answers questions. An agent takes action. Watch what happens when I ask it to fix something..."*

### The Question

```
Attempt a remote restart on device DEV-003
```

### Expected Response Highlights

| Aspect | Expected |
|--------|----------|
| Status | ✅ Command sent |
| Action | RESTART_SERVICES |
| Audit | Logged with timestamp, device ID, reason |
| Note | Simulated for demo (real API in production) |

### After the Response

**For Data Engineers:**
> *"In production, this calls your device management API via Snowflake External Functions. Same RBAC, same audit trail, same security perimeter. The procedure is a stored proc that logs every action."*

**For Data Scientists:**
> *"This is closed-loop ML: predict failure → recommend action → execute action → log result. The model can learn from outcomes to improve future predictions."*

**For Sr Leadership:**
> *"Every action is logged for compliance. Who initiated it, what command, which device, when. Full audit trail. This is enterprise-grade AI, not a toy."*

### Follow-up (Optional)

> *"Want to see the audit trail? Ask: 'Show me recent actions taken on devices'"*

---

## 🎬 Closing (2 minutes)

### The Story We Told

> *"In 20 minutes, we went from executive dashboard to operational action:*
>
> 1. **Big Picture** (Q1-Q5): Fleet health, revenue impact, cost savings, customer satisfaction
> 2. **Deep Dive** (Q6-Q6b): Which devices need attention, and WHY they failed
> 3. **Smart Triage** (Q7): Call office vs dispatch tech vs wait and monitor
> 4. **Predictive** (Q8): Catch failures BEFORE they happen
> 5. **Action** (Q9): The AI doesn't just recommend—it executes
>
> *All from natural language questions. No SQL. No dashboard switching. No waiting for reports."*

### Business Impact Summary

> *"The bottom line:*
>
> - **$55M** annual field service baseline
> - **$29M** projected savings (52% reduction)
> - **180,000** avoided dispatches annually
> - **'Last Gasp' classification** means even more savings—Wi-Fi issues get phone calls, not truck rolls
>
> *All running natively in Snowflake—Cortex for AI, your existing governance model, complete audit trail."*

### Audience-Specific Closes

**For Data Engineers:**
> *"The semantic model handles the complexity. 3 views covering device health, maintenance operations, and business impact. You define the relationships once, and the AI uses them for any question."*

**For Data Scientists:**
> *"The XGBoost models are logged in Snowflake's Model Registry. Batch inference runs daily. Predictions are materialized for performance. You can retrain on new data anytime."*

**For Sr Leadership:**
> *"This is enterprise AI that works today. $29M in savings, 52% cost reduction, and we can have a POC running on your data in 2 weeks."*

### Call to Action

> *"Would you like to see this with your data? We can set up a proof-of-concept with your actual device telemetry in days, not months."*

---

## 🛠️ Pre-Demo Checklist

- [ ] SQL scripts 01-05 executed successfully
- [ ] **ML notebook executed** (`notebooks/ML_Device_Failure_Prediction.ipynb`)
  - [ ] XGBoost models trained and logged to registry
  - [ ] `T_ML_PREDICTIONS` table populated
- [ ] SQL script 06 executed (enhanced capabilities)
- [ ] Agent created in Snowsight (AI & ML → Agents)
- [ ] Semantic views added to agent (3 views: SV_DEVICE_ANALYTICS, SV_MAINTENANCE_OPERATIONS, SV_BUSINESS_IMPACT)
- [ ] Cortex Search services added
- [ ] **Test the full Q1-Q9 flow once before demo**
- [ ] Snowflake Intelligence accessible

---

## 📊 Expected Values Quick Reference

| Question | Key Metric | Expected Value |
|----------|------------|----------------|
| Q1 | Health Score | 77.9/100 |
| Q1 | Online/Offline | 88/8 devices |
| Q1 | Annual Cost | $55.5M |
| Q1 | Projected Savings | $28.8M (52%) |
| Q2 | Monthly Revenue Loss | $91,429 |
| Q2 | 1% Improvement Value | ~$10,400/month |
| Q3 | Dispatches Avoided | 180,000/year |
| Q4 | This Month's Savings | $3,515 |
| Q4 | Remote Fix Rate | 79% |
| Q5 | Satisfaction | 4.5/5 stars |
| Q5 | NPS | 8.6 |
| Q6 | Critical Devices | 8 |
| Q6 | High Risk Devices | 1 |
| Q6b | DEV-025 Cause | WIFI_PASSWORD_CHANGE |
| Q6b | Confidence | 92% |
| Q6b | Pattern | SUDDEN_DROP |
| Q7 | Remote Fixable | 2 devices |
| Q7 | Needs Dispatch | 1 device |
| Q8 | Predicted Failures | 12 total (8 offline + 4 warning) |
| Q9 | Action Status | ✅ Command sent |

---

## 💬 Objection Handling

### "How is this different from our current monitoring tool?"
> *"Traditional monitoring tells you WHAT happened. Cortex Agents tell you WHAT, WHY, and WHAT TO DO—in natural language. Plus, they can take action, not just alert."*

### "What if the AI gives a wrong answer?"
> *"Every answer is grounded in your data—you can see the SQL it generated. The semantic model constrains the AI to your business logic. For actions, everything is logged for audit."*

### "How long does implementation take?"
> *"POC in 2 weeks on your data. Production deployment typically 4-8 weeks depending on integration complexity."*

### "Is the ML model really working?"
> *"The XGBoost models are logged in Snowflake's Model Registry. You can see the training metrics, feature importance, and prediction accuracy. We can show you the notebook that trained them."*

### "What about data we have outside Snowflake?"
> *"Snowflake's data sharing and integration capabilities can bring in data from almost any source. The agent works on whatever data is in Snowflake."*

---

## 🔒 Governance & Compliance

> *"Everything runs inside Snowflake's security perimeter:*
> - **Role-based access control** — Same RBAC you use for all Snowflake data
> - **Data never leaves Snowflake** — Cortex processes data in-place
> - **Complete audit trail** — Every query, every action logged
> - **No data copying** — AI operates on live data, not exports
> - **SOC 2, HIPAA eligible** — Snowflake's certifications apply"*

---

## 📋 Source Systems Simulated

| Source System | Demo Data | Production Equivalent |
|---------------|-----------|------------------------|
| **IoT Platform** | `DEVICE_INVENTORY`, `DEVICE_TELEMETRY` | AWS IoT, Azure IoT, Particle |
| **Ad Platform** | `HOURLY_AD_REVENUE_USD` | Google Ad Manager, direct contracts |
| **Field Service** | `WORK_ORDERS`, `MAINTENANCE_HISTORY` | ServiceNow, Salesforce FSL |
| **CRM/Surveys** | `PROVIDER_FEEDBACK` | Qualtrics, Salesforce |
| **Knowledge Base** | `TROUBLESHOOTING_KB` | Confluence, SharePoint |
| **Device API** | `SEND_DEVICE_COMMAND` procedure | Your device management API |
| **Last Gasp** | `DEVICE_LAST_GASP` | Final telemetry before disconnect |
