-- Find all customers who are located in London.
SELECT 
    *
FROM
    customers
WHERE
    city = 'London';


-- How many orders were placed by each customer? Provide the customer ID and the count of orders.    
SELECT 
    customerID, COUNT(orderID)
FROM
    orders
GROUP BY customerID;


-- Which product has the highest unit price in the Products table?
SELECT 
    *
FROM
    products
ORDER BY unitPrice DESC
LIMIT 1;


-- List the employees who report to the employee with EmployeeID of 5
SELECT 
    COUNT(employeeID)
FROM
    employees
WHERE
    reportsTo = 5;


-- Find the total quantity of products sold for each order.
SELECT 
    orderID, SUM(quantity)
FROM
    order_details
GROUP BY orderID;


-- Which category has the most products?
SELECT 
    c.categoryID, c.categoryName, COUNT(p.productID)
FROM
    categories c
        JOIN
    products p ON c.categoryID = p.categoryID
GROUP BY c.categoryID , c.categoryName
ORDER BY c.categoryID;


-- Find the average unit price of products in each category.
SELECT 
    c.categoryID,
    c.categoryName,
    ROUND((SUM(unitPrice) / COUNT(productID)), 2) AS Avg_price
FROM
    products p
        JOIN
    categories c ON p.categoryID = c.categoryID
GROUP BY c.categoryID , c.categoryName
ORDER BY categoryID;


-- List the orders that were shipped to France.
SELECT 
    orderID,
    orders.customerID,
    employeeID,
    orderDate,
    requiredDate,
    shippedDate,
    shipperID,
    freight,
    customers.country
FROM
    orders
        JOIN
    customers ON orders.customerID = customers.customerID
WHERE
    country = 'France';


-- Which shipper has delivered the most orders?
SELECT 
    shippers.shipperID,
    shippers.companyName,
    COUNT(orderID) AS order_count
FROM
    orders
        JOIN
    shippers ON orders.shipperID = shippers.shipperID
GROUP BY shippers.shipperID , shippers.companyName
ORDER BY order_count DESC
LIMIT 1;


-- List the employees who have made more than 100 sales.
SELECT 
    e.employeeID, e.employeeName, COUNT(orderID) AS order_count
FROM
    orders o
        JOIN
    employees e ON o.employeeID = e.employeeID
GROUP BY e.employeeID , e.employeeName
HAVING order_count > 100;


-- Find the customers who have placed less than 5 orders.
SELECT 
    c.customerID, c.contactName
FROM
    customers c
        JOIN
    orders o ON c.customerID = o.customerID
GROUP BY c.customerID , c.contactName
HAVING COUNT(o.orderID) < 5;


-- Which product is the most ordered?
SELECT 
    p.productID, p.productName, COUNT(orderID)
FROM
    order_details od
        JOIN
    products p ON od.productID = p.productID
GROUP BY p.productID , p.productName
ORDER BY COUNT(orderID) DESC
LIMIT 1;


-- List the OrderID and total amount for each order (total amount = UnitPrice * Quantity).
SELECT 
    orderID, ROUND((unitPrice * quantity), 2) AS total_amount
FROM
    order_details;


-- Find the OrderID with the maximum total amount.
SELECT 
    orderID, ROUND((unitPrice * quantity), 2) AS total_amount
FROM
    order_details
-- GROUP BY orderID
ORDER BY total_amount DESC
LIMIT 1;


-- List the customers who have placed more than 30 orders.
SELECT 
    c.customerID, c.contactName
FROM
    customers c
        JOIN
    orders o ON c.customerID = o.customerID
GROUP BY c.customerID , c.contactName
HAVING COUNT(o.orderID) > 30;


-- Which employee has handled the most orders?
SELECT 
    o.employeeID, COUNT(o.orderID) AS order_count
FROM
    orders o
        JOIN
    employees e ON o.employeeID = e.employeeID
GROUP BY employeeID
ORDER BY order_count DESC
LIMIT 1;


-- List the ProductName and CategoryName for all products.
SELECT 
    c.categoryID, c.categoryName, p.productID, p.productName
FROM
    categories c
        JOIN
    products p ON c.categoryID = p.categoryID
GROUP BY p.categoryID , c.categoryName , p.productID , p.productName
ORDER BY categoryID ASC;


-- - Find the total revenue (sum of Order_Details.UnitPrice * Order_Details.Quantity) for each year.
SELECT 
    YEAR(orderDate) AS year,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS total_revenue
FROM
    orders o
        JOIN
    order_details od ON o.orderID = od.orderID
GROUP BY year;


-- - List the customers who have placed orders worth more than $10,000 in total.
SELECT 
    c.customerID,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS total_revenue
FROM
    order_details od
        JOIN
    orders o ON od.orderID = o.orderID
        JOIN
    customers c ON o.customerID = c.customerID
GROUP BY c.customerID
HAVING ROUND(SUM(od.UnitPrice * od.Quantity), 2) > 10000;


-- - Which employee sold the most units of products?
SELECT 
    e.employeeID, sum(od.quantity)
FROM
    order_details od
        JOIN
    orders o ON od.orderID = o.orderID
        JOIN
    employees e ON o.employeeID = e.employeeID
GROUP BY e.employeeID
order by employeeID;


-- - List the top 5 products that generated the most revenue.
SELECT 
    productID,
    ROUND(SUM(od.UnitPrice * od.Quantity), 2) AS total_revenue
FROM
    order_details od
GROUP BY productID
ORDER BY total_revenue DESC
LIMIT 5;


-- - Find the top 3 customers who have placed the most orders for each year.
select * from 
	(select cust, yr, cnt,
	row_number() over(partition by yr order by cnt desc) as rn
	from
		(select o.customerID as cust, year(orderDate) as yr, count(od.quantity) as cnt 
		from orders o 
		join order_details od on o.orderID = od.orderID
		group by o.customerID, yr) 
	as a)
as b
where rn <= 3;
    

-- - Which category of products is the most popular among customers from the USA?
SELECT 
    ct.categoryName, COUNT(o.orderID) AS cnt
FROM
    customers c
        JOIN
    orders o ON c.customerID = o.customerID
        JOIN
    order_details od ON o.orderID = od.orderID
        JOIN
    products p ON od.productID = p.productID
        JOIN
    categories ct ON p.categoryID = ct.categoryID
WHERE
    c.country = 'USA'
GROUP BY ct.categoryName
ORDER BY cnt DESC;


-- - Find the average time it takes from an order being placed to being shipped.
SELECT AVG(DATEDIFF(orderDate, shippedDate)) AS avg_duration_days
FROM orders
WHERE orderDate IS NOT NULL AND shippedDate IS NOT NULL;


-- - List the products that have never been ordered.
SELECT DISTINCT
    od.productID
FROM
    products p
        LEFT JOIN
    order_details od ON p.productID = od.productID
WHERE
    od.productID IS NULL
;


-- - Find the product that was ordered the most in terms of quantity in each year.
select * from
(select prod, cnt, yr,
row_number() over(partition by yr order by cnt desc) as rn
from
(select p.productName as prod, count(od.quantity) as cnt, year(o.orderDate) as yr
from orders o
join order_details od on o.orderID = od.orderID
join products p on od.productID = p.productID
group by prod, yr) as a
) as b
where rn <= 5
