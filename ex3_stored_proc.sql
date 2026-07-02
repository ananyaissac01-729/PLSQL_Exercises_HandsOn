-- Exercise 3: Stored Procedures

SET SERVEROUTPUT ON;

-- Scenario 1: 
-- The bank needs to process monthly interest for all savings accounts.

CREATE OR REPLACE PROCEDURE ProcessMonthlyInterest AS
BEGIN
    FOR acc_rec IN (
        SELECT AccountID, Balance
        FROM Accounts
        WHERE AccountType = 'Savings'
    ) LOOP
        UPDATE Accounts
        SET Balance = Balance + (Balance * 0.01),
            LastModified = SYSDATE
        WHERE AccountID = acc_rec.AccountID;
 
        DBMS_OUTPUT.PUT_LINE('Interest applied to Account ' || acc_rec.AccountID ||
            ': old balance ' || acc_rec.Balance ||
            ', new balance ' || (acc_rec.Balance + acc_rec.Balance * 0.01));
    END LOOP;
 
    COMMIT;
END;
/

--Scenario 2: 
--The bank wants to implement a bonus scheme for employees based on their performance.

CREATE OR REPLACE PROCEDURE UpdateEmployeeBonus(
    p_department IN Employees.Department%TYPE,
    p_bonus_pct IN NUMBER
) AS
BEGIN
    UPDATE Employees
    SET Salary = Salary + (Salary * p_bonus_pct / 100)
    WHERE Department = p_department;

    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No employees found in department: ' || p_department);
    ELSE
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' employee(s) in ' || p_department || ' received a ' || p_bonus_pct || '% bonus');
    END IF;

    COMMIT;

EXCEPTION 
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR : ' || SQLERRM);
END;
/

-- O/P : Procedure UPDATEEMPLOYEEBONUS compiled

--Scenario 3: 
--Customers should be able to transfer funds between their accounts.

CREATE OR REPLACE PROCEDURE TransferFunds (
    p_from_account IN Accounts.AccountID%TYPE,
    p_to_account   IN Accounts.AccountID%TYPE,
    p_amount       IN NUMBER
) AS
    v_from_balance Accounts.Balance%TYPE;
BEGIN
    SELECT Balance INTO v_from_balance
    FROM Accounts
    WHERE AccountID = p_from_account;
 
    IF v_from_balance >= p_amount THEN
        UPDATE Accounts
        SET Balance = Balance - p_amount
        WHERE AccountID = p_from_account;
 
        UPDATE Accounts
        SET Balance = Balance + p_amount
        WHERE AccountID = p_to_account;
 
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Transferred ' || p_amount || ' from Account ' ||
            p_from_account || ' to Account ' || p_to_account);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Transfer failed: Account ' || p_from_account ||
            ' has insufficient balance (' || v_from_balance || ').');
    END IF;
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Account ' || p_from_account || ' does not exist.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
END;
/

--O/P : Procedure TRANSFERFUNDS compiled

-- TEST CASES

BEGIN
    ProcessMonthlyInterest;
END;
/

-- O/P: Interest applied to Account 1: old balance 900, new balance 909

BEGIN
    ProcessMonthlyInterest;
END;
/

--O/P: Interest applied to Account 1: old balance 909, new balance 918.09

BEGIN
    UpdateEmployeeBonus('IT', 5);       
END;
/

--O/P: 1 employee(s) in IT received a 5% bonus

BEGIN
    UpdateEmployeeBonus('Sales', 5);    
END;
/

--O/P: No employees found in department: Sales

BEGIN
    TransferFunds(2, 1, 200);
END;
/

--O/P: Transferred 200 from Account 2 to Account 1

BEGIN
    TransferFunds(1, 2, 999999);      
END;
/

--O/P: Transfer failed: Account 1 has insufficient balance (1118.09).