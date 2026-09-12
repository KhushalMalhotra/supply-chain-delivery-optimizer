-- Feature engineering and creating a database view

CREATE OR REPLACE VIEW v_delivery_analysis AS
SELECT
    -- Identifiers
    order_id,
    order_item_id,
    customer_id,
    
    -- Temporal Attributes
    order_date,
    shipping_date,
    
    -- Logistics & Shipping Metrics
    shipping_mode,
    days_for_shipment_scheduled AS scheduled_days,
    days_for_shipping_real AS actual_days,
    (days_for_shipping_real - days_for_shipment_scheduled) AS delay_days,
    
    -- Target & Risk Flags
    delivery_status,
    late_delivery_risk, -- Binary target (1 = Late, 0 = On time / Early)
    CASE 
        WHEN delivery_status = 'Late delivery' THEN 1 
        ELSE 0 
    END AS is_late,
    CASE 
        WHEN days_for_shipping_real <= days_for_shipment_scheduled THEN 1 
        ELSE 0 
    END AS sla_met_flag,
    -- sla is service level agreement
    -- Geographical Granularity
    market,
    order_region,
    order_country,
    order_city,
    
    -- Product & Financial Metrics
    category_name,
    product_name,
    order_item_quantity AS quantity,
    product_price,
    sales AS total_sales,
    order_profit_per_order AS profit,
    
    -- Strategic Risk Categorization
    CASE 
        WHEN shipping_mode IN ('First Class', 'Second Class') THEN 'High SLA Risk'
        WHEN shipping_mode = 'Same Day' THEN 'Medium SLA Risk'
        ELSE 'Low SLA Risk'
    END AS shipping_risk_tier

FROM raw_supply_chain;

-- Verify view creation and inspect top rows
SELECT * FROM v_delivery_analysis LIMIT 10;