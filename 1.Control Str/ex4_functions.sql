-- Exercise 4: Functions

SET SERVEROUTPUT ON;

-- Scenario 1: Calculate the age of customers for eligibility checks.

CREATE OR REPLACE FUNCTION CalculateAge (
    p_dob IN DATE
) RETURN NUMBER
AS
    v_age NUMBER;
BEGIN
    v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, p_dob) / 12);
    RETURN v_age;
END;
/
--O/P: Function CALCULATEAGE compiled

-- Scenario 2: The bank needs to compute the monthly installment for a loan.
-- EMI = P * r * (1+r)^n / ((1+r)^n - 1)
-- where P = principal, r = monthly interest rate, n = number of months.

CREATE OR REPLACE FUNCTION CalculateMonthlyInstallment (
    p_loan_amount    IN NUMBER,
    p_annual_rate    IN NUMBER,   -- e.g. 6 means 6% per year
    p_duration_years IN NUMBER
) RETURN NUMBER
AS
    v_monthly_rate NUMBER;
    v_num_months   NUMBER;
    v_emi          NUMBER;
BEGIN
    v_monthly_rate := (p_annual_rate / 100) / 12;
    v_num_months   := p_duration_years * 12;
 
    IF v_monthly_rate = 0 THEN
        -- 0% interest edge case: just divide principal evenly
        v_emi := p_loan_amount / v_num_months;
    ELSE
        v_emi := p_loan_amount * v_monthly_rate * POWER(1 + v_monthly_rate, v_num_months)
                 / (POWER(1 + v_monthly_rate, v_num_months) - 1);
    END IF;
 
    RETURN ROUND(v_emi, 2);
END;
/

--O/P: Function CALCULATEMONTHLYINSTALLMENT compiled

-- Scenario 3: Check if a customer has sufficient balance before making a transaction.

CREATE OR REPLACE FUNCTION HasSufficientBalance (
    p_account_id IN Accounts.AccountID%TYPE,
    p_amount     IN NUMBER
) RETURN BOOLEAN
AS
    v_balance Accounts.Balance%TYPE;
BEGIN
    SELECT Balance INTO v_balance
    FROM Accounts
    WHERE AccountID = p_account_id;
 
    IF v_balance >= p_amount THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
 
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE; 
END;
/

--O/P: Function HASSUFFICIENTBALANCE compiled

-- TEST CASES

BEGIN
    DBMS_OUTPUT.PUT_LINE('Age of John Doe (DOB 1985-05-15): ' ||
        CalculateAge(TO_DATE('1985-05-15', 'YYYY-MM-DD')));
END;
/
--O/P: Age of John Doe (DOB 1985-05-15): 41

BEGIN
    DBMS_OUTPUT.PUT_LINE('Monthly installment for 5000 @ 5% for 5 years: ' ||
        CalculateMonthlyInstallment(5000, 5, 5));
END;
/
--O/P: Monthly installment for 5000 @ 5% for 5 years: 94.36

BEGIN
    IF HasSufficientBalance(1, 500) THEN
        DBMS_OUTPUT.PUT_LINE('Account 1 has sufficient balance for 500.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Account 1 does NOT have sufficient balance for 500.');
    END IF;
END;
/
--O/P: Account 1 has sufficient balance for 500.

BEGIN
    IF HasSufficientBalance(1, 999999) THEN
        DBMS_OUTPUT.PUT_LINE('Account 1 has sufficient balance for 999999.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Account 1 does NOT have sufficient balance for 999999.');
    END IF;
END;
/
--O/P: Account 1 does NOT have sufficient balance for 999999.

SELECT CustomerID, Name, CalculateAge(DOB) AS Age FROM Customers;