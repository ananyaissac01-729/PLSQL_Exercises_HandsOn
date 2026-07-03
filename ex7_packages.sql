-- Exercise 7: Packages

SET SERVEROUTPUT ON;

-- Scenario 1: Group all customer-related procedures and functions into a package
CREATE OR REPLACE PACKAGE CustomerManagement AS
    PROCEDURE AddCustomer (
        p_customer_id IN Customers.CustomerID%TYPE,
        p_name        IN Customers.Name%TYPE,
        p_dob         IN Customers.DOB%TYPE,
        p_balance     IN Customers.Balance%TYPE
    );
 
    PROCEDURE UpdateCustomerDetails (
        p_customer_id IN Customers.CustomerID%TYPE,
        p_name        IN Customers.Name%TYPE DEFAULT NULL,
        p_balance     IN Customers.Balance%TYPE DEFAULT NULL
    );
 
    FUNCTION GetCustomerBalance (
        p_customer_id IN Customers.CustomerID%TYPE
    ) RETURN NUMBER;
END CustomerManagement;
/
CREATE OR REPLACE PACKAGE BODY CustomerManagement AS
 
    PROCEDURE AddCustomer (
        p_customer_id IN Customers.CustomerID%TYPE,
        p_name        IN Customers.Name%TYPE,
        p_dob         IN Customers.DOB%TYPE,
        p_balance     IN Customers.Balance%TYPE
    ) IS
    BEGIN
        INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
        VALUES (p_customer_id, p_name, p_dob, p_balance, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Customer added: ' || p_name);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Customer ID ' || p_customer_id || ' already exists.');
    END AddCustomer;
 
 
    PROCEDURE UpdateCustomerDetails (
        p_customer_id IN Customers.CustomerID%TYPE,
        p_name        IN Customers.Name%TYPE DEFAULT NULL,
        p_balance     IN Customers.Balance%TYPE DEFAULT NULL
    ) IS
    BEGIN
        UPDATE Customers
        SET Name    = NVL(p_name, Name),
            Balance = NVL(p_balance, Balance)
        WHERE CustomerID = p_customer_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Customer ID ' || p_customer_id || ' not found.');
        ELSE
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Customer ' || p_customer_id || ' updated.');
        END IF;
    END UpdateCustomerDetails;
 
 
    FUNCTION GetCustomerBalance (
        p_customer_id IN Customers.CustomerID%TYPE
    ) RETURN NUMBER IS
        v_balance Customers.Balance%TYPE;
    BEGIN
        SELECT Balance INTO v_balance
        FROM Customers
        WHERE CustomerID = p_customer_id;
 
        RETURN v_balance;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END GetCustomerBalance;
 
END CustomerManagement;
/
-- O/P
--Package CUSTOMERMANAGEMENT compiled
--Package Body CUSTOMERMANAGEMENT compiled
 

-- Scenario 2: Create a package to manage employee data.
CREATE OR REPLACE PACKAGE EmployeeManagement AS
    PROCEDURE HireEmployee (
        p_employee_id IN Employees.EmployeeID%TYPE,
        p_name        IN Employees.Name%TYPE,
        p_position    IN Employees.Position%TYPE,
        p_salary      IN Employees.Salary%TYPE,
        p_department  IN Employees.Department%TYPE
    );
 
    PROCEDURE UpdateEmployeeDetails (
        p_employee_id IN Employees.EmployeeID%TYPE,
        p_position    IN Employees.Position%TYPE DEFAULT NULL,
        p_department  IN Employees.Department%TYPE DEFAULT NULL
    );
 
    FUNCTION CalculateAnnualSalary (
        p_employee_id IN Employees.EmployeeID%TYPE
    ) RETURN NUMBER;
END EmployeeManagement;
/
--O/P

 
CREATE OR REPLACE PACKAGE BODY EmployeeManagement AS
 
    PROCEDURE HireEmployee (
        p_employee_id IN Employees.EmployeeID%TYPE,
        p_name        IN Employees.Name%TYPE,
        p_position    IN Employees.Position%TYPE,
        p_salary      IN Employees.Salary%TYPE,
        p_department  IN Employees.Department%TYPE
    ) IS
    BEGIN
        INSERT INTO Employees (EmployeeID, Name, Position, Salary, Department, HireDate)
        VALUES (p_employee_id, p_name, p_position, p_salary, p_department, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Employee hired: ' || p_name || ' (' || p_position || ')');
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_employee_id || ' already exists.');
    END HireEmployee;
 
 
    PROCEDURE UpdateEmployeeDetails (
        p_employee_id IN Employees.EmployeeID%TYPE,
        p_position    IN Employees.Position%TYPE DEFAULT NULL,
        p_department  IN Employees.Department%TYPE DEFAULT NULL
    ) IS
    BEGIN
        UPDATE Employees
        SET Position   = NVL(p_position, Position),
            Department = NVL(p_department, Department)
        WHERE EmployeeID = p_employee_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_employee_id || ' not found.');
        ELSE
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Employee ' || p_employee_id || ' updated.');
        END IF;
    END UpdateEmployeeDetails;
 
 
    FUNCTION CalculateAnnualSalary (
        p_employee_id IN Employees.EmployeeID%TYPE
    ) RETURN NUMBER IS
        v_monthly_salary Employees.Salary%TYPE;
    BEGIN
        SELECT Salary INTO v_monthly_salary
        FROM Employees
        WHERE EmployeeID = p_employee_id;
 
        RETURN v_monthly_salary * 12;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END CalculateAnnualSalary;
 
