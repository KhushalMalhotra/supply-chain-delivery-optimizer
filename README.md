# 🚚 Supply Chain Delivery Analytics & Prescriptive Risk Optimizer

An end-to-end data analytics and machine learning project built to detect historical fulfillment bottlenecks, evaluate carrier delays, and predict high-risk shipments before they impact customers.

---

## What This Project Does

When over half of a business's orders show up late, it quickly turns into a multi-million dollar problem. 

I built this project across two distinct phases to answer four core questions:
1. **Where are our current delays coming from?** (Historical SQL & Power BI Analysis)
2. **Which carriers and products present the highest financial risk?** (Root Cause Insights)
3. **Can we predict which future shipments will be late?** (Machine Learning via Scikit-Learn)
4. **How can operations teams proactively prevent delays?** (Prescriptive Power BI Risk Dashboard)

---

## Key Business Insights

* **Total Revenue Analyzed:** $3.68 Billion across 181,000+ fulfillment records.
* **Late Delivery Rate:** 55% overall delay rate across the delivery network.
* **Revenue at Risk:** $2.01 Billion directly tied to late and SLA-non-compliant orders.
* **Carrier Bottlenecks:** First Class shipping failed most often with a **95% late rate**, followed by Second Class at **77%**.
* **High-Exposure Markets:** Europe ($600M) and LATAM ($560M) represent the largest revenue exposure to fulfillment delays.

---

## Chronological Project Workflow

```text
┌──────────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
│  1. PostgreSQL Database  │ ───► │  2. Power BI Dashboard 1 │ ───► │ 3. Python Jupyter Notebook│ ───► │  4. Power BI Dashboard 2 │
│ (Data Cleaning & View)   │      │ (Historical Analysis)    │      │ (Machine Learning Pipeline)│      │ (ML Risk Optimizer)      │
└──────────────────────────┘      └──────────────────────────┘      └──────────────────────────┘      └──────────────────────────┘
```

### Step 1: SQL Data Transformation (`v_delivery_analysis.sql`)
Cleaned raw logistics data in PostgreSQL and calculated scheduled vs. actual shipping days using a `CASE` statement to generate a binary `is_late` target flag (`1` for late, `0` for on-time).

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

### Step 2: Dashboard 1 — Historical Delivery Analysis
Built an executive diagnostic report to analyze historical delay patterns, regional risk, and carrier performance:
* **Top Executive Banner:** Displays key KPIs (*Total Revenue*, *Total Orders*, *Late Delivery Rate %*, and *Revenue at Risk*).
* **Side-by-Side Root Cause Layout:**
  * **Left Column:** Stacked visual cards analyzing delay rates by shipping mode (with dynamic red conditional formatting for modes exceeding 50% late rates) and revenue exposure by market.
  * **Middle Column:** Visual breakdown of revenue at risk across product and order categories.
  * **Right Column:** Granular order detail table for real-time investigation of specific late shipments.

---

### Step 3: Machine Learning & Predictive Modeling (Python / Jupyter)
Transitioned from diagnostic to predictive analytics by building classification models directly inside a Jupyter Notebook:
* **Feature Engineering & Preprocessing:** Encoded categorical features and scaled numerical metrics using Scikit-Learn pipelines.
* **Sequential Hyperparameter Tuning:** Used 5-Fold Stratified Cross-Validation to tune tree counts (`n_estimators` up to 400) and tree depth (`max_depth`) and other features sequentially to control overfitting and balance variance.
* **Architectures Evaluated:** Compared LightGBM Classifier performance against a Multi-Layer Perceptron (MLP) Neural Network (`hidden_layer_sizes=(128, 64, 32)`) and the baseline, Random Forest Classifier, with LightGBM giving the best overall results.
* **Model Output:** Generated predicted late probabilities (`y_proba`) and late predictions (`y_pred`) for all test orders and exported them back into the data pipeline as 'csv' files.

---

### Step 4: Dashboard 2 — ML Prescriptive Risk Optimizer
Created a forward-looking operational dashboard designed to help logistics managers act before delays happen:
* **Dynamic Probability Threshold Slicer:** A top-level slider allowing operations teams to adjust risk sensitivity (e.g., filter down to shipments with `>70%` predicted delay risk).
* **Real-time KPI Alerts:** Displays live counts of high-risk shipments and predicted late delivery percentages based on user threshold selection.
* **Operational Risk Visuals:** Breaks down predicted risk across shipping modes and geographic regions.
* **Risk Tier Breakdown Matrix:** Segmented orders and total revenue into 4 actionable risk buckets (*Critical Risk (>70%)*, *High Risk (50-70%)*, *Medium Risk (30-50%)*, and *Low Risk (<30%)*).

---

## Key DAX Measures

All business logic and KPI calculations are stored in a dedicated `_Measures` table in Power BI:

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

## Repository Structure

```text
├── python/
│   └── supply_chain_ml_analysis.ipynb      # ML preprocessing, model training & tuning notebook
├── power_bi/
│   ├── supply_chain_delivery_optimizer.pbix   # Dashboard 1: Diagnostic Report
│   └── delivery_risk_ml.pbix      # Dashboard 2: ML Risk Optimizer
├── sql/
│   ├── 01_table_creation.sql     # PostgreSQL view creation scripts
│   └── 02_data_exploration.sql 
│   └── 03_data_exploration2.sql 
│   └── 04_feature_engineering_and_creating_view.sql 
├── docs/
│   ├── dashboard_preview.png     # Screenshot of Dashboard 1
│   └── ml_risk_optimizer_preview.png        # Screenshot of Dashboard 2
└── README.md                                 # Project documentation
```

---

## How to Run This Project Locally

1. **Database Setup:** Load your raw logistics dataset into PostgreSQL and execute the files.
2. **Historical Analysis:** Open `power_bi/supply_chain_delivery_optimizer.pbix` to explore the diagnostic dashboard.
3. **Machine Learning Pipeline:** Run `python/supply_chain_ml_analysis.ipynb` sequentially to train models and generate predictions and prediction probabilities.
4. **Prescriptive Optimizer:** Open `power_bi/delivery_risk_ml.pbix`, refresh the data connection, and test dynamic risk thresholds.


### 📊 Data Source
* **Dataset:** [DataCo Smart Supply Chain for Big Data (`DataCoSupplyChainDataset.csv`)](https://www.kaggle.com/) (Hosted on Kaggle)
* **Scope:** 180,000+ registered transactional records covering supply chain operations, order fulfillment times, sales metrics, and shipping logistics.