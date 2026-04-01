-- ================================================
-- Discount Impact & Margin Leakage Analysis
-- Dunnhumby - The Complete Journey Dataset
-- Author: Kamil Khan Pathan
-- ================================================


-- ================================================
-- STEP 1: CREATE TABLES
-- ================================================

CREATE TABLE transactions (
    household_key INTEGER,
    basket_id BIGINT,
    day INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    sales_value NUMERIC(10,2),
    store_id INTEGER,
    retail_disc NUMERIC(10,2),
    trans_time INTEGER,
    week_no INTEGER,
    coupon_disc NUMERIC(10,2),
    coupon_match_disc NUMERIC(10,2)
);

CREATE TABLE products (
    product_id INTEGER,
    manufacturer INTEGER,
    department VARCHAR(50),
    brand VARCHAR(50),
    commodity_desc VARCHAR(100),
    sub_commodity_desc VARCHAR(100),
    curr_size_of_product VARCHAR(30)
);

CREATE TABLE coupon (
    coupon_upc BIGINT,
    product_id INTEGER,
    campaign INTEGER
);

CREATE TABLE coupon_redempt (
    household_key INTEGER,
    day INTEGER,
    coupon_upc BIGINT,
    campaign INTEGER
);

CREATE TABLE causal_data (
    product_id INTEGER,
    store_id INTEGER,
    week_no INTEGER,
    display VARCHAR(10),
    mailer VARCHAR(10)
);


-- ================================================
-- STEP 2: LOAD DATA
-- Update file paths to match your local directory
-- ================================================

COPY transactions FROM 'D:\Projects\Pricing Analysis\archive\transaction_data.csv' DELIMITER ',' CSV HEADER;
COPY products FROM 'D:\Projects\Pricing Analysis\archive\product.csv' DELIMITER ',' CSV HEADER;
COPY coupon FROM 'D:\Projects\Pricing Analysis\archive\coupon.csv' DELIMITER ',' CSV HEADER;
COPY coupon_redempt FROM 'D:\Projects\Pricing Analysis\archive\coupon_redempt.csv' DELIMITER ',' CSV HEADER;
COPY causal_data FROM 'D:\Projects\Pricing Analysis\archive\causal_data.csv' DELIMITER ',' CSV HEADER;


-- ================================================
-- STEP 3: VERIFY DATA LOAD
-- ================================================

SELECT 'transactions' AS table_name, COUNT(*) FROM transactions
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'coupon', COUNT(*) FROM coupon
UNION ALL
SELECT 'coupon_redempt', COUNT(*) FROM coupon_redempt
UNION ALL
SELECT 'causal_data', COUNT(*) FROM causal_data;

-- Expected output:
-- transactions  2,595,732
-- products      92,353
-- coupon        124,548
-- coupon_redempt 2,318
-- causal_data   36,786,524


-- ================================================
-- QUERY 1: Discount Depth vs Sales Volume by Category
-- Goal: Identify how discount depth affects transaction 
-- volume and sales across FMCG departments
-- Finding: GROCERY showed highest volume at discount bands,
-- signaling strong discount dependency (83.78%)
-- ================================================

SELECT 
    p.department,
    CASE 
        WHEN t.retail_disc = 0 THEN '0% - No Discount'
        WHEN t.retail_disc < 1 THEN '1-10% Discount'
        WHEN t.retail_disc < 2 THEN '10-20% Discount'
        WHEN t.retail_disc < 3 THEN '20-30% Discount'
        ELSE '30%+ Discount'
    END AS discount_band,
    COUNT(DISTINCT t.basket_id) AS num_transactions,
    ROUND(SUM(t.sales_value)::numeric, 2) AS total_sales,
    ROUND(AVG(t.sales_value)::numeric, 2) AS avg_basket_value,
    ROUND(SUM(t.retail_disc)::numeric, 2) AS total_discount_given
FROM transactions t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.department, discount_band
ORDER BY p.department, discount_band;


-- ================================================
-- QUERY 2: Weekly Sales & Discount Trend
-- Goal: Identify post-promotion demand dips (cannibalization)
-- Note: Weeks 1-16 excluded from trend analysis due to 
-- household enrollment ramp-up (data collection artifact)
-- Finding: Week 92 spike (3,362 txns, $113K sales) followed
-- by 24% demand drop in Week 93 (2,547 txns, $80.8K sales)
-- confirms post-promotion demand cannibalization
-- ================================================

SELECT 
    week_no,
    COUNT(DISTINCT basket_id) AS num_transactions,
    ROUND(SUM(sales_value)::numeric, 2) AS total_sales,
    ROUND(SUM(ABS(retail_disc))::numeric, 2) AS total_discounts
FROM transactions
GROUP BY week_no
ORDER BY week_no;


-- ================================================
-- QUERY 3: Margin Leakage by Category
-- Goal: Quantify discount as % of revenue per department
-- to identify where margin is being unnecessarily eroded
-- Finding: MEAT at 32.20% and MEAT-PCKGD at 28.96% showed
-- highest margin leakage. DRUG GM at 9.93% suggests
-- discounts are largely unnecessary in personal care.
-- ================================================

SELECT 
    p.department,
    ROUND(SUM(t.sales_value)::numeric, 2) AS total_revenue,
    ROUND(SUM(ABS(t.retail_disc))::numeric, 2) AS total_discount,
    ROUND((SUM(ABS(t.retail_disc)) / NULLIF(SUM(t.sales_value), 0) * 100)::numeric, 2) AS discount_as_pct_of_revenue,
    COUNT(DISTINCT t.basket_id) AS total_transactions
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE p.department IN ('GROCERY', 'MEAT', 'MEAT-PCKGD', 'PRODUCE', 'DRUG GM', 'NUTRITION', 'PASTRY', 'DELI')
GROUP BY p.department
ORDER BY discount_as_pct_of_revenue DESC;


-- ================================================
-- QUERY 4: Discount Dependency Score by Category
-- Goal: Measure what % of transactions only occur
-- when a discount is applied (dependency score)
-- Finding: GROCERY at 83.78% is critically discount-dependent.
-- PASTRY at 37.89% is healthiest - impulse-driven, not price-driven.
-- Recommendation: Shift GROCERY to loyalty-based promotions,
-- protect DRUG GM margins by reducing blanket discounts.
-- ================================================

SELECT 
    p.department,
    COUNT(DISTINCT CASE WHEN t.retail_disc < 0 THEN t.basket_id END) AS discounted_transactions,
    COUNT(DISTINCT t.basket_id) AS total_transactions,
    ROUND((COUNT(DISTINCT CASE WHEN t.retail_disc < 0 THEN t.basket_id END)::numeric / 
    NULLIF(COUNT(DISTINCT t.basket_id), 0) * 100)::numeric, 2) AS discount_dependency_pct
FROM transactions t
JOIN products p ON t.product_id = p.product_id
WHERE p.department IN ('GROCERY', 'MEAT', 'MEAT-PCKGD', 'PRODUCE', 'DRUG GM', 'NUTRITION', 'PASTRY', 'DELI')
GROUP BY p.department
ORDER BY discount_dependency_pct DESC;
