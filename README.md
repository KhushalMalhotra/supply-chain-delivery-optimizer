# 🚚 Supply Chain & Logistics Delivery Optimizer

A Power BI and SQL portfolio project analyzing delivery delays, carrier bottlenecks, and revenue at risk across global supply chain data.

---

## What This Project Does

When over half of a company's shipments arrive late, it isn't just an operational annoyance—it puts millions of dollars at risk. 

I built this dashboard to figure out **why** shipments were getting delayed, **which shipping methods** were causing the biggest issues, and **how much money** was on the line.

---
### Key Executive Insights (From Dashboard)
* **Total Revenue:** $3.68 Billion across 181,000+ analyzed orders.
* **Late Delivery Rate %:** 55% overall delay rate (`0.55`).
* **Revenue at Risk:** $2.01 Billion directly tied to delayed shipments.
* **Primary Bottleneck:** First Class shipping is the leading failure point with a **95% late rate (`0.95`)**, followed by Second Class at **77% (`0.77`)**.
* **High-Risk Products:** Products like *SOLE E25 Elliptical* (70% late rate) and *Ogio Race Golf Shoes* (69% late rate) suffer from severe fulfillment bottlenecks.
* **Top Market Risk:** Europe ($0.60bn) and LATAM ($0.56bn) represent the highest revenue exposure due to delivery delays.
---

## How I Built It (Data Pipeline)

```text
┌──────────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
│   PostgreSQL Database    │ ───► │  Power BI Data Model     │ ───► │   Interactive Dashboard  │
│  (Data Prep & SQL View)  │      │ (Explicit DAX Measures)  │      │  (Executive & Details)   │
└──────────────────────────┘      └──────────────────────────┘      └──────────────────────────┘
```

1. **SQL View (`v_delivery_analysis`):** Cleaned and prepared the raw supply chain data in PostgreSQL. I wrote a `CASE` statement comparing actual delivery days against scheduled delivery days to create a binary `is_late` flag (`1` for late, `0` for on-time).
2. **Data Modeling & DAX:** Created a dedicated `_Measures` table in Power BI to keep calculations organized. Wrote explicit DAX measures using `CALCULATE` for filter overrides and `DIVIDE` to safely handle division by zero.
3. **Dashboard Design:** Structured the report in a way anyone opening it can go from high-level numbers down to individual order details in a few clicks.

---

## Key DAX Measures

All measures are isolated within a dedicated `_Measures` table:

<details>
<summary><b>Click to expand DAX measures</b></summary>

```dax
// 1. Total Sales Revenue
Total Revenue = 
SUM(v_delivery_analysis[total_sales])

// 2. Total Order Count
Total Orders = 
COUNTROWS(v_delivery_analysis)

// 3. Total Late Deliveries
Late Deliveries = 
CALCULATE(
    COUNTROWS(v_delivery_analysis),
    v_delivery_analysis[is_late] = 1
)

// 4. Percentage of Late Shipments
Late Delivery Rate % = 
DIVIDE(
    [Late Deliveries],
    [Total Orders],
    0
)

// 5. Total Sales Exposure from Late Orders
Revenue at Risk = 
CALCULATE(
    [Total Revenue],
    v_delivery_analysis[is_late] = 1
)
```

</details>

---

## SQL Data Transformation (`v_delivery_analysis.sql`)

<details>
<summary><b>Click to expand PostgreSQL view script</b></summary>

```sql
CREATE VIEW v_delivery_analysis AS
SELECT 
    order_id,
    order_item_id,
    order_date,
    shipping_date,
    shipping_mode,
    market,
    order_region,
    category_name,
    product_name,
    sales AS total_sales,
    order_item_quantity,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    CASE 
        WHEN days_for_shipping_real > days_for_shipment_scheduled THEN 1
        ELSE 0
    END AS is_late
FROM raw_supply_chain_data;
```

</details>

---

## Dashboard Layout & Design Standards

I designed the dashboard using a side-by-side executive layout to maximize horizontal analytical depth:

* **Top Tier (Executive KPI Banner):** Displays high-level summaries (*Total Revenue*, *Total Orders*, *Late Delivery Rate %*, *Revenue at Risk*) formatted with clean 8px rounded container cards.
* **Lower Tier (Side-by-Side Analytical Layout - Left to Right):**
  * **Left Column (Root Cause Metrics):** Stacked visual cards analyzing risk by shipping mode (*Late Delivery Rate % by Shipping Mode* with dynamic conditional red formatting) and regional exposure (*Revenue at Risk by Market*).
  * **Middle Column (Product Category Exposure):** A visual breakdown showing *Revenue at Risk by Product / Order Category* to pinpoint high-value inventory bottlenecks.
  * **Right Column (Granular Order Grid):** A vertical detail table containing `order_id`, `market`, `shipping_mode`, and sales values so supply chain teams can inspect specific delayed shipments in real time.

---

## Repository Structure

```text
├── power_bi     
│   └── Supply_Chain_Delivery_Optimizer.pbix  #Power BI report file
├── sql/
│   └── v_delivery_analysis.sql               # PostgreSQL view creation script
├── docs/
│   └── dashboard_preview.png                 # Screenshot of the completed dashboard
└── README.md                                 # Project documentation
```

---

## How to Run This Project Locally

1. Load your raw supply chain dataset into your local PostgreSQL database.
2. Run `sql/v_delivery_analysis.sql` to generate the required analytical view.
3. Open `Supply_Chain_Delivery_Optimizer.pbix` in Power BI Desktop.
4. Update your database connection under **Transform Data → Data source settings**.
5. Click **Refresh** to load the data model.
