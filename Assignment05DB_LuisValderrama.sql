--*************************************************************************--
-- Title: Assignment05
-- Author: Luis Valderrama
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2021-05-04,Luis Valderrama,Created File
--**************************************************************************--

/*Objective:
1. Create a database
2. Add Tables
3. Add Constraints
4. Add data to the tables from northwind DB
5. Answer questions 1 - 7
*/

Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_LuisValderrama')
 Begin 
  Alter Database [Assignment05DB_LuisValderrama] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_LuisValderrama;
 End
go

Create Database Assignment05DB_LuisValderrama;
go

Use Assignment05DB_LuisValderrama;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go


Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********Please use Assignment05DB_LuisValderrama database for the questions below*********/

USE Assignment05DB_LuisValderrama
GO

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--List of columns:
CategoryName, ProductName, UnitPrice

--List of Tables:
Categories, Products

--List of how these columns are connected:
Categories.CategoryID = Products.CategoryID

--Ingredients to create query:
SELECT CategoryName, ProductName, UnitPrice 
FROM Categories 
INNER JOIN Products
ON Categories.CategoryID = Products.CategoryID
ORDER BY CategoryName, ProductName ASC;
GO

-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

--List of columns:
ProductName, InventoryDate, Count

--List of Tables:
Products, Inventories

--List of how these columns are connected:
Products.ProductID = Inventories.ProductID

--Ingredients to create query:
SELECT ProductName, InventoryDate, Count
FROM Products 
INNER JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY InventoryDate, ProductName, Count;
GO

-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

--List of columns:
InventoryDate, EmployeeFirstName, EmployeeLastName

--List of Tables:
Employees, Inventories

--List of how these columns are connected:
Employees.EmployeeID = Inventories.EmployeeID

--Ingredients to create query:
SELECT DISTINCT InventoryDate, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
FROM Employees 
INNER JOIN Inventories
ON Employees.EmployeeID = Inventories.EmployeeID
ORDER BY InventoryDate; 
GO

-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

--List of columns:
CategoryName, ProductName, InventoryDate, Count

--List of Tables:
Categories, Products, Inventories

--List of how these columns are connected:
Categories.CategoryID = Products.CategoryID 
Products.ProductID = Inventories.ProductID

--Ingredients to create query:
SELECT CategoryName, ProductName, InventoryDate, Count
FROM Categories 
INNER JOIN Products
ON Categories.CategoryID = Products.CategoryID
INNER JOIN Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count; 
GO

-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

--List of columns:
CategoryName, ProductName, InventoryDate, Count, EmployeeName

--List of Tables:
Categories, Products, Inventories, Employees

--List of how these columns are connected:
Categories.CategoryID = Products.CategoryID 
Products.ProductID = Inventories.ProductID
Inventories.EmployeeID = Employees.EmployeeID

--Ingredients to create query:
SELECT CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
FROM Categories
INNER JOIN Products
ON Categories.CategoryID = Products.CategoryID
INNER JOIN Inventories
ON Products.ProductID = Inventories.ProductID
INNER JOIN Employees
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName;
GO

-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!

--List of columns:
CategoryName, ProductName, InventoryDate, Count, EmployeeName

--List of Tables:
Categories, Products, Inventories, Employees

--List of how these columns are connected:
Categories.CategoryID = Products.CategoryID 
Products.ProductID = Inventories.ProductID
Inventories.EmployeeID = Employees.EmployeeID

--Ingredients to create query:
SELECT CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
FROM Categories
INNER JOIN Products
ON Categories.CategoryID = Products.CategoryID
INNER JOIN Inventories
ON Products.ProductID = Inventories.ProductID
INNER JOIN Employees
ON Inventories.EmployeeID = Employees.EmployeeID
WHERE Inventories.ProductID IN (SELECT ProductID FROM Products WHERE ProductName LIKE 'Cha%')  
Order By InventoryDate, CategoryName, ProductName;   
GO
 
-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

SELECT 
[Manager] = IIF (ISNULL(Mgr.EmployeeID, 0) = 0, 'Manager', Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName), 
[Employee] = Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName
FROM Employees AS Emp
INNER JOIN Employees As Mgr
ON Emp.ManagerID = Mgr.EmployeeID 
ORDER BY 'Manager';
GO

/***************************************************************************************/