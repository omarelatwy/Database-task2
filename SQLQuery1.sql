CREATE DATABASE CompanyDB;
GO

USE CompanyDB;
GO

CREATE SCHEMA Sales;
GO

CREATE SEQUENCE Sales.EmployeeSequence
    AS INT
    START WITH 1
    INCREMENT BY 1;
GO

CREATE TABLE Sales.employees
(
    employee_id INT NOT NULL
        DEFAULT NEXT VALUE FOR Sales.EmployeeSequence,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    salary DECIMAL(10,2)
);
GO

ALTER TABLE Sales.employees
ADD hire_date DATE;
GO

INSERT INTO Sales.employees
    (first_name, last_name, salary, hire_date)
VALUES
('John', 'Smith', 65000, '2020-05-10'),
('Jane', 'Stone', 52000, '2021-03-15'),
('Adam', 'Johnson', 48000, '2019-08-20'),
('Michael', 'Brown', 72000, '2022-02-10'),
('Sarah', 'Wilson', 55000, '2020-11-25'),
('David', 'Anderson', 43000, '2021-07-18'),
('James', 'Thomas', 60000, '2020-01-05'),
('Emily', 'Mason', 47000, '2022-06-30'),
('Robert', 'Taylor', 58000, '2018-09-12'),
('Daniel', 'Harrison', 51000, NULL),
('Emma', 'Sanders', 40000, '2020-12-01'),
('William', 'Morgan', 75000, '2023-01-20');
GO


-- =========================
-- DATA MANIPULATION
-- =========================

-- 1
SELECT *
FROM Sales.employees;

-- 2
SELECT first_name, last_name
FROM Sales.employees;

-- 3
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM Sales.employees;

-- 4
SELECT AVG(salary) AS average_salary
FROM Sales.employees;

-- 5
SELECT *
FROM Sales.employees
WHERE salary > 50000;

-- 6
SELECT *
FROM Sales.employees
WHERE YEAR(hire_date) = 2020;

-- 7
SELECT *
FROM Sales.employees
WHERE last_name LIKE 'S%';

-- 8
SELECT TOP 10 *
FROM Sales.employees
ORDER BY salary DESC;

-- 9
SELECT *
FROM Sales.employees
WHERE salary BETWEEN 40000 AND 60000;

-- 10
SELECT *
FROM Sales.employees
WHERE CONCAT(first_name, ' ', last_name) LIKE '%man%';

-- 11
SELECT *
FROM Sales.employees
WHERE hire_date IS NULL;

-- 12
SELECT *
FROM Sales.employees
WHERE salary IN (40000, 45000, 50000);

-- 13
SELECT *
FROM Sales.employees
WHERE hire_date BETWEEN '2020-01-01' AND '2021-01-01';

-- 14
SELECT *
FROM Sales.employees
ORDER BY salary DESC;

-- 15
SELECT TOP 5 *
FROM Sales.employees
ORDER BY last_name ASC;

-- 16
SELECT *
FROM Sales.employees
WHERE salary > 55000
AND YEAR(hire_date) = 2020;

-- 17
SELECT *
FROM Sales.employees
WHERE first_name IN ('John', 'Jane');

-- 18
SELECT *
FROM Sales.employees
WHERE salary <= 55000
AND hire_date > '2022-01-01';

-- 19
SELECT *
FROM Sales.employees
WHERE salary >
(
    SELECT AVG(salary)
    FROM Sales.employees
);

-- 20
SELECT *
FROM Sales.employees
ORDER BY salary DESC
OFFSET 2 ROWS
FETCH NEXT 5 ROWS ONLY;

-- 21
SELECT *
FROM Sales.employees
WHERE hire_date > '2021-01-01'
ORDER BY first_name ASC;

-- 22
SELECT *
FROM Sales.employees
WHERE salary > 50000
AND last_name NOT LIKE 'A%';

