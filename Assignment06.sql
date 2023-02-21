--*************************************************************************--
-- Title: Assignment06
-- Author: CSchnoor
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2023-02-21,CSchnoor,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CSchnoor')
	 Begin 
	  Alter Database [Assignment06DB_CSchnoor] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CSchnoor;
	 End
	Create Database Assignment06DB_CSchnoor;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CSchnoor;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
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

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
/* go
Create -- DROP
VIEW vProducts
AS
	SELECT * FROM dbo.Products;
	GO
Select * FROM vProducts
*/

/*go
Create -- DROP
VIEW vCategories
AS
	SELECT * FROM dbo.Categories;
	GO
Select * FROM vCategories;
go

Create -- DROP
VIEW vProducts
AS
	SELECT * FROM dbo.Products;
	GO
Select * FROM vProducts;

go
Create -- DROP
VIEW vEmployees
AS
	SELECT * FROM dbo.Employees;
	GO
Select * FROM vEmployees;

go
Create -- DROP
VIEW vInventories
AS
	SELECT * FROM dbo.Inventories;
	GO
Select * FROM vInventories;
*/
 
go
Create -- DROP
VIEW vCategories
WITH SCHEMABINDING
AS
	SELECT CategoryID
	,CategoryName
	FROM dbo.Categories;
	GO
Select * FROM vCategories;
go

Create -- DROP
VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductID
	,ProductName
	,CategoryID
	,UnitPrice
	FROM dbo.Products;
	GO
Select * FROM vProducts;

go
Create -- DROP
VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID
	,EmployeeFirstName
	,EmployeeLastName
	,ManagerID
	FROM dbo.Employees;
	GO
Select * FROM vEmployees;

go
Create -- DROP
VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT InventoryID
	,InventoryDate
	,EmployeeID
	,ProductID
	,[COUNT]
	FROM dbo.Inventories;
	GO
Select * FROM vInventories;


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Use Assignment06DB_CSchnoor;

Deny Select on Categories to PUBLIC;
Grant Select on vCategories to PUBLIC;

Deny Select on Produucts to PUBLIC;
Grant Select on vProducts to PUBLIC;

Deny Select on Employeees to PUBLIC;
Grant Select on vEmployees to PUBLIC;

Deny Select on Inventories to PUBLIC;
Grant Select on vInventories to PUBLIC;

GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
/*
Create -- Drop
View vCatProd
AS
Select
	CategoryName
	,ProductName
	,UnitPrice
	FROM vCategories as c
	JOIN vProducts as p on c.CategoryID = p.CategoryID;
	go
Select * from vCatProd;
	GO
*/

Create -- Drop
View vProductsByCategories
AS
Select TOP 100000
	CategoryName
	,ProductName
	,UnitPrice
	FROM vCategories as c
	JOIN vProducts as p on c.CategoryID = p.CategoryID
	Order By CategoryName, ProductName;
	go
Select * From vProductsByCategories;
go

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Create -- Drop
View vInventoriesByProductsByDates
AS
SELECT TOP 100000
	ProductName
	,[COUNT]
	,InventoryDate
	From vProducts as p
	Join vInventories as i on p.ProductID = i.ProductID
	Order by ProductName, InventoryDate, [Count];
	GO
Select * from vInventoriesByProductsByDates;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

