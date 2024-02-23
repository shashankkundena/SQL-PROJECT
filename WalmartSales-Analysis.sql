USE salesdata;

CREATE TABLE Sales (
    invoice_id VARCHAR(20) NOT NULL PRIMARY KEY,
    branch VARCHAR(10) NOT NULL,
    city VARCHAR(20),
    Customer_type VARCHAR(20) NOT NULL,
    Gender VARCHAR(10) NOT NULL,
    Unit_Price DECIMAL(10,2) NOT NULL,
    Product_line VARCHAR(50) NOT NULL,
    Quantity INT NOT NULL,
    VAT DECIMAL(6,4) NOT NULL, -- Corrected data type
    total DECIMAL(12,4) NOT NULL,
    Date DATETIME NOT NULL,
    Time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    Cogs DECIMAL(10,3),
    Gross_margin_percentage FLOAT(11,9),
    Gross_income DECIMAL(12,4) NOT NULL,
    Rating FLOAT(2,1)
);



-- ---------------------------------------------------------------------------------
-- ------------------FEATURE ENGINEERING -------------------------------------------

--  time_of_day

SELECT time ,
CASE 
WHEN time between '00:00:00' AND '12:00:00' THEN 'Morning'
WHEN time between '12:01:00' AND '16:00:00' THEN 'Afternoon'
ELSE 'Evening'
END As time_of_date
FROM Sales;

Alter Table sales
ADD Column time_of_day VARCHAR(15);

UPDATE sales 
SET time_of_day=(
         CASE 
WHEN time between '00:00:00' AND '12:00:00' THEN 'Morning'
WHEN time between '12:01:00' AND '16:00:00' THEN 'Afternoon'
ELSE 'Evening'
END
)

-- ----Day_Name

-- ---- SELECTING DAY FROM THE DATE
Select  DAYNAME(Date) AS Day
FROM Sales;

-- CREATING A NEW COLUMN(DAY)
ALTER TABLE sales
ADD Column Day VARCHAR(10);

-- UPDATING THE COLUMN
UPDATE sales
SET Day=DAYNAME(Date)

-- --- MONTH NAME-------
-- CREATING A NEW COLUMN(Month)

ALTER TABLE sales
ADD COLUMN Month VARCHAR(15);

Select Date, 
Monthname(date)
From sales;

UPDATE sales
SET month=Monthname(date)

-- --- GROUPING DAYS INTO WEEKDAYS AND WEEKENDS
-- ----CREATING A NEW COLUMN(DAY-TYPE)
ALTER TABLE Sales
ADD column Day_type VARCHAR(15);

UPDATE sales
SET Day_type = 
       CASE 
       WHEN Day IN ('Saturday' , 'Sunday') THEN 'Weekend'
       ELSE 'Weekday'
       END;
       
-- ---------------------------------------------------------------------------------------------------
-- ---------------------------------GENERIC QUESTIONS-------------------------------------------------

-- -------------------------------How many unique cities does the data have?----------------------
SELECT DISTINCT(city)
FROM sales;

-- --------------------------In which city is each branch?-----------------------
SELECT DISTINCT(city),Branch
FROM Sales;

-- -----------------------------Product----------------------
-- -------------------How many unique product lines does the data have?
SELECT DISTINCT(product_line)
FROM sales;

-- ------------------What is the most common payment method?
SELECT MAX(payment_method)
FROM sales;

-- --------------What is the most selling product line?
SELECT product_line,COUNT(Product_line)
FROM sales
GROUP BY Product_line

-- -------------What is the total revenue by month?
SELECT 
month,
SUM(total) as Total_sales
FROM sales
GROUP BY Month
ORDER BY Total_sales DESC;

-- ---------What month had the largest COGS?
SELECT SUM(cogs) AS total_cogs, Month
FROM sales
GROUP BY Month 
ORDER BY total_cogs DESC;

-- -----------What product line had the largest revenue?
SELECT product_line,SUM(total) as Total_revenue
FROM sales
GROUP BY product_line
ORDER BY Total_revenue DESC;

-- ------------What is the city with the largest revenue?
SELECT 
city,SUM(total) as Total_revenue
FROM sales
GROUP BY city
ORDER by Total_revenue DESC;

-- ------------What product line had the largest VAT?
SELECT 
AVG(VAT) as AVG_Tax,product_line
FROM sales
GROUP BY product_line
ORDER BY AVG_Tax DESC;

-- ----------Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

WITH SalesData AS(
SELECT product_line,total
FROM sales)

Select
product_line,
AVG(total) as AVGsales,
CASE 
     WHEN SUM(total) > AVG(total) THEN 'Good'
     ELSE 'BAD'
END as Salesrating
FROM SalesData
GROUP BY Product_line;

-- -----------Which branch sold more products than average product sold?
SELECT branch,SUM(quantity) as qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > AVG(quantity);

-- ---------What is the most common product line by gender?
SELECT product_line,Gender, COUNT(Gender) as Total_gender
FROM sales
GROUP BY Gender,product_line
ORDER BY Total_gender DESC;

-- --------What is the average rating of each product line?
SELECT product_line,AVG(rating) AS AVG_Rating
FROM Sales
GROUP BY Product_line
ORDER BY AVG_Rating;

-- ----------SALES--------------------------

-- -----Number of sales made in each time of the day per weekday
SELECT time_of_day,COUNT(total) as Number_of_Sales
FROM sales
WHERE Day_type= "Weekday" 
GROUP BY time_of_day;

-- ---------Which of the customer types brings the most revenue?
SELECT SUM(total) as Total_revenue,customer_type
FROM sales
GROUP BY customer_type
ORDER BY Total_revenue DESC;

-- ---------Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT AVG(VAT),city
FROM sales
GROUP BY city
ORDER By AVG(VAT) DESC;

--   Which customer type pays the most in VAT?
SELECT customer_type,AVG(VAT)
FROM sales
GROUP BY customer_type
ORDER BY AVG(VAT) DESC;

-- ----CUSTOMER---------
-- ---------How many unique customer types does the data have?
SELECT distinct(Customer_type)
FROM sales;

-- -----How many unique payment methods does the data have?
SELECT distinct(payment_method)
FROM sales;

-- --------Which customer type buys the most?
SELECT COUNT(total),customer_type
FROM sales
GROUP BY customer_type;


-- -------What is the gender of most of the customers?
SELECT COUNT(Gender) AS Gender_count,gender
FROM sales
GROUP BY gender
ORDER BY Gender_count;

-- ------What is the gender distribution per branch?
SELECT branch,gender,
COUNT(gender) AS Gender_Count
FROM sales
GROUP BY branch, gender
ORDER BY branch, Gender_Count DESC;

-- -----Which time of the day do customers give most ratings?
SELECT AVG(rating) as total_ratings,time_of_day
FROM sales
GROUP BY time_of_day
ORDER By total_ratings DESC;

-- ------Which time of the day do customers give most ratings per branch?
SELECT AVG(rating) as total_ratings,time_of_day,branch
FROM sales
GROUP BY time_of_day,branch
ORDER By total_ratings DESC;

-- --------(OR)---------------
SELECT AVG(rating) as total_ratings,time_of_day
FROM sales
WHERE branch='A'
GROUP BY time_of_day
ORDER By total_ratings DESC;

-- -------------Which day of the week has the best avg ratings?
SELECT AVG(rating) as total_ratings,day
FROM sales
GROUP BY day
ORDER By total_ratings DESC;

-- ----------------Which day of the week has the best average ratings per branch?
SELECT AVG(rating) as total_ratings,day
FROM sales
WHERE Branch='A'
GROUP BY day
ORDER By total_ratings DESC;