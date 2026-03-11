-- ============================================================
-- Package Sorting UDF
-- Returns: 'STANDARD', 'SPECIAL', or 'REJECTED'
-- ============================================================
CREATE OR REPLACE FUNCTION SORT(WIDTH FLOAT, HEIGHT FLOAT, LENGTH FLOAT, MASS FLOAT)
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
    CASE
        WHEN (WIDTH * HEIGHT * LENGTH >= 1000000 OR WIDTH >= 150 OR HEIGHT >= 150 OR LENGTH >= 150)
             AND MASS >= 20
            THEN 'REJECTED'
        WHEN (WIDTH * HEIGHT * LENGTH >= 1000000 OR WIDTH >= 150 OR HEIGHT >= 150 OR LENGTH >= 150)
             OR MASS >= 20
            THEN 'SPECIAL'
        ELSE 'STANDARD'
    END
$$;


-- ============================================================
-- Test Cases
-- ============================================================

-- Standard: normal package
SELECT SORT(10, 10, 10, 5) AS RESULT;          -- Expected: STANDARD

-- Bulky: volume >= 1,000,000
SELECT SORT(100, 100, 100, 5) AS RESULT;       -- Expected: SPECIAL

-- Heavy: mass >= 20
SELECT SORT(10, 10, 10, 20) AS RESULT;         -- Expected: SPECIAL

-- Bulky by dimension: one side >= 150cm
SELECT SORT(150, 10, 10, 5) AS RESULT;         -- Expected: SPECIAL

-- Rejected: both bulky (volume) and heavy
SELECT SORT(100, 100, 100, 20) AS RESULT;      -- Expected: REJECTED

-- Rejected: both bulky (dimension) and heavy
SELECT SORT(150, 10, 10, 25) AS RESULT;        -- Expected: REJECTED

-- EdgeCase: volume exactly 1,000,000 (boundary)
SELECT SORT(100, 100, 100, 5) AS RESULT;       -- Expected: SPECIAL

-- EdgeCase: mass exactly 20 (boundary)
SELECT SORT(10, 10, 10, 20) AS RESULT;         -- Expected: SPECIAL

-- EdgeCase: dimension exactly 150 (boundary)
SELECT SORT(150, 1, 1, 1) AS RESULT;           -- Expected: SPECIAL

-- Batch test using VALUES
SELECT
    WIDTH, HEIGHT, LENGTH, MASS,
    SORT(WIDTH, HEIGHT, LENGTH, MASS) AS STACK
FROM (VALUES
    (10,  10,  10,  5),    -- STANDARD
    (100, 100, 100, 5),    -- SPECIAL  (bulky volume)
    (10,  10,  10, 20),    -- SPECIAL  (heavy)
    (150, 10,  10,  5),    -- SPECIAL  (bulky dimension)
    (100, 100, 100, 20),   -- REJECTED (bulky + heavy)
    (150, 10,  10, 25),    -- REJECTED (bulky dimension + heavy)
    (100, 100, 100, 19),   -- SPECIAL  (bulky, just under heavy)
    (99,  99,  99, 20)     -- SPECIAL  (just under bulky volume, heavy)
) AS BATCH_TEST(WIDTH, HEIGHT, LENGTH, MASS);

-- BATCH TEST VIA a CTE
WITH BATCH_TEST AS (
    SELECT $1 AS WIDTH, $2 AS HEIGHT, $3 AS LENGTH, $4 AS MASS
    FROM VALUES
        (10,  10,  10,  5),    -- STANDARD
    (100, 100, 100, 5),    -- SPECIAL  (bulky volume)
    (10,  10,  10, 20),    -- SPECIAL  (heavy)
    (150, 10,  10,  5),    -- SPECIAL  (bulky dimension)
    (100, 100, 100, 20),   -- REJECTED (bulky + heavy)
    (150, 10,  10, 25),    -- REJECTED (bulky dimension + heavy)
    (100, 100, 100, 19),   -- SPECIAL  (bulky, just under heavy)
    (99,  99,  99, 20)     -- SPECIAL  (just under bulky volume, heavy)
)
SELECT * FROM BATCH_TEST;