Create -- Drop
View vInventoriesByEmployeesByDates
AS
Select top 100000
	InventoryDate
	,EmployeeName = (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	From Inventories as i 
	Join Employees as e on i.employeeid = e.EmployeeID
	Group by InventoryDate, EmployeeFirstName, EmployeeLastName
	Order by InventoryDate;
	go
Select * from vInventoriesByEmployeesByDates;
go

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create -- Drop
View vInventoriesByProductsByCategories
AS
Select TOP 10000
	CategoryName
	,ProductName
	,InventoryDate
	,[COUNT]
	From Categories as c 
	Join Products as p on c.CategoryID = p.CategoryID
	Join Inventories as i on p.ProductID = i.ProductID
	Order by CategoryName,ProductName,inventorydate,[count];
	GO
Select * from vInventoriesByProductsByCategories;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create -- Drop
View vInventoriesByProductsByEmployees
AS
SELECT TOP 10000
	CategoryName
	,ProductName
	,InventoryDate
	,[COUNT]
	,EmployeeName = (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	From Categories as c 
	Join Products as p on c.CategoryID = p.CategoryID
	Join Inventories as i on p.ProductID = i.ProductID
	Join Employees as e on i.EmployeeID = e.EmployeeID
	Order by inventorydate,CategoryName,ProductName,[count],EmployeeFirstName,EmployeeLastName;
	GO
SElect * from vInventoriesByProductsByEmployees
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create -- Drop
View vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 10000
	CategoryName
	,ProductName
	,InventoryDate
	,[COUNT]
	,EmployeeName = (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	From Categories as c 
	Join Products as p on c.CategoryID = p.CategoryID
	Join Inventories as i on p.ProductID = i.ProductID
	Join Employees as e on i.EmployeeID = e.EmployeeID
	WHERE p.ProductID IN
	(SELECT ProductID FROM Products
		Where ProductName = 'Chai' OR ProductName = 'Chang')
	Order by inventorydate,CategoryName,ProductName,[count],EmployeeFirstName,EmployeeLastName;
	GO
SElect * from vInventoriesForChaiAndChangByEmployees;
GO

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create -- Drop
View vEmployeesByManager
AS
SELECT TOP 10000
	(Mgr.EmployeeFirstName + ' ' + Mgr.EmployeeLastName) as Manager
	,(Emp.EmployeeFirstName + ' ' + Emp.EmployeeLastName) as Employee
	From Employees as Emp JOIN Employees as Mgr
	On Emp.ManagerID = mgr.EmployeeID
	Order by mgr.EmployeefirstName;
GO
Select * from vEmployeesByManager;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/*
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 10000
	c.CategoryID
	,CategoryName
	,p.ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,Inventorydate 
	,[COUNT]
	FROM vCategories as c
	JOIN vProducts as p on c.CategoryID = p.CategoryID
	JOIN vInventories as i on p.ProductID = i.ProductID
	JOIN vEmployees as e on i.EmployeeID = e.EmployeeID

	Order by CategoryID,ProductID,inventoryid,e.EmployeeFirstName,e.EmployeeLastName;
GO
select * from vInventoriesByProductsByCategoriesByEmployees
*/
/*
Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 10000
	c.CategoryID
	,CategoryName
	,p.ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,Inventorydate 
	,[COUNT]
	,e.EmployeeID
	,Employee = (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	,e.ManagerID
	,Manager = (m.EmployeeFirstName + ' ' + m.EmployeeLastName)
	FROM vCategories as c
	JOIN vProducts as p on c.CategoryID = p.CategoryID
	JOIN vInventories as i on p.ProductID = i.ProductID
	JOIN vEmployees as e on i.EmployeeID = e.EmployeeID
	JOIN vEmployees as m on e.managerID = m.employeeID
	Order by c.CategoryID,p.ProductID,inventoryid,e.EmployeeFirstName;
GO
select * from vInventoriesByProductsByCategoriesByEmployees
*/

Create -- Drop
View vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 10000
	c.CategoryID
	,CategoryName
	,p.ProductID
	,ProductName
	,UnitPrice
	,InventoryID
	,Inventorydate 
	,[COUNT]
	,e.EmployeeID
	,Employee = (e.EmployeeFirstName + ' ' + e.EmployeeLastName)
	,Manager = (m.EmployeeFirstName + ' ' + m.EmployeeLastName)
	FROM vCategories as c
	JOIN vProducts as p on c.CategoryID = p.CategoryID
	JOIN vInventories as i on p.ProductID = i.ProductID
	JOIN vEmployees as e on i.EmployeeID = e.EmployeeID
	JOIN vEmployees as m on e.managerID = m.employeeID
	Order by c.CategoryID,p.ProductID,inventoryid,e.EmployeeFirstName;
GO
select * from vInventoriesByProductsByCategoriesByEmployees

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/