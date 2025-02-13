select count(*) as count_of_transactions from assessment_data;

--Gives the total no of transactions :500000

select count(*) as trasactions,city,PaymentMethod from assessment_data
group by city,PaymentMethod
order by  city,trasactions desc;

--gives the transaction count by city and payment method

--bangalore has the highest transaction count

---debit card transactions are higher following cash upi credit card

SELECT SUM(TransactionAmount) AS Total_Revenue FROM assessment_data;

---10202662960.19042 is the total revenue generated

SELECT CustomerID, AVG(TransactionAmount) AS Avg_Purchase 
FROM assessment_data 
GROUP BY CustomerID 
ORDER BY Avg_Purchase DESC;

---34341 has the highest average purchase of 99687

SELECT ProductName, COUNT(*) AS Total_Sales
FROM assessment_data
GROUP BY ProductName 
ORDER BY Total_Sales DESC 
LIMIT 5;

/*notebook has highest transacrions and sofa being the least.
but considering the cost laptop earns the most laptop a product with fewer sales but higher revenue means it has a higher price point*/


SELECT City, SUM(TransactionAmount) AS City_Revenue
FROM assessment_data
GROUP BY City 
ORDER BY City_Revenue DESC;

--kolkata has highest revenue and hyderabad being the least

SELECT DiscountPercent, COUNT(*) AS Transactions, 
       AVG(TransactionAmount) AS Avg_Sale ,city
FROM assessment_data
GROUP BY DiscountPercent ,city
ORDER BY DiscountPercent DESC;

----when 50percent  discount is provided, kolkata earned a good revenue and has the highest avg sale


SELECT 
    CASE 
        WHEN CustomerAge < 20 THEN 'Under 20'
        WHEN CustomerAge BETWEEN 20 AND 30 THEN '20-30'
        WHEN CustomerAge BETWEEN 31 AND 40 THEN '31-40'
        WHEN CustomerAge BETWEEN 41 AND 50 THEN '41-50'
        ELSE 'Above 50'
    END AS Age_Group,
    COUNT(*) AS Customers 
FROM assessment_data
GROUP BY Age_Group 
ORDER BY Age_Group;


---people with age 20-30 are the targeted customers and sale need to be improved for age below 20 .people around  31-40 and 41-50 age  has the similar count of customers

SELECT Region, AVG(DeliveryTimeDays) AS Avg_Delivery_Days
FROM assessment_data
GROUP BY Region 
ORDER BY Avg_Delivery_Days;

--north and west has the similar avg delivery time while most data is empty

SELECT CustomerID,CASE 
        WHEN CustomerAge < 20 THEN 'Under 20'
        WHEN CustomerAge BETWEEN 20 AND 30 THEN '20-30'
        WHEN CustomerAge BETWEEN 31 AND 40 THEN '31-40'
        WHEN CustomerAge BETWEEN 41 AND 50 THEN '41-50'
        ELSE 'Above 50'
    END AS Age_Group, sum(LoyaltyPoints) as LoyaltyPoints_total
FROM assessment_data
group by customerID,Age_Group,LoyaltyPoints
ORDER BY LoyaltyPoints DESC 
LIMIT 10;

--cutomer id 43770 Belongs to age group 41-50 has higher loyalty points and 5 people are above 50 and rest goes with other age group in the top 10


SELECT CustomerID, COUNT(*) AS Total_Returns
FROM assessment_data
WHERE Returned = 'Yes'
GROUP BY CustomerID 
ORDER BY Total_Returns DESC
LIMIT 5;

---43135 has made the highest returns and most of the returns are unoragnised in terms of data 

SELECT 
    IsPromotional,
    COUNT(*) AS total_transactions,
    SUM(TransactionAmount) AS total_revenue,
    AVG(TransactionAmount) AS avg_transaction_value
FROM assessment_data
GROUP BY IsPromotional;

--eventhough a product  is not promtional, has higher number of transaction and total transaction cost 

SELECT 
    ProductName,
    COUNT(*) AS total_returns,
    SUM(TransactionAmount) AS total_refunded
FROM assessment_data
WHERE Returned = 'Yes'
GROUP BY ProductName
ORDER BY total_returns DESC
LIMIT 5;

---notebook has the highest returns and total amount refunded is 12 million approxiamtely.
--Since laptop and sofa are high prices,though they have less returns has the higher refund amount


SELECT City, COUNT(*) AS total_returns
FROM assessment_data
WHERE Returned = 'Yes'
GROUP BY City
HAVING COUNT(*) = (
    SELECT MAX(return_count) 
    FROM (SELECT City, COUNT(*) AS return_count 
          FROM assessment_data 
          WHERE Returned = 'Yes'
          GROUP BY City) AS return_table
);

---delhi has highest count of returns

SELECT ProductName, SUM(TransactionAmount) AS total_revenue
FROM assessment_data
GROUP BY ProductName
HAVING SUM(TransactionAmount) = (
    SELECT MAX(product_revenue) 
    FROM (SELECT ProductName, SUM(TransactionAmount) AS product_revenue 
          FROM assessment_data 
          GROUP BY ProductName) AS product_revenue_table
);


