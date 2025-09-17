# Telecom-SQL-Customer-Segmentation.

## Project Background

NexaSat, a mid-sized telecom provider, delivers **mobile voice and data services through prepaid and postpaid plans**. The company was facing growing challenges in retaining customers and maximizing revenue from its existing user base. **High churn rates, unclear customer value segments, and limited visibility into cross-sell and upsell opportunities were slowing business growth**.

To address these challenges, customer usage and billing data was analyzed using SQL to uncover key behavioral patterns. The analysis focused on segmenting customers by **Customer Lifetime Value (CLV), identifying revenue drivers, and surfacing opportunities for churn reduction through**.

### Insights and recommendations were provided in the following areas:

- **Customer segmentation and CLV profiling:** Grouped customers into High, Medium, and Low value tiers, helping NexaSat prioritize resources toward high-value clients while designing retention strategies for lower tiers.

- **Churn risk analysis and retention strategies:** Identified customer groups most likely to leave, enabling proactive engagement (e.g., offering support to senior citizens without dependents).

- **Revenue contribution and ARPU optimization:** Measured average revenue per user across segments to show which customer groups were driving profitability.

- **Plan-level performance and pricing opportunities:** Compared prepaid vs postpaid and basic vs premium plans to highlight which combinations were most lucrative or underperforming.

- **Upselling and cross-selling strategies:** Found opportunities to offer premium plans or value-added services (like tech support) to under-served groups, boosting both revenue and customer satisfaction.

- The SQL queries used to inspect and clean the data for this analysis can be found here [Nexas_EDA_data_transformation.sql](./Nexas_EDA_data_transformation.sql).

- The SQL queries used to analyze revenue, customer segments, and upselling/cross-selling opportunities can be found here [Nexas_Analysis_Queries.sql](./Nexas_Analysis_Queries.sql).


## Executive Summary
### Overview of Findings

This analysis examines NexaSat’s customer base and revenue dynamics using SQL queries. Out of **7,043 total customers, 2,771 (39.4%) have churned**, leaving **4,272 active customers.** Exploratory analysis (EDA) was performed on the full customer base to understand overall patterns, while revenue and strategy-focused insights were derived only from active customers.

The analysis highlights three critical themes:

- **Revenue Concentration:** High and Medium CLV customers drive the majority of revenue despite being fewer in number.

- **Plan-Level Dynamics:** Premium plans, particularly Postpaid Premium, are the backbone of revenue.

- **Cross-Sell Opportunities:** Specific groups (e.g., Medium CLV on Basic plans, Low CLV with no add-ons) present clear upsell potential.

### Insights Deep Dive

### Customer Base & Churn

- **Total Customers: 7,043**

- **Churned Customers: 2,771 (≈39.4%)**

- **Active Customers (Analyzed for revenue): 4,272**

- Among active customers, the largest segment is **Medium CLV (2,581 customers),** followed by **Low CLV (1,377)**, and **High CLV (314).**

### Revenue Insights

- **Total Active Customer Revenue: ₦19.47M**

- **Revenue by CLV: Medium CLV contributes ₦13.56M, High CLV ₦4.57M, Low CLV ₦1.36M.**

- **Revenue by Plan Type & Level:**

- Postpaid Premium: ₦10.63M (1,403 customers)

- Prepaid Premium: ₦6.77M (1,612 customers)

- Postpaid Basic: ₦1.76M (772 customers)

- Prepaid Basic: ₦0.33M (485 customers)

### Profitability (ARPU)

Overall ARPU: ₦4,561.35

By CLV Segment: High CLV (₦14,552.76), Medium CLV (₦5,253.73), Low CLV (₦985.22).

Cross-Selling Opportunities

Low CLV without add-ons: 412 customers could be targeted for Tech Support / Multiple Lines.

Medium CLV on Basic Plan: 188 customers generating ₦955,709 could be upgraded to Premium.

Senior Citizens without support: 137 customers lack dependents and Tech Support, representing a niche upsell group.

📌 Takeaway for Stakeholders:
NexaSat’s profitability rests heavily on Medium and High CLV customers, particularly those on Premium Postpaid plans. However, nearly 40% of the original base has already churned, underscoring the need for proactive retention. At the same time, upselling low- and medium-value groups represents a clear path to sustainable revenue growth.
  
