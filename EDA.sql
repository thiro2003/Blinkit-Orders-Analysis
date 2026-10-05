-- USING THE DATABASE
USE  blinkit_db;

-- DATA CLEANING

-- CUSTOMERS

select * from customers where user_id='U0060550';

-- CREATING uset_tier_cronology Column 

ALTER TABLE blinkit_orders
ADD COLUMN user_tier_cronology varchar(20);

-- UPDATING COLUMN uset_tier_cronology
UPDATE blinkit_orders o
JOIN (
    SELECT order_id, DENSE_RANK() OVER (PARTITION BY user_id ORDER BY order_date ASC) as new_rank
    FROM blinkit_orders
    WHERE user_tier_cronology IS NULL 
    LIMIT 50000 
) ranked_data ON o.order_id = ranked_data.order_id
SET o.user_tier_cronology = ranked_data.new_rank;

-- CHECKING NULL VALUES
select * from customers limit 1;
select * from customers  where user_id is null;
select * from customers  where user_tier is null;
select * from customers  where customer_pincode is null;
select * from customers  where user_tier_cronology is null;

-- CHECKING DUPLICATE VALUES
select 
      user_id,
      customer_pincode,
      user_tier,
      count(*)
From customers
group by user_id,customer_pincode,user_tier;


-- first order placed 
select 
      min(order_timestamp)
From blinkit_orders;      -- 2022-01-01 00:16:10

-- last order placed 
select 
      max(order_timestamp)
From blinkit_orders;      -- 2026-05-31 23:59:14

 
 -- first order month
select 
      min(order_month)
From blinkit_orders;      -- 1

 -- last order month
select 
      max(order_month)
From blinkit_orders;      -- 12

 -- min order hour
select 
      min(order_hour)
From blinkit_orders;      -- 0


 -- max order hour
select 
      max(order_hour)
From blinkit_orders;      -- 23

-- delivery slot:-estimated timeframe within which you can expect your order to be delivered or the work schedule available to delivery partners.


select 
      distinct delivery_slot
From blinkit_orders;   

-- 10-min Express
-- 15 min
-- 20 min
-- 30 min
-- 45 min
-- 8-min Turbo
-- Scheduled AM
-- Scheduled PM   

-- platform distribution 
select 
      platform,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by platform
order by total_orders desc;  

-- Android	2031341	  2056756877.06
-- iOS	    1531820	  1574279361.07
-- Web	    296421	   293010140.20

 

-- payment_method distribution 
select 
      payment_method,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by payment_method
order by total_orders desc; 

-- UPI	                1923705	1981117245.46
-- Credit Card	        626670	632205431.18
-- Debit Card	        455205	453389528.24
-- Wallet	            273981	277452465.89
-- Cash on Delivery  	262327	256578457.30
-- Net Banking	        138240	136356700.60
-- EMI	                111446	115158313.94
-- Buy Now Pay Later	68008	71788235.72  

-- order_status distribution 
select 
      order_status,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by order_status
order by total_orders desc; 





-- cancellation_return_reaason distribution 
select 
      cancellation_return_reason,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by cancellation_return_reaason
order by total_orders desc;

-- Delivered	        3680987	3751366291.18
-- Cancelled	        72028	68929253.22
-- Partially Delivered	53582	52080754.96
-- Returned	            52985	51670078.97

-- num of item distribution
select 
      num_items_ordered,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by num_items_ordered
order by total_orders desc;

-- 3	806284	607185615.40
-- 4	777762	791685407.49
-- 2	676230	340117516.53
-- 5	471627	606961191.10
-- 1	336311	87784401.83
-- 6	335842	520111861.05
-- 7	187535	338332706.81
-- 8	114800	236888410.84
-- 9	76293	178513091.36
-- 10	38312	100257535.37
-- 12	19365	61150729.72
-- 11	19221	55057910.83

-- total_qty distribution
select 
      total_qty,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by total_qty
order by total_orders desc
limit 5;