---laptop has the highest revenue,this can also be added to stored procedure

SELECT 
    ProductName, 
    COUNT(*) AS total_purchases,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS product_rank
FROM assessment_data
GROUP BY ProductName
ORDER BY product_rank;

--- gets the top ranked product based on count of purchases


SELECT 
    City, 
    CustomerID, 
    SUM(TransactionAmount) AS total_spent,
    RANK() OVER (PARTITION BY City ORDER BY SUM(TransactionAmount) DESC) AS city_spending_rank
FROM assessment_data
GROUP BY City, CustomerID
ORDER BY City, city_spending_rank;

---ranks the city based on total spent amount, ahmedabad being the first ranked



SELECT CustomerID, CustomerName, COUNT(DISTINCT ProductName) AS unique_products_purchased
FROM assessment_data
GROUP BY CustomerID, CustomerName
HAVING COUNT(DISTINCT ProductName) = (
    SELECT MAX(unique_product_count) 
    FROM (SELECT CustomerID, COUNT(DISTINCT ProductName) AS unique_product_count 
          FROM assessment_data 
          GROUP BY CustomerID) AS customer_products
);


----every customer has mostly the trasaction record to buy unique 5 items

SELECT 
    StoreType,
    SUM(TransactionAmount) AS total_revenue,
    COUNT(*) AS total_transactions,
    AVG(TransactionAmount) AS avg_transaction_value
FROM assessment_data
GROUP BY StoreType
ORDER BY total_revenue DESC;

--customers are preferring offline a little more compared to online considering the no of transactions and transactions value


SELECT StoreType, SUM(Quantity) AS total_quantity_sold
FROM assessment_data
GROUP BY StoreType
HAVING SUM(Quantity) = (
    SELECT MAX(total_quantity) 
    FROM (SELECT StoreType, SUM(Quantity) AS total_quantity 
          FROM assessment_data 
          GROUP BY StoreType) AS store_quantity_table
);
--but considering the total quanity online is leading


SELECT A.CustomerID, A.StoreType AS first_store, B.StoreType AS second_store
FROM assessment_data A
JOIN assessment_data B
ON A.CustomerID = B.CustomerID
AND A.StoreType <> B.StoreType
AND A.TransactionID <> B.TransactionID;

-----most of customers preferring both  modes of stores



SELECT A.CustomerID, A.ProductName, COUNT(*) AS purchase_count
FROM assessment_data A
JOIN assessment_data B
ON A.CustomerID = B.CustomerID 
AND A.ProductName = B.ProductName
AND A.TransactionID <> B.TransactionID
GROUP BY A.CustomerID, A.ProductName
HAVING COUNT(*) > 1
ORDER BY purchase_count DESC;

----many cutomers repurchased the same item multiple times .39540 and 39732 has repurchased sofa and laptop respectivrly multiple time


SELECT PaymentMethod, COUNT(*) AS usage_count
FROM assessment_data
WHERE CustomerID IN (
    SELECT CustomerID FROM assessment_data 
    GROUP BY CustomerID 
    HAVING SUM(TransactionAmount) > (
        SELECT AVG(TransactionAmount) FROM assessment_data
    )
)
GROUP BY PaymentMethod
ORDER BY usage_count DESC
LIMIT 1;

---debit card is most used payment method by high-spending customers

SELECT CustomerID, CustomerName, SUM(TransactionAmount) AS total_spent
FROM assessment_data
GROUP BY CustomerID, CustomerName
HAVING SUM(TransactionAmount) > (
    SELECT AVG(TransactionAmount) FROM assessment_data
)
ORDER BY total_spent DESC;


----32460 has spent more than the average transaction amount


SELECT 
    LoyaltyPoints,
    AVG(DiscountPercent) AS avg_discount,
    COUNT(*) AS total_transactions,
    SUM(TransactionAmount) AS total_spent
FROM assessment_data
GROUP BY LoyaltyPoints
ORDER BY LoyaltyPoints DESC;


--a person with highest loyalty point of 9999 gets a discount of 21% but there are higher discount provided to other customers since they have more transactions 

SELECT 
    CustomerID, 
    SUM(TransactionAmount) AS total_spent,
    RANK() OVER (ORDER BY SUM(TransactionAmount) DESC) AS spending_rank
FROM assessment_data
GROUP BY CustomerID
ORDER BY spending_rank

--32460 and 39732 are top spending customers and rest are ordered

    SELECT 
    DeliveryTimeDays,
    AVG(FeedbackScore) AS avg_feedback_score,
    COUNT(*) AS total_transactions
FROM assessment_data
GROUP BY DeliveryTimeDays
ORDER BY avg_feedback_score DESC;


---average feedabck scores aroung 2.9-3.0 irrespective of the delivery time


---all these results can be grouped into a stored procedure to run as per the requiremnet evrytime.if we dont want the data to be stored a view can be used


