select * from walmart_db;
select payment_method, count(*) as no_payments, sum(quantity) as no_of_qty_sold from walmart_db group by payment_method;
SELECT Branch, Category, avg_rating
FROM (
    SELECT 
        Branch,
        Category,
        AVG(rating) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rn
    FROM walmart_db
    GROUP BY Branch, Category
) AS t
WHERE rn = 1
ORDER BY Branch;

WITH branch_transactions AS (
  SELECT
    branch,
    DAYNAME(STR_TO_DATE(`date`, '%d/%m/%y')) AS day_name,
    COUNT(*) AS no_transactions
  FROM walmart_db
  GROUP BY branch, day_name
)
SELECT
  branch,
  day_name,
  no_transactions
FROM (
  SELECT
    branch,
    day_name,
    no_transactions,
    ROW_NUMBER() 
      OVER (PARTITION BY branch ORDER BY no_transactions DESC) AS rn
  FROM branch_transactions
) AS ranked
WHERE rn = 1
ORDER BY branch;





