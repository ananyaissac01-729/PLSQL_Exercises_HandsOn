-- Exercise 5: Triggers

SET SERVEROUTPUT ON;
-- Scenario 1: Automatically update the last modified date when a customer's record is updated.

CREATE OR REPLACE TRIGGER UpdateCustomerLastModified
BEFORE UPDATE ON Customers
FOR EACH ROW
BEGIN
    :NEW.LastModified := SYSDATE;
END;
/
--O/P: Trigger UPDATECUSTOMERLASTMODIFIED compiled


-- Scenario 2: Maintain an audit log for all transactions.
CREATE TABLE AuditLog (
    LogID           NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TransactionID   NUMBER,
    AccountID       NUMBER,
    Amount          NUMBER,
    TransactionType VARCHAR2(10),
    LoggedAt        DATE DEFAULT SYSDATE
);

--Table AUDITLOG created.

CREATE OR REPLACE TRIGGER LogTransaction
AFTER INSERT ON Transactions
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TransactionID, AccountID, Amount, TransactionType, LoggedAt)
    VALUES (:NEW.TransactionID, :NEW.AccountID, :NEW.Amount, :NEW.TransactionType, SYSDATE);
END;
/
--O/P: Trigger LOGTRANSACTION compiled


-- Scenario 3: Enforce business rules on deposits and withdrawals

CREATE OR REPLACE TRIGGER CheckTransactionRules
BEFORE INSERT ON Transactions
FOR EACH ROW
DECLARE
    v_balance Accounts.Balance%TYPE;
BEGIN
    SELECT Balance INTO v_balance
    FROM Accounts
    WHERE AccountID = :NEW.AccountID;
 
    IF :NEW.TransactionType = 'Deposit' AND :NEW.Amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Deposit amount must be positive.');
    END IF;
 
    IF :NEW.TransactionType = 'Withdrawal' AND :NEW.Amount > v_balance THEN
        RAISE_APPLICATION_ERROR(-20011, 'Withdrawal exceeds account balance.');
    END IF;
END;
/
-- Trigger CHECKTRANSACTIONRULES compiled

-- TEST CASES

SELECT CustomerID, Balance, LastModified FROM Customers WHERE CustomerID = 1;
-- IF BALANCE = 1000

UPDATE Customers SET Balance = Balance + 50 WHERE CustomerID = 1;

SELECT CustomerID, Balance, LastModified FROM Customers WHERE CustomerID = 1;
-- BALANCE CHANGES TO 1050

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (3, 1, SYSDATE, 100, 'Deposit');
--1 row inserted.

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (4, 1, SYSDATE, 50, 'Deposit');
-- 1 row inserted.

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (5, 1, SYSDATE, 999999, 'Withdrawal');
-- SQL Error: ORA-20011: Withdrawal exceeds account balance.

INSERT INTO Transactions (TransactionID, AccountID, TransactionDate, Amount, TransactionType)
VALUES (6, 1, SYSDATE, -100, 'Deposit');
-- SQL Error: ORA-20010: Deposit amount must be positive.

SELECT * FROM AuditLog;

COMMIT;