-- 5	408912	288812468.72
-- 4	398893	225265576.05
-- 6	388221	330777117.48
-- 3	358719	151938257.99
-- 7	349369	350201217.75


-- delivery_time_mins distribution
select 
      delivery_time_mins,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by delivery_time_mins
order by total_orders desc
limit 5;

-- 9	    365323	384797550.84
-- 10	    356764	370503526.82
-- 8	    291147	307971940.21
-- 11	    264135	271093321.42
-- null  	178595	172680087.15

-- rating range
select 
      min(order_rating) min_rating,
      max(order_rating) max_rating,
      avg(order_rating) as avg_rating
from blinkit_orders;      

-- 1	5	4.2595

-- first order and reorder customers

select 
      is_first_order,
	 count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by is_first_order
order by total_orders desc;

-- 0	3774950	3840273437.95
-- 1	84632	83772940.38


-- is Express elligible
select 
      is_express_eligible,
      count(order_id) as total_orders,
     sum(grand_total) as total_GMV
from blinkit_orders
group by is_express_eligible
order by is_express_eligible desc ;  

-- 1	2255418	2380020688.57
-- 0	1604164	1544025689.76    


-- what is product discount range

select 
      min(product_discount) as min_product_discount,
      max(product_discount) as max_product_discount
From blinkit_orders;

-- 1.00	, 1842.00

-- promo code applied orders  and GMV 
select 
      promo_code,
	  count(order_id) as total_orders,
      sum(grand_total) as total_GMV
from blinkit_orders
group by promo_code
order by total_orders desc;
      

-- NULL 	1610365	1745140504.00
-- UPIOFF	272166	281628823.36
-- SAVE20	250101	229552906.60
-- BLINK10	225787	219272151.10
-- FLAT30	210751	203888274.28
-- FESTIVE25	206290	185690210.25
-- WEEKEND15	189053	182688906.95
-- NEWUSER	130366	117916645.40
-- DIWALI30	102858	91207901.50
-- SUMMER15	85068	85131388.70
-- HOLI20	82584	76172379.60
-- BLINK500	82546	88902138.00
-- REPUBLIC26	68566	72452431.22
-- MONSOON10	63933	66475585.60
-- BLINKIT25	55994	56823771.75
-- BLINK200	54015	43343148.58
-- IPLAUNCH	40560	46927122.20
-- HOLI26	33867	38205628.18
-- SUMMER26	33652	40498645.25
-- FIRST50	22466	15499426.00
-- VALENTINE26	20432	24335139.95
-- BLINK100	18162	12293249.86

 -- promo  discount range
 
 select 
      min(promo_discount) as min_product_discount,
      max(promo_discount) as max_product_discount
From blinkit_orders;

-- 0.00	,400.00

 -- delivery pricee range
 
 select 
      min(delivery_fee) as min_product_discount,
      max(delivery_fee) as max_product_discount
From blinkit_orders;

-- 0.00	,29.00

 -- tip range
 
 select 
      min(tip) as min_tip,
      max(tip) as min_tip
From blinkit_orders;

-- 0.00	100.00

-- cash back earned

 select 
      min(cashback_earned) as min_cashback_earnedtip,
      max(cashback_earned) as min_cashback_earned
From blinkit_orders;

-- 0.00	1098.56

-- grand total

 select 
      min(grand_total) as min_grand_total,
      max(grand_total) as min_grand_total
From blinkit_orders;

-- 29.00	17600.00











       



      


-- ROWS IN TABLE
SELECT count(*) AS Total_rows FROM blinkit_orders; -- 3859582

-- COLUMNS IN TABLE
SELECT  count(*) AS column_count
FROM information_schema.COLUMNS
WHERE  table_name = 'blinkit_orders' 
  AND table_schema = 'blinkit_db'; -- 37
  
-- Table description
DESC blinkit_orders;

-- Total unique customers
select count(distinct user_id) from blinkit_orders; -- 3859582

-- Total unique customers
select count(order_id) as Total_orders from blinkit_orders; -- 743772

-- total tiers wise order
select 
      user_tier,
      count(order_id) as total_orders