-- 23
SELECT *
FROM Sales.employees
WHERE salary IS NOT NULL;

-- 24
SELECT *
FROM Sales.employees
WHERE
(
    first_name LIKE '%e%'
    OR first_name LIKE '%i%'
    OR last_name LIKE '%e%'
    OR last_name LIKE '%i%'
)
AND salary > 45000;
GO


-- =========================
-- JOIN RELATED EXERCISES
-- =========================

-- 25
CREATE TABLE Sales.departments
(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    manager_id INT,

    CONSTRAINT FK_Department_Manager
        FOREIGN KEY (manager_id)
        REFERENCES Sales.employees(employee_id)
);
GO

INSERT INTO Sales.departments
    (department_id, department_name, manager_id)
VALUES
(1, 'IT', 1),
(2, 'HR', 2),
(3, 'Finance', 4),
(4, 'Marketing', 5);
GO

-- 26
ALTER TABLE Sales.employees
ADD department_id INT;
GO

ALTER TABLE Sales.employees
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (department_id)
REFERENCES Sales.departments(department_id);
GO

UPDATE Sales.employees
SET department_id = 1
WHERE employee_id IN (1, 3, 7);

UPDATE Sales.employees
SET department_id = 2
WHERE employee_id IN (2, 6, 10);

UPDATE Sales.employees
SET department_id = 3
WHERE employee_id IN (4, 9, 12);

UPDATE Sales.employees
SET department_id = 4
WHERE employee_id IN (5, 8, 11);
GO

-- 27
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM Sales.employees e
INNER JOIN Sales.departments d
    ON e.department_id = d.department_id;

-- 28
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM Sales.employees e
LEFT JOIN Sales.departments d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;

-- 29
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM Sales.departments d
LEFT JOIN Sales.employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name;

-- 30
SELECT
    d.department_name,
    MAX(e.salary) AS highest_salary
FROM Sales.departments d
INNER JOIN Sales.employees e
    ON d.department_id = e.department_id
GROUP BY d.department_name;
GO


-- =========================
-- STORED PROCEDURES
-- =========================

CREATE TABLE dbo.Employees
(
    Id INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO

-- 1
CREATE PROCEDURE dbo.GetAllEmployees
AS
BEGIN
    SELECT *
    FROM dbo.Employees;
END;
GO

-- 2
CREATE PROCEDURE dbo.GetHighSalaryEmployees
    @MinSalary DECIMAL(10,2)
AS
BEGIN
    SELECT *
    FROM dbo.Employees
    WHERE Salary > @MinSalary;
END;
GO

-- 3
CREATE PROCEDURE dbo.AddEmployee
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Salary DECIMAL(10,2)
AS
BEGIN
    INSERT INTO dbo.Employees
        (FirstName, LastName, Salary)
    VALUES
        (@FirstName, @LastName, @Salary);
END;
GO


-- =========================
-- EMPLOYEE LOG + TRIGGER
-- =========================

CREATE TABLE dbo.EmployeeLog
(
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT,
    Action VARCHAR(50),
    ActionDate DATETIME
);
GO

CREATE TRIGGER trg_Employee_AfterInsert
ON dbo.Employees
AFTER INSERT
AS
BEGIN
    INSERT INTO dbo.EmployeeLog
        (EmployeeId, Action, ActionDate)
    SELECT
        Id,
        'INSERT',
        GETDATE()
    FROM inserted;
END;
GO


-- =========================
-- TEST
-- =========================

EXEC dbo.AddEmployee
    @FirstName = 'Omar',
    @LastName = 'Ali',
    @Salary = 60000;

EXEC dbo.AddEmployee
    @FirstName = 'Ahmed',
    @LastName = 'Hassan',
    @Salary = 45000;

EXEC dbo.GetAllEmployees;

EXEC dbo.GetHighSalaryEmployees
    @MinSalary = 50000;

SELECT *
FROM dbo.EmployeeLog;
GO