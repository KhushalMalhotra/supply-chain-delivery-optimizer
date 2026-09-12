--Late Delivery Rates by Market and Geographic Region
SELECT 
    market,
    order_region,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS late_delivery_rate_pct
FROM raw_supply_chain
GROUP BY market, order_region
HAVING COUNT(*) > 1000
ORDER BY late_delivery_rate_pct DESC;

-- Financial Impact and Revenue Exposure by Delivery Status
SELECT 
    delivery_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2) AS total_sales_usd,
    ROUND(
        SUM(sales)::NUMERIC * 100.0 / SUM(SUM(sales)::NUMERIC) OVER (), 
        2
    ) AS pct_of_total_sales,
    ROUND(AVG(order_profit_per_order)::NUMERIC, 2) AS avg_profit_per_order
FROM raw_supply_chain
GROUP BY delivery_status
ORDER BY total_sales_usd DESC;