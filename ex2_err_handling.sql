-- Exercise 2: Error Handling

SET SERVEROUTPUT ON;

-- Scenario 1: SafeTransferFunds
-- Transfers money between two accounts.

CREATE OR REPLACE PROCEDURE SafeTransferFunds (
    p_from_account IN Accounts.AccountID%TYPE,
    p_to_account   IN Accounts.AccountID%TYPE,
    p_amount       IN NUMBER
) AS
    v_from_balance   Accounts.Balance%TYPE;
    e_insufficient_funds EXCEPTION;
BEGIN
    
    SELECT Balance INTO v_from_balance
    FROM Accounts
    WHERE AccountID = p_from_account
    FOR UPDATE;

    IF v_from_balance < p_amount THEN
        RAISE e_insufficient_funds;
    END IF;

    UPDATE Accounts
    SET Balance = Balance - p_amount
    WHERE AccountID = p_from_account;

    UPDATE Accounts
    SET Balance = Balance + p_amount
    WHERE AccountID = p_to_account;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Destination account does not exist.');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Transfer successful: ' || p_amount ||
        ' moved from Account ' || p_from_account || ' to Account ' || p_to_account);

EXCEPTION
    WHEN e_insufficient_funds THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: Insufficient funds in Account ' || p_from_account ||
            '. Transfer of ' || p_amount || ' cancelled.');

    WHEN NO_DATA_FOUND THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: Source Account ' || p_from_account || ' does not exist.');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: Transfer failed - ' || SQLERRM);
END;
/

--OUTPUT
--Procedure SAFETRANSFERFUNDS compiled


-- --------------------------------------------
-- Scenario 2: UpdateSalary
-- Increases an employee's salary by a given percentage.
-- If the employee doesn't exist, handle the exception and log it.

CREATE OR REPLACE PROCEDURE UpdateSalary (
    p_employee_id IN Employees.EmployeeID%TYPE,
    p_percent     IN NUMBER
) AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * p_percent / 100)
    WHERE EmployeeID = p_employee_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee ID ' || p_employee_id || ' not found.');
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Salary updated for Employee ID: ' || p_employee_id);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

--OUTPUT
--Procedure UPDATESALARY compiled


-- --------------------------------------------
-- Scenario 3: AddNewCustomer
-- Inserts a new customer. If a customer with the same ID already
-- exists, log an error and prevent the insertion.

CREATE OR REPLACE PROCEDURE AddNewCustomer (
    p_customer_id IN Customers.CustomerID%TYPE,
    p_name        IN Customers.Name%TYPE,
    p_dob         IN Customers.DOB%TYPE,
    p_balance     IN Customers.Balance%TYPE
) AS
BEGIN
    INSERT INTO Customers (CustomerID, Name, DOB, Balance, LastModified)
    VALUES (p_customer_id, p_name, p_dob, p_balance, SYSDATE);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Customer added: ID ' || p_customer_id || ', ' || p_name);

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: Customer ID ' || p_customer_id || ' already exists. Insertion cancelled.');

    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

--OUTPUT
--Procedure ADDNEWCUSTOMER compiled

-- ============================================
-- TEST CASES

-- Scenario 1 tests
BEGIN
    SafeTransferFunds(1, 2, 100);      
END;
/
--O/P
--Transfer successful: 100 moved from Account 1 to Account 2

BEGIN
    SafeTransferFunds(1, 2, 999999);   
END;
/
--O/P
--ERROR: Insufficient funds in Account 1. Transfer of 999999 cancelled.

BEGIN
    SafeTransferFunds(999, 2, 50);     
END;
/

--O/P
--ERROR: Source Account 999 does not exist.


-- Scenario 2 tests
BEGIN
    UpdateSalary(1, 10);                
END;
/
--O/P
--Salary updated for Employee ID: 1

BEGIN
    UpdateSalary(999, 10);             
END;
/

--O/P
--ERROR: ORA-20002: Employee ID 999 not found.


-- Scenario 3 tests
BEGIN
    AddNewCustomer(5, 'New Customer', TO_DATE('1995-01-01','YYYY-MM-DD'), 2000);  
END;
/

--O/P
--Customer added: ID 5, New Customer

BEGIN
    AddNewCustomer(1, 'John', TO_DATE('1995-01-01','YYYY-MM-DD'), 2000); 
END;
/

--O/P
--ERROR: Customer ID 1 already exists. Insertion cancelled.