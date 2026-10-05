# 🛒 Blinkit Order Analytics: 10 Business Questions Answered with SQL

> End-to-end SQL analysis of **~3.86 million quick-commerce orders** (Jan 2022 – May 2026) to answer ten business questions on growth, operations, customers and pricing.

![MySQL](https://img.shields.io/badge/MySQL-8%2B-blue)
![Domain](https://img.shields.io/badge/Domain-Quick%20Commerce-yellow)
![Rows](https://img.shields.io/badge/Rows-3.86M-green)

---

## 📌 Project Overview

Blinkit delivers groceries and daily essentials in minutes. Growing profitably in this market means making good decisions on **growth, operations, customers and pricing**.

This project takes the `blinkit_orders` table, which records every order's timing, location, customer tier, payment, pricing, delivery performance and final status. It answers **10 business problems** with MySQL. Each query is tied to a **decision** the business can act on.

## 🗂️ Repository Contents

| File | Description |
|------|-------------|
| `Insights.sql` | All 10 SQL queries (plus indexing) with the decision each one supports |
| `Problem_Statement_on_Blinkit_Orders.pdf` | The 10 business problem statements |
| `Blinkit_Order_Analytics.pptx` | Presentation of insights and recommendations |

📁 **Dataset:** [Download from Google Drive](https://drive.google.com/drive/folders/1nAAhdfyb5DqZUfupO-aweXxZayBFbijz)

## 🧰 Tech Stack & SQL Skills Used

- **MySQL 8+**
- CTEs, window functions (`LAG`, `RANK`, `ROW_NUMBER`, `SUM() OVER`)
- Conditional aggregation (`CASE WHEN`), bucketing and cohort analysis
- Indexing for performance on 3.8M+ rows

## 🗃️ Dataset Snapshot

| Attribute | Detail |
|-----------|--------|
| Table | `blinkit_db.blinkit_orders` |
| Rows | ~3.86 million orders |
| Period | January 2022 – May 2026 |
| Key columns | `order_status`, `grand_total`, `subtotal`, `delivery_time_mins`, `order_rating`, `store_city`, `store_zone`, `promo_code`, `promo_discount`, `user_tier`, `cashback_earned`, `payment_method`, `platform`, `delivery_fee`, `tip`, `is_first_order`, `is_reorder` |

---

## 🔍 Key Insights

### Q1. Is the business growing? 📈
- Monthly GMV grew **8.5x**, from **₹2.2 Cr (Jan-22)** to **₹18.7 Cr (Apr-26)**.
- Average order value rose **70%**, from **₹739 (2022)** to **₹1,256 (2026 YTD)**.
- 2026 YTD GMV growth is **+28% vs 2025**, down sharply from **+131% in 2025**. Growth is maturing, so targets should be set accordingly.

### Q2. How much revenue do failed orders cost? 💸
- **₹17.3 Cr** was lost on failed orders, equal to **4.6% of delivered GMV**.
- **30%** of the loss comes from **partial deliveries, which have no reason recorded**. This is a data-capture gap as well as an ops problem.
- **₹5.2 Cr** was lost to returns, and all of them are operational failures (wrong item, expired, damaged).

### Q3. Does delivery speed drive loyalty? ⚡
- **34%** of orders arrive within 10 minutes, the largest bucket.
- Reorder rate falls about **3 pts**, from **65.4% (≤10 min)** to **62.4% (30+ min)**.
- **14%** of orders take 30+ minutes, which puts roughly **16K repeat orders at risk**.

### Q4. When is demand highest? ⏰
- There are **two daily peaks**: **11 AM** and **6–7 PM**.
- **86%** of top-slot orders land on **Friday, Saturday or Sunday**.
- Delivery time stays flat at **~19 min** even in the busiest slots, so current rider and picker capacity is coping.

### Q5. Which cities are stars? 🏙️
- **Mumbai and Delhi** generate **36% of GMV**, and the **top 5 cities** give **66%**.
- Small cities such as **Mysuru** have order values of **₹1,200+**, vs ~₹980 in metro zones.
- Small cities also deliver faster, at about **15 min** vs **19.7 min** in metros, with **4.4 ratings**.

### Q6. Are promo codes worth it? 🏷️
- Total discounts were **₹34.7 Cr (9% of GMV)**, with **58% of orders** using a code.
- **24%** of discount spend sits in just two codes: **SAVE20** and **FESTIVE25**.
- **NEWUSER** brings a first-order share of only **2.3%**, the same as no-promo orders (**2.2%**). It is not acquiring new users effectively.

### Q7. Who are the most valuable customers? 👑
- **Platinum** revenue per customer is **₹1,727**, which is **34% lower than Bronze (₹2,633)**.
- **7.4%** of Platinum revenue is paid out as cashback, while Bronze gets none.
- Platinum order value is only **~5% higher** than Bronze, with fewer orders per customer. The tier program is not paying off.

### Q8. Do new customers come back? 🔁
- **85%** of new customers in 2025 do **not** place a second order within 30 days.
- The 30-day repeat rate improved from **10.7% (2024)** to **15.0% (2025)**, a gain of **4.3 pts**.
- The **Mar and Apr 2026 cohorts are the strongest yet, at 16.5%**.

### Q9. Which payments carry the most risk? 💳
- **52%** of orders are paid by **UPI**, at a low **1.81% cancel rate**.
- The spread between **Net Banking (2.06%)** and **BNPL (1.71%)** is only **0.35 pt**, so payment-method risk is low.
- **Web** cancels slightly more than **iOS** (**2.02% vs 1.81%**) and carries 8% of orders.

### Q10. Are small baskets losing money? 🧺
- On orders under **₹100**, the delivery fee equals **43.6%** of basket value.
- **12%** of orders are under ₹200, and they fail more often (**5.0–5.2% vs 4.4%**).
- **74%** of orders pass ₹400 and ship free. The **₹200–399 band** is the best target for "add ₹X for free delivery" nudges.

---

## 🚀 Business Recommendations

| # | Recommendation | Why |
|---|----------------|-----|
| 1 | **Fix returns at the source** | Audit packing and supplier quality, and log reasons for partial deliveries (₹5.2 Cr each) |
| 2 | **Redesign loyalty** | Tie Platinum cashback (7.4% of revenue) to order frequency, not tier alone |
| 3 | **Rebalance promos** | Trim SAVE20 and FESTIVE25, scale UPIOFF (7.8% cost), retarget NEWUSER |
| 4 | **Win the second order** | Send day 7–14 nudges, since 85% of new customers never return within 30 days |
| 5 | **Expand tier-2 cities** | Higher order value (₹1,200+), faster delivery (~15 min) and room to grow |
| 6 | **Nudge carts to ₹400** | Show "add ₹X for free delivery" on ₹200–399 carts (14% of orders) |

---

## ▶️ How to Run

1. Load the dataset into MySQL as `blinkit_db.blinkit_orders`.
2. Open `Insights.sql` and run **Q0** first. It checks the `order_status` values and creates indexes.
   > The queries assume statuses `'Delivered'`, `'Cancelled'` and `'Returned'`. Adjust the labels if yours differ.
3. Run Q1–Q10 one at a time.

```sql
-- Example: Q1 - Monthly GMV with MoM & YoY growth
WITH monthly AS (
    SELECT order_year, order_month,
           COUNT(*) AS orders,
           SUM(grand_total) AS gmv,
           ROUND(AVG(grand_total), 2) AS aov
    FROM blinkit_orders
    WHERE order_status = 'Delivered'
    GROUP BY order_year, order_month
)
SELECT *,
       ROUND(100 * (gmv - LAG(gmv)     OVER w) / LAG(gmv)     OVER w, 2) AS mom_growth_pct,
       ROUND(100 * (gmv - LAG(gmv, 12) OVER w) / LAG(gmv, 12) OVER w, 2) AS yoy_growth_pct
FROM monthly
WINDOW w AS (ORDER BY order_year, order_month);
```

## 📬 Connect With Me

**Rohit Sul**

- 💼 LinkedIn: [linkedin.com/in/rohit-sul-780265283](https://www.linkedin.com/in/rohit-sul-780265283/)
- 💻 GitHub: [github.com/your-username](https://github.com/your-username)

⭐ If you found this project useful, please give it a star!