From blinkit_orders
group by  user_tier;    

-- Bronze	1576333
-- Gold	785990
-- Platinum	421889
-- Silver	1075370 

-- getting descrition table

WITH yearly_summary AS (
    SELECT 
        order_year,
        SUM(grand_total) AS GMV,
        COUNT(DISTINCT order_id) AS order_volume,
        SUM(grand_total) / COUNT(*) AS AOV,
        (SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(order_id) AS Cancellation_rate
    FROM blinkit_orders
    GROUP BY order_year
)
SELECT 
    order_year,
    -- Actual Values
    GMV,
    order_volume,
    AOV,
    Cancellation_rate,
    
    -- Percentage Changes vs Previous Year
    ROUND(((GMV - LAG(GMV, 1) OVER (ORDER BY order_year)) / LAG(GMV, 1) OVER (ORDER BY order_year)) * 100.0, 2) AS GMV_pct_change,
    
    ROUND(((order_volume - LAG(order_volume, 1) OVER (ORDER BY order_year)) / LAG(order_volume, 1) OVER (ORDER BY order_year)) * 100.0, 2) AS order_volume_pct_change,
    
    ROUND(((AOV - LAG(AOV, 1) OVER (ORDER BY order_year)) / LAG(AOV, 1) OVER (ORDER BY order_year)) * 100.0, 2) AS AOV_pct_change

FROM yearly_summary
ORDER BY order_year;

select * from blinkit_orders;

SELECT 
    distinct MONTHNAME(STR_TO_DATE(CONCAT('2026-', order_month, '-01'), '%Y-%m-%d')) AS month_name
FROM blinkit_orders 
WHERE order_year = 2026 ; 


-- getting delivery in minutes vs calcelation rate

select * from blinkit_orders limit 1;
SELECT 
    CASE 
        WHEN order_hour = 8 THEN '8 AM'
        WHEN order_hour = 12 THEN '12 PM'
        WHEN order_hour = 18 THEN '6 PM'
        WHEN order_hour = 21 THEN '9 PM'
        ELSE 'Other Hours'
    END AS time_slot,
    delivery_time_mins,
    (SUM(CASE WHEN order_status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0) / COUNT(order_id) AS Cancellation_rate
FROM blinkit_orders
WHERE order_hour IN (8, 12, 18, 21)
GROUP BY 
    CASE 
        WHEN order_hour = 8 THEN '8 AM'
        WHEN order_hour = 12 THEN '12 PM'
        WHEN order_hour = 18 THEN '6 PM'
        WHEN order_hour = 21 THEN '9 PM'
        ELSE 'Other Hours'
    END,
    delivery_time_mins
ORDER BY 
    time_slot, 
    delivery_time_mins;


-- total GMV by Cancellation Reason

select * from blinkit_orders limit 1;

select 
      cancellation_return_reason,
      sum(grand_total) as Total_GMV
From  blinkit_orders 
where cancellation_return_reason is not null and cancellation_return_reason!=""
group by  cancellation_return_reason;    


-- getting total GMV loass by calcelation

select 
      sum(grand_total) as Total_GMV_loss_due_to_Cancellation
From blinkit_orders
where cancellation_return_reason is not null and cancellation_return_reason!="";      


-- GMV, discounts and cashback by customer tier


select * from blinkit_orders limit 1;

select 
      user_tier,
      sum(grand_total) as total_GMV,
      sum(promo_discount) as total_discount,
      sum(cashback_earned) as total_cash_back_earned,
      count(*) as Total_orders,
      SUM(grand_total) / COUNT(*) AS AOV
from blinkit_orders
group by user_tier;      


-- express vs non express

select 
      (case when is_express_eligible=1 then "Express_order" else "Non-Express_order" end)as order_type,
      sum(grand_total)/count(*) as AOV,
      (sum(case when is_reorder then 1 else 0 end)*100.0)/count(*) as reorder_rate,
      avg(delivery_time_mins) as avg_delivery_in_min
from blinkit_orders
group by order_type;      
      
      