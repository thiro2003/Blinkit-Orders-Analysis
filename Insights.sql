-- =====================================================================
-- BLINKIT ORDERS - 10 BUSINESS QUESTIONS THAT DRIVE DECISIONS (MySQL 8+)
-- Table: blinkit_db.blinkit_orders (~3.86M rows)
-- ASSUMPTION: order_status has values like 'Delivered', 'Cancelled',
-- 'Returned'. Run Q0 first and adjust the labels if yours differ.
-- =====================================================================
USE blinkit_db;

-- Q0: Check status values + add indexes (3.8M rows -> queries get MUCH faster)
SELECT order_status, COUNT(*) AS orders FROM blinkit_orders GROUP BY order_status;

CREATE INDEX idx_date   ON blinkit_orders (order_date);
CREATE INDEX idx_user   ON blinkit_orders (user_id, order_timestamp);
CREATE INDEX idx_city   ON blinkit_orders (store_city, store_zone);
CREATE INDEX idx_status ON blinkit_orders (order_status);




-- =====================================================================
-- Q1. Is the business growing? Monthly GMV, orders, AOV, MoM and YoY growth
-- DECISION: Find slowdown months, seasonality, and set growth targets.
-- =====================================================================
WITH monthly AS (
    SELECT order_year, order_month,
           COUNT(*)                     AS orders,
           SUM(grand_total)             AS gmv,
           ROUND(AVG(grand_total), 2)   AS aov
    FROM blinkit_orders
    WHERE order_status = 'Delivered'
    GROUP BY order_year, order_month
)
SELECT order_year, order_month, orders, gmv, aov,
       ROUND(100 * (gmv - LAG(gmv)     OVER w) / LAG(gmv)     OVER w, 2) AS mom_growth_pct,
       ROUND(100 * (gmv - LAG(gmv, 12) OVER w) / LAG(gmv, 12) OVER w, 2) AS yoy_growth_pct
FROM monthly
WINDOW w AS (ORDER BY order_year, order_month)
ORDER BY order_year, order_month;


-- =====================================================================
-- Q2. How much revenue do we lose to cancellations & returns, and why?
-- DECISION: Fix the top reasons (stock-outs, late delivery, wrong items).
-- =====================================================================
SELECT order_status,
       cancellation_return_reason,
       COUNT(*)                                                      AS orders,
       ROUND(SUM(grand_total), 0)                                    AS revenue_lost,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)              AS pct_of_all_orders
FROM blinkit_orders
WHERE order_status <> 'Delivered'
GROUP BY order_status, cancellation_return_reason
ORDER BY revenue_lost DESC;


-- =====================================================================
-- Q3. Does delivery speed drive ratings and cancellations?
-- DECISION: Find the delivery-time "tipping point" where satisfaction drops
-- and invest in dark-store capacity / rider supply to stay under it.
-- (AVG ignores NULL ratings; add AND order_rating > 0 if 0 means "unrated")
-- =====================================================================
SELECT CASE
           WHEN delivery_time_mins <= 10 THEN '1) <=10 min'
           WHEN delivery_time_mins <= 15 THEN '2) 11-15 min'
           WHEN delivery_time_mins <= 20 THEN '3) 16-20 min'
           WHEN delivery_time_mins <= 30 THEN '4) 21-30 min'
           ELSE '5) 30+ min'
       END                                     AS delivery_bucket,
       COUNT(*)                                AS orders,
       ROUND(AVG(order_rating), 2)             AS avg_rating,
       ROUND(100 * SUM(is_reorder) / COUNT(*), 2) AS reorder_pct
FROM blinkit_orders
WHERE delivery_time_mins IS NOT NULL
GROUP BY delivery_bucket
ORDER BY delivery_bucket;


-- =====================================================================
-- Q4. When is demand highest? Orders by day of week x hour
-- DECISION: Staff riders & pickers, schedule stock refills, time promos
-- (push offers in off-peak hours to flatten the curve).
-- =====================================================================
SELECT order_day_of_week,
       order_hour,
       COUNT(*)                   AS orders,
       ROUND(SUM(grand_total), 0) AS gmv,
       ROUND(AVG(delivery_time_mins), 1) AS avg_delivery_mins   -- shows peak stress
FROM blinkit_orders
WHERE order_status = 'Delivered'
GROUP BY order_day_of_week, order_hour
ORDER BY orders DESC
LIMIT 30;


-- =====================================================================
-- Q5. Which cities/zones are stars and which are underperformers?
-- DECISION: Where to expand dark stores, where to fix operations,
-- where to cut losses.
-- =====================================================================
SELECT store_city, store_zone,
       COUNT(*)                                                         AS total_orders,
       ROUND(SUM(CASE WHEN order_status = 'Delivered' THEN grand_total END), 0) AS gmv,
       ROUND(AVG(CASE WHEN order_status = 'Delivered' THEN grand_total END), 2) AS aov,
       ROUND(AVG(delivery_time_mins), 1)                                AS avg_delivery_mins,
       ROUND(100 * SUM(order_status <> 'Delivered') / COUNT(*), 2)      AS fail_rate_pct,
       ROUND(AVG(order_rating), 2)                                      AS avg_rating,
       RANK() OVER (ORDER BY SUM(CASE WHEN order_status = 'Delivered' THEN grand_total END) DESC) AS gmv_rank
