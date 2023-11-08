create database Steel_Challenge5;

use Steel_Challenge5;

CREATE TABLE pubs (
pub_id INT PRIMARY KEY,
pub_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(50)
);
--------------------
-- Create the 'beverages' table
CREATE TABLE beverages (
beverage_id INT PRIMARY KEY,
beverage_name VARCHAR(50),
category VARCHAR(50),
alcohol_content FLOAT,
price_per_unit DECIMAL(8, 2)
);
--------------------
-- Create the 'sales' table
CREATE TABLE sales (
sale_id INT PRIMARY KEY,
pub_id INT,
beverage_id INT,
quantity INT,
transaction_date DATE,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id),
FOREIGN KEY (beverage_id) REFERENCES beverages(beverage_id)
);
--------------------
CREATE TABLE ratings ( 
rating_id INT PRIMARY KEY,
pub_id INT,
customer_name VARCHAR(50),
rating FLOAT,
review TEXT,
FOREIGN KEY (pub_id) REFERENCES pubs(pub_id) 
);
--------------------
-- Insert sample data into the 'pubs' table
INSERT INTO pubs (pub_id, pub_name, city, state, country)
VALUES
(1, 'The Red Lion', 'London', 'England', 'United Kingdom'),
(2, 'The Dubliner', 'Dublin', 'Dublin', 'Ireland'),
(3, 'The Cheers Bar', 'Boston', 'Massachusetts', 'United States'),
(4, 'La Cerveceria', 'Barcelona', 'Catalonia', 'Spain');
--------------------
-- Insert sample data into the 'beverages' table
INSERT INTO beverages (beverage_id, beverage_name, category, alcohol_content, price_per_unit)
VALUES
(1, 'Guinness', 'Beer', 4.2, 5.99),
(2, 'Jameson', 'Whiskey', 40.0, 29.99),
(3, 'Mojito', 'Cocktail', 12.0, 8.99),
(4, 'Chardonnay', 'Wine', 13.5, 12.99),
(5, 'IPA', 'Beer', 6.8, 4.99),
(6, 'Tequila', 'Spirit', 38.0, 24.99);
--------------------
INSERT INTO sales (sale_id, pub_id, beverage_id, quantity, transaction_date)
VALUES
(1, 1, 1, 10, '2023-05-01'),
(2, 1, 2, 5, '2023-05-01'),
(3, 2, 1, 8, '2023-05-01'),
(4, 3, 3, 12, '2023-05-02'),
(5, 4, 4, 3, '2023-05-02'),
(6, 4, 6, 6, '2023-05-03'),
(7, 2, 3, 6, '2023-05-03'),
(8, 3, 1, 15, '2023-05-03'),
(9, 3, 4, 7, '2023-05-03'),
(10, 4, 1, 10, '2023-05-04'),
(11, 1, 3, 5, '2023-05-06'),
(12, 2, 2, 3, '2023-05-09'),
(13, 2, 5, 9, '2023-05-09'),
(14, 3, 6, 4, '2023-05-09'),
(15, 4, 3, 7, '2023-05-09'),
(16, 4, 4, 2, '2023-05-09'),
(17, 1, 4, 6, '2023-05-11'),
(18, 1, 6, 8, '2023-05-11'),
(19, 2, 1, 12, '2023-05-12'),
(20, 3, 5, 5, '2023-05-13');
--------------------
-- Insert sample data into the 'ratings' table
INSERT INTO ratings (rating_id, pub_id, customer_name, rating, review)
VALUES
(1, 1, 'John Smith', 4.5, 'Great pub with a wide selection of beers.'),
(2, 1, 'Emma Johnson', 4.8, 'Excellent service and cozy atmosphere.'),
(3, 2, 'Michael Brown', 4.2, 'Authentic atmosphere and great beers.'),
(4, 3, 'Sophia Davis', 4.6, 'The cocktails were amazing! Will definitely come back.'),
(5, 4, 'Oliver Wilson', 4.9, 'The wine selection here is outstanding.'),
(6, 4, 'Isabella Moore', 4.3, 'Had a great time trying different spirits.'),
(7, 1, 'Sophia Davis', 4.7, 'Loved the pub food! Great ambiance.'),
(8, 2, 'Ethan Johnson', 4.5, 'A good place to hang out with friends.'),
(9, 2, 'Olivia Taylor', 4.1, 'The whiskey tasting experience was fantastic.'),
(10, 3, 'William Miller', 4.4, 'Friendly staff and live music on weekends.');


