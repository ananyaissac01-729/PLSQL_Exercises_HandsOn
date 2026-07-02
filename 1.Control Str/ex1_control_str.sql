SET SERVEROUTPUT ON;

-- Scenario 1: The bank wants to apply a discount to loan interest rates for customers above 60 years old.

DECLARE
    v_age NUMBER;
BEGIN
    FOR cust_rec IN (SELECT CustomerID, DOB FROM Customers) LOOP
        v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, cust_rec.DOB) / 12);

        IF v_age > 60 THEN
            UPDATE Loans
            SET InterestRate = InterestRate - (InterestRate * 0.01)
            WHERE CustomerID = cust_rec.CustomerID;

            DBMS_OUTPUT.PUT_LINE('Discount applied for Customer ID: '
                || cust_rec.CustomerID || ' (Age: ' || v_age || ')');
        END IF;
    END LOOP;

    COMMIT;
END;
/

-- OUTPUT : 
-- Discount applied for Customer ID: 3 (Age: 71)
-- Discount applied for Customer ID: 4 (Age: 67)
--PL/SQL procedure successfully completed.


-- Scenario 2: A customer can be promoted to VIP status based on their balance.
BEGIN
    FOR cust_rec IN (SELECT CustomerID, Balance FROM Customers) LOOP
        IF cust_rec.Balance > 10000 THEN
            UPDATE Customers
            SET IsVIP = 'TRUE'
            WHERE CustomerID = cust_rec.CustomerID;

            DBMS_OUTPUT.PUT_LINE('Customer ' || cust_rec.CustomerID || ' promoted to VIP.');
        END IF;
    END LOOP;

    COMMIT;
END;
/
-- OUTPUT
-- Customer 3 promoted to VIP.
-- PL/SQL procedure successfully completed.

--Scenario 3: The bank wants to send reminders to customers whose loans are due within the next 30 days.

BEGIN
    FOR loan_rec IN (
        SELECT l.LoanID, l.CustomerID, c.Name, l.EndDate
        FROM Loans l
        JOIN Customers c ON l.CustomerID = c.CustomerID
        WHERE l.EndDate BETWEEN SYSDATE AND SYSDATE + 30
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Reminder: ' || loan_rec.Name ||
            ', your loan (ID: ' || loan_rec.LoanID ||
            ') is due on ' || TO_CHAR(loan_rec.EndDate, 'DD-MON-YYYY')
        );
    END LOOP;
END;
/

-- OUTPUT
-- Reminder: Jane Smith, your loan (ID: 3) is due on 17-JUL-2026
-- PL/SQL procedure successfully completed.