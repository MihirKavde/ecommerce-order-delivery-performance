SELECT COUNT(*) AS total_rows 
FROM ecommerce_dataset_updated;

DESCRIBE ecommerce_dataset_updated;

SELECT *
FROM ecommerce_dataset_updated LIMIT 10;


# Check Nulls

SELECT
    COUNT(*) AS total_rows,
    SUM(User_ID IS NULL) AS missing_user_id,
    SUM(Product_ID IS NULL) AS missing_product_id,
    SUM(Category IS NULL) AS missing_category,
    SUM(`Price (Rs.)` IS NULL) AS missing_price,
    SUM(`Discount (%)` IS NULL) AS missing_discount,
    SUM(`Final_Price(Rs.)` IS NULL) AS missing_final_price,
    SUM(Payment_Method IS NULL) AS missing_payment,
    SUM(Purchase_Date IS NULL) AS missing_date
FROM ecommerce_dataset_updated;

# Check Duplicates

SELECT
    User_ID,
    Product_ID,
    Category,
    `Price (Rs.)`,
    `Discount (%)`,
    `Final_Price(Rs.)`,
    Payment_Method,
    Purchase_Date,
    COUNT(*) AS duplicate_count
FROM ecommerce_dataset_updated
GROUP BY
    User_ID,
    Product_ID,
    Category,
    `Price (Rs.)`,
    `Discount (%)`,
    `Final_Price(Rs.)`,
    Payment_Method,
    Purchase_Date
HAVING COUNT(*) > 1;

# Check Invalid Discounts

SELECT *
FROM ecommerce_dataset_updated
WHERE `Discount (%)` < 0
   OR `Discount (%)` > 100;
   
# Check Invalid Prices

SELECT *
FROM ecommerce_dataset_updated
WHERE `Price (Rs.)` <= 0 
	OR `Final_Price(Rs.)` <= 0;
    
# Check Price Calculation 

SELECT *
FROM ecommerce_dataset_updated
WHERE ABS(
    `Final_Price(Rs.)` - (`Price (Rs.)` * (1 - `Discount (%)` / 100))
) > 1;




# Dataset Overview

SELECT
	COUNT(*) AS total_transaction,
    COUNT(DISTINCT User_ID) AS unique_users,
	COUNT(DISTINCT Product_ID) AS unique_products,
    COUNT(DISTINCT Category) AS categories, 
    COUNT(DISTINCT Payment_Method) AS payment_methods
FROM ecommerce_dataset_updated;


# Overall Sales Performance

SELECT
	SUM(`Final_Price(Rs.)`) AS total_revenue,
    AVG(`Final_Price(Rs.)`) AS average_transaction_value,
    MIN(`Final_Price(Rs.)`) AS minimum_transaction_value,
    MAX(`Final_Price(Rs.)`) AS maximum_transaction_value,
    AVG(`Discount (%)`) AS average_discount
FROM ecommerce_dataset_updated;


# Revenue By Category

SELECT	
	Category,
    COUNT(*) AS transactions,
    SUM(`Final_Price(Rs.)`) AS total_revenue,
    AVG(`Final_Price(Rs.)`) AS average_transaction_value
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY total_revenue DESC;


# Category Revenue Contribution

SELECT
	Category,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(
			SUM(`Final_Price(Rs.)`) * 100 /
            (SELECT SUM(`Final_Price(Rs.)`)
            FROM ecommerce_dataset_updated), 2
    ) AS revenue_percentage
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY revenue DESC;


# Tranaction Volume By Category

SELECT
	Category,
	COUNT(*) AS transaction_count,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`),2) AS avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY transaction_count DESC;


# Payment Method Analysis

SELECT
	Payment_Method,
    COUNT(*) AS transactions,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`),2) AS avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY Payment_Method
ORDER BY transactions DESC;


# Monthly Sales Trend
    
SELECT
    YEAR(STR_TO_DATE(Purchase_Date, '%d-%m-%Y')) AS year,             # used str to date because the date in dataset was in text and not in date format
    MONTH(STR_TO_DATE(Purchase_Date, '%d-%m-%Y')) AS month,
    COUNT(*) AS transactions,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`), 2) AS avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY
    YEAR(STR_TO_DATE(Purchase_Date, '%d-%m-%Y')),
    MONTH(STR_TO_DATE(Purchase_Date, '%d-%m-%Y'))
ORDER BY
    year,
    month;
    
    
# Discout Analysis    

SELECT
	`Discount (%)`,
	COUNT(*) AS transaction_count,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`),2) AS avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY `Discount (%)`
ORDER BY `Discount (%)`;

 
 
 # Create Discount Groups

SELECT
	CASE
		WHEN `Discount (%)` = 0 THEN 'No Discount'
        WHEN `Discount (%)` <= 15 THEN 'Low Discount'
        WHEN `Discount (%)` <= 30 THEN 'Medium Discount'
        WHEN `Discount (%)` <= 45 THEN 'High Discount'
        WHEN `Discount (%)` = 50 THEN 'Very High Discount'
        ELSE 'Other'
	END AS discount_group,
    COUNT(*) AS transactions,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`),2) as avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY discount_group
ORDER BY MIN(`Discount (%)`);



# Category x Discount
SELECT
	Category,
	CASE
		WHEN `Discount (%)` = 0 THEN 'No Discount'
        WHEN `Discount (%)` <= 15 THEN 'Low Discount'
        WHEN `Discount (%)` <= 30 THEN 'Medium Discount'
        WHEN `Discount (%)` <= 45 THEN 'High Discount'
        WHEN `Discount (%)` = 50 THEN 'Very High Discount'
        ELSE 'Other'
	END AS discount_group,
    COUNT(*) AS transactions,
    SUM(`Final_Price(Rs.)`) AS revenue,
    ROUND(AVG(`Final_Price(Rs.)`),2) as avg_transaction_value
FROM ecommerce_dataset_updated
GROUP BY Category, discount_group
ORDER BY Category, discount_group;



# Discount Amount by Category

SELECT
    Category,
    ROUND(
        SUM(`Price (Rs.)` - `Final_Price(Rs.)`),
        2
    ) AS total_discount_amount,
    ROUND(
        AVG(`Price (Rs.)` - `Final_Price(Rs.)`),
        2
    ) AS avg_discount_amount
FROM ecommerce_dataset_updated
GROUP BY Category
ORDER BY total_discount_amount DESC;


# Top Transactions

SELECT
	User_ID, Product_ID, Category, `Price (Rs.)`, `Discount (%)`, `Final_Price(Rs.)`, Payment_Method, Purchase_Date
FROM ecommerce_dataset_updated
ORDER BY `Final_Price(Rs.)` DESC
LIMIT 10;


# Category Revenue and Rank Categories (CTE)

WITH category_sales AS(
	SELECT
		Category,
        COUNT(*) AS transactions,
        SUM(`Final_Price(Rs.)`) AS revenue
	FROM ecommerce_dataset_updated
    GROUP BY Category
)

SELECT
	Category,
    transactions,
    revenue,
    RANK() OVER(ORDER BY revenue DESC) AS revenue_rank
FROM category_sales
ORDER BY revenue_rank;


# Revenue Contribution Using Window Function

WITH category_sales AS(
	SELECT
		Category,
        SUM(`Final_Price(Rs.)`) AS revenue
	FROM ecommerce_dataset_updated
    GROUP BY Category
)

SELECT
	Category,
    ROUND(revenue, 2) AS revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER(),2) AS revenue_percentage
FROM category_sales
ORDER BY revenue DESC;