END EmployeeManagement;
/
--O/P
--Package EMPLOYEEMANAGEMENT compiled
--Package Body EMPLOYEEMANAGEMENT compiled


-- Scenario 3: Group all account-related operations into a package.

CREATE OR REPLACE PACKAGE AccountOperations AS
    PROCEDURE OpenAccount (
        p_account_id   IN Accounts.AccountID%TYPE,
        p_customer_id  IN Accounts.CustomerID%TYPE,
        p_account_type IN Accounts.AccountType%TYPE,
        p_initial_balance IN Accounts.Balance%TYPE
    );
 
    PROCEDURE CloseAccount (
        p_account_id IN Accounts.AccountID%TYPE
    );
 
    FUNCTION GetTotalBalance (
        p_customer_id IN Customers.CustomerID%TYPE
    ) RETURN NUMBER;
END AccountOperations;
/
 
CREATE OR REPLACE PACKAGE BODY AccountOperations AS
 
    PROCEDURE OpenAccount (
        p_account_id   IN Accounts.AccountID%TYPE,
        p_customer_id  IN Accounts.CustomerID%TYPE,
        p_account_type IN Accounts.AccountType%TYPE,
        p_initial_balance IN Accounts.Balance%TYPE
    ) IS
    BEGIN
        INSERT INTO Accounts (AccountID, CustomerID, AccountType, Balance, LastModified)
        VALUES (p_account_id, p_customer_id, p_account_type, p_initial_balance, SYSDATE);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Account opened: ID ' || p_account_id ||
            ' (' || p_account_type || ') for Customer ' || p_customer_id);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Account ID ' || p_account_id || ' already exists.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END OpenAccount;
 
 
    PROCEDURE CloseAccount (
        p_account_id IN Accounts.AccountID%TYPE
    ) IS
    BEGIN
        DELETE FROM Accounts WHERE AccountID = p_account_id;
 
        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Account ID ' || p_account_id || ' not found.');
        ELSE
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Account ' || p_account_id || ' closed.');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            -- e.g. fails if Transactions still reference this account (FK constraint)
            DBMS_OUTPUT.PUT_LINE('ERROR: Could not close account - ' || SQLERRM);
    END CloseAccount;
 
 
    FUNCTION GetTotalBalance (
        p_customer_id IN Customers.CustomerID%TYPE
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(Balance), 0) INTO v_total
        FROM Accounts
        WHERE CustomerID = p_customer_id;
 
        RETURN v_total;
    END GetTotalBalance;
 
END AccountOperations;
/
--O/P
--Package ACCOUNTOPERATIONS compiled
--Package Body ACCOUNTOPERATIONS compiled

-- TEST CASES
BEGIN
    CustomerManagement.AddCustomer(6, 'Priya Nair', TO_DATE('1998-04-12','YYYY-MM-DD'), 3000);
    DBMS_OUTPUT.PUT_LINE('Balance check: ' || CustomerManagement.GetCustomerBalance(6));
 
    CustomerManagement.UpdateCustomerDetails(6, p_balance => 3500);
    DBMS_OUTPUT.PUT_LINE('Updated balance: ' || CustomerManagement.GetCustomerBalance(6));
END;
/

-- O/P
/*
Customer added: Priya Nair

Balance check: 3000

Customer 6 updated.

Updated balance: 3500
*/

BEGIN
    EmployeeManagement.HireEmployee(3, 'Arjun Menon', 'Analyst', 45000, 'Finance');
    DBMS_OUTPUT.PUT_LINE('Annual salary: ' || EmployeeManagement.CalculateAnnualSalary(3));
END;
/

--O/P
/*
Employee hired: Arjun Menon (Analyst)
Annual salary: 540000
*/

BEGIN
    AccountOperations.OpenAccount(3, 1, 'Savings', 500);
    DBMS_OUTPUT.PUT_LINE('Total balance for Customer 1: ' || AccountOperations.GetTotalBalance(1));
END;
/
--O/P
/*
Account opened: ID 3 (Savings) for Customer 1
Total balance for Customer 1: 1593.09
*/