# E-Bike Rental Operations and User Behavior Analytics
End-to-end e-bike rental analysis using PostgreSQL and Power BI. Includes SQL-based data modeling, data cleaning, and analytical view creation to build interactive dashboards analyzing user behavior, ride patterns, and station operations for actionable business and fleet optimization insights.

🚲 E-Bike Rental Operational Data Analytics

📌 Project Overview An end-to-end data analysis project on an e-bike rental system, covering the full pipeline from database design in PostgreSQL to interactive dashboards in Power BI. The project uncovers insights around user behaviour, station operations, and ride patterns to support smarter business and logistics decisions.

🛠️ Tools & Technologies

PostgreSQL — Database design, data cleaning, and analytical views Power BI — Interactive 3-page dashboard

🔍 SQL Analysis Highlights All analytical outputs were built as PostgreSQL views for clean integration with Power BI

📊 Power BI Dashboard The report contains 3 pages: Page 1 — Executive Dashboard

KPI cards for Total Users (1,000), Total Rides (15K), Total Stations (25), Average Duration (29.24 min), Average Distance (5.85 km), and Maximum Distance (19.37 km). A line chart tracks monthly new user growth across 2024.

Page 2 — User Behaviour & Ride Patterns

Peak Hour Activity — Line chart showing two clear peaks: morning (~7–8 AM) and afternoon (~4–5 PM), consistent with commuter usage Ride Categories — Donut chart: Long >30m (46.97%), Medium 11–30m (45.5%), Short <10m (7.53%) Membership-wise Ride Behaviour — Casual users dominate (10,676 rides) vs. Subscribers (4,324 rides), suggesting strong tourist/casual usage Outlier Ride Behaviour — 106 short-duration trips flagged for data quality review

Page 3 — Station & Operational Insights

Popular Stations — Jennifer Land St leads in total departures E-Bike Imbalance Across Stations — Net flow bar chart highlights stations losing bikes over time (negative net flow = residential/commute origins requiring rebalancing)

💡 Key Business Insights

Dual commuter peaks at 7–8 AM and 4–5 PM suggest the service is primarily used for work commutes. Casual users outnumber subscribers 2.5:1, pointing to significant tourist or occasional rider demand; targeted subscription promotions could convert this base. Negative net flow stations (e.g., Jennifer Land St) consistently lose bikes throughout the day; hence, these need priority rebalancing via logistics trucks. Positive net-flow stations accumulate surplus bikes and may require additional parking infrastructure. 106 suspicious rides (< 2 min or 0 km) represent ~0.7% of total rides. These could indicate likely false starts or app glitches worth filtering in operational reports. Nearly half of rides are > 30 minutes, suggesting the fleet is being used for genuine transportation, not just short hops.
