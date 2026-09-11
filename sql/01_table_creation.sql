-- EDA

-- Knowing what is the problem?
-- Query 1: Calculate the deliver status distribution

SELECT 
	delivery_status,
	COUNT(*) AS total_orders,
	ROUND(COUNT(*)* 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM raw_supply_chain
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- After knowing how much percentage of the total shipping is late, we want to know what is the distribution of late deliveries among the shipping modes

SELECT 
    shipping_mode,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) AS late_orders,
    ROUND(
        SUM(CASE WHEN delivery_status = 'Late delivery' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS late_delivery_rate_pct,
    ROUND(AVG(days_for_shipping_real), 2) AS avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled), 2) AS avg_scheduled_days
FROM raw_supply_chain
GROUP BY shipping_mode
ORDER BY late_delivery_rate_pct DESC;