FROM blinkit_orders
GROUP BY store_city, store_zone
ORDER BY gmv_rank;


-- =====================================================================
-- Q6. Are promo codes worth it? Promo vs non-promo orders + cost per code
-- DECISION: Kill codes that burn margin without lifting basket size,
-- scale the ones that raise AOV or bring first-time users.
-- =====================================================================
SELECT COALESCE(NULLIF(promo_code, ''), 'NO PROMO')                AS promo,
       COUNT(*)                                                    AS orders,
       ROUND(AVG(subtotal), 2)                                     AS avg_subtotal,
       ROUND(SUM(promo_discount), 0)                               AS total_discount_given,
       ROUND(100 * SUM(promo_discount) / NULLIF(SUM(subtotal), 0), 2) AS discount_pct_of_sales,
       ROUND(100 * SUM(is_first_order) / COUNT(*), 2)              AS first_order_share_pct,
       ROUND(100 * SUM(order_status <> 'Delivered') / COUNT(*), 2) AS fail_rate_pct
FROM blinkit_orders
GROUP BY promo
ORDER BY total_discount_given DESC;


-- =====================================================================
-- Q7. Who are the most valuable customers? User-tier economics
-- DECISION: Is the loyalty/tier program (and cashback) paying off?
-- Where to focus retention budget.
-- =====================================================================
SELECT user_tier,
       COUNT(DISTINCT user_id)                                AS customers,
       COUNT(*)                                               AS orders,
       ROUND(COUNT(*) / COUNT(DISTINCT user_id), 2)           AS orders_per_customer,
       ROUND(AVG(grand_total), 2)                             AS aov,
       ROUND(SUM(grand_total) / COUNT(DISTINCT user_id), 0)   AS revenue_per_customer,
       ROUND(100 * SUM(cashback_earned) / SUM(grand_total), 2) AS cashback_pct_of_revenue
FROM blinkit_orders
WHERE order_status = 'Delivered'
GROUP BY user_tier
ORDER BY revenue_per_customer DESC;


-- =====================================================================
-- Q8. Retention: what % of new customers place a 2nd order within 30 days?
-- DECISION: Biggest lever on lifetime value. Weak cohorts -> improve
-- first-order experience, trigger win-back offers on day 7-14.
-- =====================================================================
WITH ranked AS (
    SELECT user_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY order_timestamp) AS rn
    FROM blinkit_orders
    WHERE order_status = 'Delivered'
),
first_second AS (

    SELECT user_id,
           MIN(CASE WHEN rn = 1 THEN order_date END) AS first_dt,
           MIN(CASE WHEN rn = 2 THEN order_date END) AS second_dt
    FROM ranked
    WHERE rn <= 2
    GROUP BY user_id
)
SELECT DATE_FORMAT(first_dt, '%Y-%m')                                   AS cohort_month,
       COUNT(*)                                                         AS new_customers,
       SUM(second_dt IS NOT NULL AND DATEDIFF(second_dt, first_dt) <= 30) AS repeated_in_30d,
       ROUND(100 * SUM(second_dt IS NOT NULL AND DATEDIFF(second_dt, first_dt) <= 30) / COUNT(*), 2) AS retention_30d_pct
FROM first_second
GROUP BY cohort_month
ORDER BY cohort_month;


-- =====================================================================
-- Q9. Which payment methods & platforms are risky or most valuable?
-- DECISION: Push low-failure digital payments (UPI/wallet incentives),
-- reduce COD risk, prioritise the best-converting platform.
-- =====================================================================
SELECT platform, payment_method,
       COUNT(*)                                                    AS orders,
       ROUND(AVG(grand_total), 2)                                  AS aov,
       ROUND(100 * SUM(order_status = 'Cancelled') / COUNT(*), 2)  AS cancel_rate_pct,
       ROUND(100 * SUM(order_status = 'Returned')  / COUNT(*), 2)  AS return_rate_pct
FROM blinkit_orders
GROUP BY platform, payment_method
ORDER BY orders DESC;


-- =====================================================================
-- Q10. Are small baskets losing money? Basket size vs delivery fee & tip
-- DECISION: Set/adjust minimum order value, free-delivery threshold,
-- and small-cart fees; upsell nudges ("add Rs X for free delivery").
-- =====================================================================
SELECT CASE
           WHEN subtotal < 100  THEN '1) < 100'
           WHEN subtotal < 200  THEN '2) 100-199'
           WHEN subtotal < 400  THEN '3) 200-399'
           WHEN subtotal < 700  THEN '4) 400-699'
           ELSE '5) 700+'
       END                                                         AS basket_bucket,
       COUNT(*)                                                    AS orders,
       ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)            AS share_of_orders_pct,
       ROUND(AVG(num_items_ordered), 1)                            AS avg_items,
       ROUND(AVG(delivery_fee), 2)                                 AS avg_delivery_fee,
       ROUND(AVG(tip), 2)                                          AS avg_tip,
       ROUND(100 * SUM(delivery_fee) / SUM(subtotal), 2)           AS fee_pct_of_basket,
       ROUND(100 * SUM(order_status <> 'Delivered') / COUNT(*), 2) AS fail_rate_pct
FROM blinkit_orders
GROUP BY basket_bucket
ORDER BY basket_bucket;