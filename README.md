Markdown
# 📦 Logistics Optimization for Delivery Routes – FedEx

This repository contains an end-to-end data cleaning, SQL analysis, and KPI reporting project focused on **FedEx Logistics and Route Optimization**. The project evaluates delivery delays, route efficiencies, warehouse performance, and agent metrics to uncover operational bottlenecks and suggest optimizations.

---

## 📌 Project Overview
Efficient supply chain management is critical for minimizing delivery delays and maximizing customer satisfaction. 
* **Problem Statement:** Analyze multi-table relational logistics data (orders, shipments, routes, warehouses, and agents) to identify bottlenecks, measure warehouse and route efficiencies, and optimize overall logistics performance.
* **Domain:** Supply Chain / Logistics Analytics
* **Goal:** Use advanced SQL queries, window functions, CTEs, and visualization tools to deliver actionable insights on shipping delays and operational bottlenecks.

---

## 📊 Workflow & Methodology

1. **Task 1: Data Cleaning & Preparation**
   * Identified and deleted duplicate records for `order_id` and `shipment_id`[cite: 5].
   * Checked and handled null values in `delay_hours`[cite: 6].
   * Standardized all date columns (`order_date`, `pickup_date`, `delivery_date`) into `YYYY-MM-DD HH:MM:SS` format[cite: 7].
   * Validated data integrity to ensure no `delivery_date` occurs before `pickup_date`[cite: 8].

2. **Task 2: Delivery Delay Analysis**
   * Calculated delivery delay in hours using `TIMESTAMPDIFF` between `pickup_date` and `delivery_date`[cite: 10].
   * Ranked shipments by delay within each warehouse using SQL window functions (`DENSE_RANK`)[cite: 12].
   * Compared service-level efficiencies between **Express** and **Standard** delivery types[cite: 13].

3. **Task 3: Route Optimization Insights**
   * Computed average transit times and average delay per route[cite: 15, 16].
   * Developed a **Distance-to-Time Efficiency Ratio** (`distance_km / avg_transit_time_hours`) to isolate underperforming routes like `R003`, `R015`, and `R006`[cite: 17, 18, 20].
   * Isolated routes with high percentages of delayed shipments exceeding expected transit windows[cite: 19].

4. **Task 4: Warehouse Performance**
   * Evaluated dispatch response times (`pickup_date - order_date`) to locate top lagging warehouses (`W007`, `W006`, `W002`)[cite: 22].
   * Utilized Common Table Expressions (CTEs) to find warehouses exceeding global average delays[cite: 24].
   * Ranked all warehouses based on on-time delivery percentages and calculated capacity utilization[cite: 25, 39].

5. **Task 5: Delivery Agent Performance**
   * Ranked delivery agents per route by on-time delivery percentage[cite: 27].
   * Used subqueries to compare the average experience and ratings of top vs. bottom performing agents[cite: 29].

6. **Task 6: Shipment Tracking Analytics & KPI Reporting**
   * Analyzed shipment statuses (**Delivered** ~89.5%, **In Transit** ~8.7%, **Returned** ~1.8%)[cite: 31].
   * Investigated root causes of extreme delays (>120 hours), identifying **Traffic (50%)**, **Weather (26.92%)**, and **Technical Issues (23.08%)** as primary bottlenecks[cite: 34].
   * Computed advanced KPIs such as global on-time delivery percentage (~6.8%) and source-country delay breakdowns[cite: 36, 37].

---

## 🛠️ Tech Stack & Languages

* **Language:** SQL (MySQL)
* **Data Visualization:** Power BI / Reporting Dashboards
* **Concepts Applied:** Joins, Aggregations, CTEs, Window Functions (`DENSE_RANK`, `OVER`), Conditional Logic (`CASE WHEN`), Date Functions.

---

## 📁 Video link
Video link - https://drive.google.com/file/d/1uEgtZau7poekuUXu7oIWeKBf7nNisWlF/view?usp=sharing
<img width="1853" height="88" alt="image" src="https://github.com/user-attachments/assets/c9223bf4-b665-48b9-909e-1d0a24b475ef" />
