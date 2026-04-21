/* III. Making dynamic reports*/
/* Part 1 - Montly Revenue Report*/

-- Auto partition prune and using index (product_id) when filter
CREATE OR REPLACE FUNCTION monthly_revenue_report(
    start_date DATE,
    end_date DATE
)
RETURNS TABLE (
    month DATE,
    total_orders BIGINT,
    total_quantity BIGINT,
    total_revenue NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS total_quantity,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders_ranges o
    JOIN order_item_ranges oi ON o.order_id = oi.order_id
    WHERE o.order_date BETWEEN start_date AND end_date
    GROUP BY DATE_TRUNC('month', o.order_date)
    ORDER BY month;
END;
$$;

SELECT * 
FROM monthly_revenue_report('2025-08-01', '2025-10-31');