/*1. How many pubs are located in each country??*/

select count(*) as No_of_Pubs from pubs;


/*2. What is the total sales amount for each pub, including the beverage price and quantity sold?*/

select p.pub_name, (b.price_per_unit*s.quantity) as Total_Sales from pubs p 
inner join sales s using(pub_id)
inner join beverages b using(beverage_id)
group by p.pub_name;


/*Question 3. Which pub has the highest average rating?*/

select p.pub_name, round(avg(r.rating),2) as Average_Rating from
pubs p inner join ratings r using(pub_id)
group by p.pub_name
order by Average_rating desc limit 1;

/*Question 4. What are the top 5 beverages by sales quantity across all pubs?*/

select b.beverage_name, (b.price_per_unit*s.quantity) as Total_Sales from
sales s inner join beverages b using(beverage_id)
group by b.beverage_name
order by Total_Sales desc limit 5;


/*Question 5. How many sales transactions occurred on each date?*/

select transaction_date, count(transaction_date) as Sales_transactions from
sales
group by transaction_date
order by Sales_transactions desc;


/*Question 6. Find the name of someone that had cocktails and which pub they had it in.*/

select p.pub_name, r.customer_name from pubs p
inner join ratings r using(pub_id)
inner join sales s using(pub_id)
inner join beverages b using(beverage_id)
where b.category = "Cocktail"
group by r.customer_name;


/*Question 7. What is the average price per unit for each category of beverages, excluding the category 'Spirit'?*/

select category, round(avg(price_per_unit),2) as Average_price from beverages
where category not in ("Spirit")
group by category;


/*Question 8. Which pubs have a rating higher than the average rating of all pubs?*/

select p.pub_name from
pubs p inner join ratings r using(pub_id)
where r.rating > (select round(avg(rating),2) from ratings)
group by p.pub_name;


/*Question 9. What is the running total of sales amount for each pub, ordered by the transaction date?*/

select s.pub_id, p.pub_name, s.transaction_date, (s.quantity*b.price_per_unit) as Sale,  sum(s.quantity*b.price_per_unit) over (partition by s.pub_id order by transaction_date) as Running_total  
from
sales s inner join pubs p using(pub_id)
inner join beverages b using(beverage_id)
order by s.pub_id, s.transaction_date;


/*Question 10. For each country, what is the average price per unit of beverages in each category, 
			   and what is the overall average price per unit of beverages across all categories?*/

select p.country, b.category, round(avg(b.price_per_unit),2) as average_price, round(avg(b.price_per_unit) over(partition by p.country),2) as
average_price_per_country
from pubs p inner join sales s using(pub_id)
inner join beverages b using(beverage_id)
group by p.country, b.category
order by p.country, b.category;



/* Question 11. For each pub, what is the percentage contribution of each category of beverages to the total sales amount, and what is the pub's overall sales amount?*/

select p.pub_id, p.pub_name, sum(s.quantity*b.price_per_unit) as Overall_sales, (sum(s.quantity*b.price_per_unit)/pub_total_sales.total_sales)*100 as Category_contribution,
b.category from pubs p 
JOIN sales s using(pub_id)
join beverages b using(beverage_id)
join (select s.pub_id, sum(s.quantity*b.price_per_unit) as total_sales from sales s inner join beverages b using(beverage_id) 
group by s.pub_id) as pub_total_sales on p.pub_id = pub_total_sales.pub_id
group by p.pub_id, p.pub_name, b.category, pub_total_sales.total_sales
order by p.pub_id, b.category;