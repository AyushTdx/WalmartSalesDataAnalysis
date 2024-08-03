-- Create database
create database if not exists salesDataWalmart;
use salesDataWalmart;
DROP TABLE IF EXISTS sales;

-- Create table
CREATE TABLE sales(
  invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
  branch VARCHAR(5) NOT NULL,
  city VARCHAR(30) NOT NULL,
  customer_type VARCHAR(30) NOT NULL,
  gender VARCHAR(30) NOT NULL,
  product_line VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  tax_pct DECIMAL(6,4) NOT NULL,
  total DECIMAL(12,4) NOT NULL,
  date DATETIME NOT NULL,
  time TIME NOT NULL,
  payment VARCHAR(15) NOT NULL,
  cogs DECIMAL(10,2) NOT NULL,
  gross_margin_pct DECIMAL(11,9),
  gross_income DECIMAL(12,4),
  rating DECIMAL(3,1)
);

#------------------------------FEATURE ENGINEERING------------------------------------------------#
#--------TIME OF THE DAY-------------------#
SELECT time,
  (CASE 
    WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
  END) AS time_of_day
FROM sales;

alter table sales add column time_of_day varchar(20);
update sales
set time_of_day=(CASE 
    WHEN `time` BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
    WHEN `time` BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
    ELSE 'Evening'
  END);

#-------DAY NAME----------------
select date,DAYNAME(date)
from sales;
alter table sales add column day_name varchar(20);
update sales 
set day_name=DAYNAME(date);

#-------Month NAME----------------
select date,MONTHNAME(date)
from sales;
alter table sales add column month_name varchar(20);
update sales 
set month_name=MONTHNAME(date);


-- -----------------------------------------------------------------------------------------------------------------------
-- ---------------------------- EXPLORATORY DATA ANALYSIS(EDA) -----------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Generic ------------------------------
-- --------------------------------------------------------------------
-- How many unique cities does the data have?
select distinct(city)
from sales;

-- In which city is each branch?
select distinct(branch)
from sales;

-- --------------------------------------------------------------------
-- ---------------------------- Product -------------------------------
-- --------------------------------------------------------------------
-- How many unique product lines does the data have?
select count(distinct(product_line)) as numOfProductLine
from sales;

-- What is the most selling product line
select product_line ,sum(quantity) as qty
from sales
group by product_line
order by qty desc
limit 1;

-- Most common Payment method
select payment,count(payment) as CommonPaymentMethod
from sales
group by payment
order by CommonPaymentMethod desc;

-- What is the total revenue by month
select month_name,sum(total) as revenue
from sales
group by month_name
order by revenue;

-- What month had the largest COGS?
select month_name,sum(cogs) as COGS
from sales
group by month_name
order by COGS;

-- What product line had the largest revenue?
select product_line,sum(total) as revenue
from sales
group by product_line
order by revenue;

-- What is the city with the largest revenue?
select city,sum(total) as revenue
from sales
group by city
order by revenue;

-- What product line had the largest VAT?
alter table sales add column VAT decimal(10,2);
update sales
set VAT =0.05* cogs;

select product_line,avg(VAT) as vat
from sales
group by product_line;
-- or
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT product_line,
       CASE 
           WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN 'Good'
           ELSE 'Bad'
       END AS goodBad
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING sum(quantity) > (SELECT avg(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
select product_line, avg(rating) as averageRating
from sales 
group by product_line;

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
select time_of_day,sum(quantity) as totalQuantity
from sales 
group by time_of_day;

-- Which of the customer types brings the most revenue?
select customer_type,sum(total) as revenue
from sales
group by customer_type;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
select city,avg(tax_pct) as avg_tax
from sales
group by city
order by avg_tax desc;

-- Which customer type pays the most in VAT?
select customer_type,avg(tax_pct) as avg_tax
from sales
group by customer_type;

-- --------------------------------------------------------------------
-- ---------------------------Customer---------------------------------
-- --------------------------------------------------------------------
-- How many unique customer types does the data have?
select distinct(customer_type)
from sales;

-- How many unique payment methods does the data have?
select distinct(payment)
from sales;

-- What is the most common customer type?
select customer_type,count(*) as count
from sales 
group by customer_type;

-- Which customer type buys the most?
select customer_type,sum(quantity) as total
from sales 
group by customer_type;

-- What is the gender of most of the customers?
select gender,count(*) as total
from sales 
group by gender;

-- What is the gender distribution per branch?
select branch,gender,count(*) as cnt
from sales 
group by branch,gender
order by branch;

-- Which time of the day do customers give most ratings?
select time_of_day,avg(rating) as avgRating
from sales 
group by time_of_day;

-- Which time of the day do customers give most ratings per branch?
select time_of_day,branch,avg(rating) as avgRating
from sales 
group by time_of_day,branch
order by branch asc;

-- Which day fo the week has the best avg ratings?
select day_name,avg(rating) as AvgRating
from sales 
group by day_name
order by AvgRating desc;

-- Which day of the week has the best average ratings per branch?
select branch,day_name,avg(rating) as AvgRating
from sales 
group by day_name,branch
order by branch asc,AvgRating desc;