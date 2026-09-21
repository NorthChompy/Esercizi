/* Task 2 DLL: Creazione delle tabelle */
CREATE DATABASE IF NOT EXISTS ToysGroup;
USE ToysGroup;

/* Tabella CATEGORIA */
CREATE TABLE CATEGORY (
Id_Category INT AUTO_INCREMENT PRIMARY KEY, 
Category_Name VARCHAR(50) NOT NULL
);
/* Tabella PRODOTTO */
CREATE TABLE PRODUCT (
Id_Product INT AUTO_INCREMENT PRIMARY KEY, 
Product_Name VARCHAR(100) NOT NULL,
Price DECIMAL(10,2) NOT NULL, 
Id_Category INT NOT NULL, 
FOREIGN KEY (Id_Category) REFERENCES CATEGORY(Id_Category)
);
/* Tabella REGIONE */ 
CREATE TABLE REGION (
Id_Region INT AUTO_INCREMENT PRIMARY KEY,
Region_Name VARCHAR(50) NOT NULL
);
/* Tabella STATE */
CREATE TABLE STATE (
Id_State INT AUTO_INCREMENT PRIMARY KEY,
State_Name VARCHAR(50) NOT NULL,
Id_Region INT NOT NULL,
FOREIGN KEY (Id_Region) REFERENCES REGION(Id_Region)
);
/* Tabella Sales */
CREATE TABLE SALES (
Id_Sales INT AUTO_INCREMENT PRIMARY KEY,
Quantity INT NOT NULL, 
Sales_Date DATE NOT NULL, 
Total_Amount DECIMAL(10,2) NOT NULL,
Id_Product INT NOT NULL,
Id_State INT NOT NULL,
FOREIGN KEY (Id_Product) REFERENCES PRODUCT(Id_Product),
FOREIGN KEY (Id_State) REFERENCES STATE(Id_State)
);

/* Task 3: Popolamento dati */
/* Popolamento CATEGORY */
INSERT INTO CATEGORY (Category_Name) VALUES 
('Board Games'),
('Action Figures');

/* Popolamento PRODUCT */
INSERT INTO PRODUCT (Product_Name, Price, Id_Category) VALUES 
('Monopoly Deluxe', 29.99, 1),
('Catan Board Game', 42.50, 1),
('Super Hero Figure', 15.00, 2),
('Robot Warrior', 24.90, 2);

/* Popolamento REGION */
INSERT INTO REGION (Region_Name) VALUES 
('Southern Europe'),
('North America');

/* Popolamento STATE */
INSERT INTO STATE (State_Name, Id_Region) VALUES 
('Italy', 1),
('Spain', 1),
('United States', 2);

/* Popolamento SALES */
INSERT INTO SALES (Quantity, Sales_Date, Total_Amount, Id_Product, Id_State) VALUES 
(2, '2022-03-15', 59.98, 1, 1),
(1, '2022-06-20', 42.50, 2, 3),
(5, '2022-11-05', 75.00, 3, 1),
(1, '2023-01-10', 24.90, 4, 3),
(3, '2023-04-18', 89.97, 1, 1),
(2, '2023-08-22', 49.80, 4, 1),
(1, '2023-12-01', 42.50, 2, 1),
(10, '2024-02-14', 150.00, 3, 3),
(1, '2024-05-30', 29.99, 1, 3),
(4, '2024-09-10', 99.60, 4, 1);

