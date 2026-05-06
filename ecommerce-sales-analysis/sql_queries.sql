-- E-Commerce Sales Analysis Project
-- Database: MySQL

CREATE DATABASE IF NOT EXISTS orders;
USE orders;

CREATE TABLE orders (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description TEXT,
    Quantity INT,
    InvoiceDate TEXT,
    UnitPrice DECIMAL(10,2),
    CustomerID VARCHAR(20),
    Country VARCHAR(50)
);

LOAD DATA LOCAL INFILE 'path_to_dataset/ecom.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

ALTER TABLE orders
ADD COLUMN TotalPrice DECIMAL(10,2);

SET SQL_SAFE_UPDATES = 0;

UPDATE orders
SET TotalPrice = IFNULL(Quantity,0) * IFNULL(UnitPrice,0);

DELETE FROM orders
WHERE InvoiceNo LIKE 'C%';

ALTER TABLE orders
ADD COLUMN CleanDate DATETIME;

UPDATE orders
SET CleanDate = STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')
WHERE CleanDate IS NULL
LIMIT 50000;

SELECT SUM(Quantity * UnitPrice) AS total_revenue
FROM orders;

SELECT Country,
       SUM(Quantity * UnitPrice) AS revenue
FROM orders
GROUP BY Country
ORDER BY revenue DESC;

SELECT MONTH(STR_TO_DATE(InvoiceDate, '%d-%m-%Y %H:%i')) AS month,
       SUM(Quantity * UnitPrice) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

SELECT CustomerID,
       SUM(Quantity * UnitPrice) AS total_spent
FROM orders
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 5;

SELECT Description,
       SUM(Quantity) AS total_sold
FROM orders
GROUP BY Description
ORDER BY total_sold DESC
LIMIT 5;

SELECT COUNT(*)
FROM orders
WHERE CustomerID IS NULL
   OR CustomerID = '';

SELECT *
FROM orders
WHERE Quantity < 0;

SELECT InvoiceNo,
       StockCode,
       COUNT(*)
FROM orders
GROUP BY InvoiceNo, StockCode
HAVING COUNT(*) > 1;
