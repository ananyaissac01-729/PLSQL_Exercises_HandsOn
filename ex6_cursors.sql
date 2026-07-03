-- Exercise 6: Cursors

SET SERVEROUTPUT ON;

-- Scenario 1: Generate monthly statements for all customers.

DECLARE
    CURSOR stmt_cursor IS
        SELECT c.CustomerID, c.Name, t.TransactionID, t.TransactionDate,
               t.Amount, t.TransactionType
        FROM Transactions t
        JOIN Accounts a ON t.AccountID = a.AccountID
        JOIN Customers c ON a.CustomerID = c.CustomerID
        WHERE TRUNC(t.TransactionDate, 'MM') = TRUNC(SYSDATE, 'MM')
        ORDER BY c.CustomerID, t.TransactionDate;

    v_current_customer Customers.CustomerID%TYPE := -1;
    v_row_count NUMBER := 0;          -- add this
BEGIN
    FOR stmt_rec IN stmt_cursor LOOP
        v_row_count := v_row_count + 1;   -- add this, increments each iteration

        IF stmt_rec.CustomerID != v_current_customer THEN
            DBMS_OUTPUT.PUT_LINE('--- Statement for ' || stmt_rec.Name ||
                ' (Customer ID: ' || stmt_rec.CustomerID || ') ---');
            v_current_customer := stmt_rec.CustomerID;
        END IF;

        DBMS_OUTPUT.PUT_LINE('  Txn ' || stmt_rec.TransactionID || ': ' ||
            stmt_rec.TransactionType || ' of ' || stmt_rec.Amount ||
            ' on ' || TO_CHAR(stmt_rec.TransactionDate, 'DD-MON-YYYY'));
    END LOOP;

    IF v_row_count = 0 THEN           --
        DBMS_OUTPUT.PUT_LINE('No transactions found for the current month.');
    END IF;
END;
/
-- OUTPUT
--Statement for John Doe (Customer ID: 1) --
--Txn 1: Deposit of 200 on 02-JUL-2026
--Statement for Jane Smith (Customer ID: 2) ---
--Txn 2: Withdrawal of 300 on 02-JUL-2026
--PL/SQL procedure successfully completed.


-- Scenario 2: Apply annual fee to all accounts.
DECLARE
    CURSOR fee_cursor IS
        SELECT AccountID, Balance
        FROM Accounts
        FOR UPDATE OF Balance;
 
    v_annual_fee CONSTANT NUMBER := 25;
BEGIN
    FOR acc_rec IN fee_cursor LOOP
        UPDATE Accounts
        SET Balance = Balance - v_annual_fee,
            LastModified = SYSDATE
        WHERE CURRENT OF fee_cursor;
 
        DBMS_OUTPUT.PUT_LINE('Annual fee of ' || v_annual_fee ||
            ' deducted from Account ' || acc_rec.AccountID ||
            '. New balance: ' || (acc_rec.Balance - v_annual_fee));
    END LOOP;
 
    COMMIT;
END;
/
-- OUTPUT
--Annual fee of 25 deducted from Account 1. New balance: 1093.09
--Annual fee of 25 deducted from Account 2. New balance: 1375
--PL/SQL procedure successfully completed.


-- Scenario 3: Update the interest rate for all loans based on a new policy.

DECLARE
    CURSOR loan_cursor IS
        SELECT LoanID, LoanAmount, InterestRate
        FROM Loans
        FOR UPDATE OF InterestRate;
 
    v_new_rate Loans.InterestRate%TYPE;
BEGIN
    FOR loan_rec IN loan_cursor LOOP
        IF loan_rec.LoanAmount < 5000 THEN
            v_new_rate := loan_rec.InterestRate + 0.5;
        ELSE
            v_new_rate := loan_rec.InterestRate - 0.5;
        END IF;
 
        UPDATE Loans
        SET InterestRate = v_new_rate
        WHERE CURRENT OF loan_cursor;
 
        DBMS_OUTPUT.PUT_LINE('Loan ' || loan_rec.LoanID ||
            ': rate changed from ' || loan_rec.InterestRate ||
            '% to ' || v_new_rate || '%');
    END LOOP;
 
    COMMIT;
END;
/
--OUPUT
--Loan 1: rate changed from 5% to 4.5%
--Loan 2: rate changed from 5.94% to 5.44%
--Loan 3: rate changed from 4.5% to 5%
--PL/SQL procedure successfully completed.