/* Task 4A: Integrità e JOIN */
/* Integrità CATEGORY */
SELECT Id_Category, COUNT(*) AS Duplicates
FROM CATEGORY
GROUP BY Id_Category
HAVING COUNT(*) > 1;
/* Integrità PRODUCT */
SELECT Id_Product, COUNT(*) AS Duplicates
FROM PRODUCT
GROUP BY Id_Product
HAVING COUNT(*) > 1;
/* Integrità REGION */
SELECT Id_Region, COUNT(*) AS Duplicates
FROM REGION
GROUP BY Id_Region
HAVING COUNT(*) > 1;
/* Integrità STATE */
SELECT Id_State, COUNT(*) AS Duplicates
FROM STATE
GROUP BY Id_State
HAVING COUNT(*) > 1;
/* Integrità SALES */
SELECT Id_Sales, COUNT(*) AS Duplicates
FROM SALES
GROUP BY Id_Sales
HAVING COUNT(*) > 1;
/* Verifica righe SALES*/ 
SELECT COUNT(*) AS Numero_Sales
FROM SALES;
/* Controllo dopo gli inner join*/
SELECT COUNT(*) AS Numero_Righe_JOIN
FROM SALES S
INNER JOIN PRODUCT P ON S.Id_Product = P.Id_Product
INNER JOIN CATEGORY C ON P.Id_Category = C.Id_Category
INNER JOIN STATE ST ON S.Id_State = ST.Id_State
INNER JOIN REGION R ON ST.Id_Region = R.Id_Region;
/* JOIN */ 
SELECT P.Id_Product AS Product_Code,
       C.Category_Name AS Category, 
       ST.State_Name AS State,
       R.Region_Name AS Region_Selling,
       S.Sales_Date AS Date_Selling,
       S.Quantity AS Quantity, 
       S.Total_Amount AS total_amount,
CASE WHEN DATEDIFF(CURDATE(), S.Sales_Date) > 180 THEN TRUE 
ELSE FALSE 
END AS More_then_180_days
FROM SALES S
INNER JOIN PRODUCT P ON S.Id_Product = P.Id_Product
INNER JOIN CATEGORY C ON P.Id_Category = C.Id_Category
INNER JOIN STATE ST ON S.Id_State = ST.Id_State
INNER JOIN REGION R ON ST.Id_Region = R.Id_Region 
ORDER BY S.Sales_Date;

/* Task 4B: Aggregazioni e ragguppamenti */
/* 1: Fatturato totale per prodotto e per anno */ 
Select Id_Product,
YEAR(Sales_Date) AS Year,
SUM(Total_Amount) AS Total_Amount
FROM SALES 
GROUP BY Id_Product, YEAR(Sales_Date);
/* 2: Fatturato totale per stato e anno, oridnato per data e fatturato decrescente */ 
Select Id_State,
YEAR(Sales_Date) AS Year,
SUM(Total_Amount) AS Total_Amount
FROM SALES
GROUP BY Id_State, YEAR(Sales_Date)
ORDER BY YEAR DESC, Total_Amount DESC;
/* 3: Categoria di prodotto più richiesta del mercato, misurata come quantità totale venduta */
SELECT C.Category_name, SUM(S.Quantity) AS Total_Quantity
FROM SALES S
INNER JOIN PRODUCT P ON S.Id_Product = P.Id_Product
INNER JOIN CATEGORY C ON P.Id_Category = C.Id_Category
GROUP BY C.Category_name
ORDER BY Total_Quantity DESC
LIMIT 1;

/* Task 4C: Subquery e CTE */
/* Punto 1: Ho fatto la somma per ogni prodotto con l'ultimo anno */
/* Punto 2: Ho fatto la media del punto 1*/
SELECT Id_Product, SUM(Quantity) AS Total_Quantity
FROM SALES
WHERE YEAR(Sales_Date) = (SELECT MAX(YEAR(Sales_Date)) FROM SALES)
GROUP BY Id_Product
HAVING SUM(Quantity) > (SELECT AVG(Product_Quantity) 
FROM ( SELECT SUM(Quantity) AS Product_Quantity
FROM SALES
WHERE YEAR(Sales_Date) = (SELECT MAX(YEAR(Sales_Date)) FROM SALES)
GROUP BY Id_Product) AS Sub_Query);

/* CTE */ 
/* Per questa ho avuto parecchi problemi con la sintassi, ma è decisamente molto più comoda e leggibile */
WITH Total_Sales_Last_Year AS (SELECT Id_Product, SUM(Quantity) AS Total_Quantity
FROM SALES
WHERE YEAR(Sales_Date) = (SELECT MAX(YEAR(Sales_Date)) 
FROM SALES)
GROUP BY Id_Product),
AverageSales AS ( SELECT AVG(Total_Quantity) AS Avg_Quantity
FROM Total_Sales_Last_Year )
SELECT T.Id_Product, T.Total_Quantity
FROM Total_Sales_Last_Year T, AverageSales A
WHERE T.Total_Quantity > A.Avg_Quantity;

/* Task 4D: Window Function */  

