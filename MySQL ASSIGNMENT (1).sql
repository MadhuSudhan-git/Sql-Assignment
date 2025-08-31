
-- MYSQL ASSIGNMENTS QUESTIONS

use classicmodels;
desc employees;
-- Q1 ---
-- a --- 
select * from employees;
select employeenumber,lastname,firstname from employees
 where jobTitle= "sales rep" and reportsTo=1102;
 
 -- b -- 
 select * from products;
 select distinct productline from products where productLine like '%cars';
 
 -- Q2 ---
 
-- a ---
select * from customers;
select customernumber,customername , case
	when country in ('usa','canada')
    then 'north america'
    when country in ('uk','france','germany')
    then 'europe'
    else 'other'
    end as customersegment
    from customers;
 
-- Q3---
-- a ---
 select * from orderdetails;
 select productcode,sum(quantityordered) as Total_Ordered
 from orderdetails
 group by productCode order by total_ordered desc limit 10;
 
 -- b 
 select * from payments;
 select monthname(paymentdate) as Payment_Month , 
 count(*)  as Num_Payments From payments 
 group by payment_month having num_payments >20 
 order by Num_payments desc;
 
 
 -- Q4 
  create database Customers_Orders;
  use customers_orders;
  
  create table customers ( customer_id int primary key auto_increment , 
  first_name varchar(50) not null , last_name varchar(50) not null ,
  email varchar(225) unique, phone_number varchar(20));
  
-- b
create table orders ( order_id int primary key auto_increment, customer_id int , order_date date ,
total_amount decimal(10,2), foreign key (customer_id) references customers(customer_id),
check (total_amount >0 ));

-- Q5
use classicmodels;
select * from customers;
select * from orders;
select c.country,count(o.ordernumber) as order_count from customers c
join orders o on c.customernumber = o.customernumber
group by c.country 
order by  order_count desc limit 5;
  
-- Q6
create table project( EmployeeID int primary key auto_increment, FullName varchar(50)
not null, Gender enum('male','female') not null , ManagerID int);

insert into project values (1,'Pranaya','Male',3),
(2,'Priyanka','Female',1),
(3,'Preety','Female',null),
(4,'Anurag','Male',1),
(5,'Sambit','Male',1),
(6,'Rajesh','Male',3),
(7,'Hina','Female',3);
select * from project;

select m.fullname as 'Manager Name',
	   e.fullname as 'Emp name'
       from project e 
       join project m on e.managerid = m.empolyeeid;
       
-- Q7

create table facility ( Facility_ID int , name varchar(20),state varchar(50),country varchar (50));

alter table facility modify facility_id int auto_increment primary key ;

alter table facility add city varchar (100) not null;

-- Q8

create view product_category_sales as select p.productline ,
	sum(od.quantityordered * od.priceeach) as Total_sales,
    count(distinct od.ordernumber) as number_of_orders
    from products p
    join orderdetails od on p.productcode = od.productcode
    group by p.productline;
    
select * from product_category_sales;

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `get_country_payments`(in input_year int 
										--- , in input_country varchar(50))
--- BEGIN
	select 
		input_year as year,
        c.country,
        concat(round(sum(p.amount)/1000),'k')
        as 'Total_amount' 
        from customers c 
        join payments p on c.customernumber = p.customernumber
        where year(p.paymentdate)=input_year 
        and c.country = input_country
        group by c.country;
        
--- END Q9 --
-- created stored procedure using create new stored procedure 

call get_country_payments(2003,'france');

--- Q10
--- a
select * from orders;
select * from customers;
select 
	c.customername , count(o.ordernumber) as order_count ,
    rank() over (order by count(o.ordernumber) desc ) as order_frequncy_rank
    from customers c
    join orders o on c.customernumber=o.customernumber
    group by c.customername;


--- b

WITH monthly_orders AS (
    SELECT
        YEAR(orderdate) AS Year,
        MONTH(orderdate) AS MonthNumber,
        MONTHNAME(orderdate) AS Month,
        COUNT(*) AS Total_Orders
    FROM orders
    GROUP BY
        YEAR(orderdate),
        MONTH(orderdate),
        MONTHNAME(orderdate)
)

SELECT
    Year,
    Month,
    Total_Orders,
    CONCAT(
        ROUND((
            Total_Orders - LAG(Total_Orders) OVER (
                PARTITION BY MonthNumber ORDER BY Year
            )
        ) * 100.0 / NULLIF(LAG(Total_Orders) OVER (
                PARTITION BY MonthNumber ORDER BY Year
            ), 0), 0),
        '%'
    ) AS YoY_Change
FROM monthly_orders
ORDER BY Year, MonthNumber;

--- Q11
select * from products;
SELECT 
    productLine,
    COUNT(*) AS Total
FROM products p1
WHERE buyPrice > (
    SELECT AVG(buyPrice)
    FROM products p2
    WHERE p1.productLine = p2.productLine
)
GROUP BY productLine
ORDER BY Total DESC;


--- Q12
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

DELIMITER //

CREATE PROCEDURE InsertEmpEH (
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(100)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Error handling block
        SELECT 'Error occurred' AS Message;
    END;

    -- Insertion statement
    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);
END //

DELIMITER ;

CALL InsertEmpEH(101, 'John Doe', 'john@example.com');


--- Q13

CREATE TABLE Emp_BIT (
    Name VARCHAR(50),
    Occupation VARCHAR(50),
    Working_date DATE,
    Working_hours INT
);


DELIMITER $$

CREATE TRIGGER before_insert_emp_bit
BEFORE INSERT ON Emp_BIT
FOR EACH ROW
BEGIN
    IF NEW.Working_hours < 0 THEN
        SET NEW.Working_hours = ABS(NEW.Working_hours);
    END IF;
END $$

DELIMITER ;


INSERT INTO Emp_BIT VALUES
('Robin', 'Scientist', '2020-10-04', 12),
('Warner', 'Engineer', '2020-10-04', 10),
('Peter', 'Actor', '2020-10-04', -4),  -- Will be converted to 4
('Marco', 'Doctor', '2020-10-04', 14),
('Brayden', 'Teacher', '2020-10-04', 12),
('Antonio', 'Business', '2020-10-04', 11);

select * from emp_bit;

 
