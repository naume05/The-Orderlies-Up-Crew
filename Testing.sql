CREATE TABLE ORDERS_DATA (
    ORDER_ID NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,
    CUSTOMER_ID NUMBER,
    ORDER_DATE DATE,
    PRODUCT_CATEGORY VARCHAR2(50),
    PRODUCT_NAME VARCHAR2(100),
    QUANTITY NUMBER,
    UNITY_PRICE NUMBER,
    TOTAL_AMOUNT NUMBER
);
INSERT INTO ORDERS_DATA VALUES (101,2002, DATE '2024-01-15', 'Electronics', 'Laptop', 1, 1200, 1200);
INSERT INTO ORDERS_DATA VALUES (101,3010, DATE '2024-01-20', 'Books', 'Science Fiction Novel', 2, 15, 30);
INSERT INTO ORDERS_DATA VALUES (102,1212, DATE '2024-02-01', 'Electronics', 'Smartphone', 1, 900, 900);
INSERT INTO ORDERS_DATA VALUES (102,1210, DATE '2024-02-10', 'Clothing', 'T-Shirt', 3, 25, 75);
INSERT INTO ORDERS_DATA VALUES (103,2000, DATE '2024-01-25', 'Books', 'Mystery Thriller', 1, 18, 18);
INSERT INTO ORDERS_DATA VALUES (103,900, DATE '2024-03-05', 'Electronics', 'Headphones', 2, 150, 300);
INSERT INTO ORDERS_DATA VALUES (104,467, DATE '2024-02-15', 'Clothing', 'Jeans', 1, 60, 60);
INSERT INTO ORDERS_DATA VALUES (104,6023, DATE '2024-03-10', 'Books', 'Historical Drama', 1, 22, 22);
INSERT INTO ORDERS_DATA VALUES (101,300, DATE '2024-03-15', 'Electronics', 'Tablet', 1, 500, 500);
INSERT INTO ORDERS_DATA VALUES (102,555, DATE '2024-03-20', 'Clothing', 'Jacket', 1, 120, 120);
INSERT INTO ORDERS_DATA VALUES (103,4321, DATE '2024-04-01', 'Books', 'Fantasy Epic', 2, 25, 50);
INSERT INTO ORDERS_DATA VALUES (104,7654, DATE '2024-04-05', 'Electronics', 'Smartwatch', 1, 300, 300);
INSERT INTO ORDERS_DATA VALUES (105,986, DATE '2024-01-10', 'Electronics', 'Laptop', 1, 1200, 1200); -- Duplicate total_amount
INSERT INTO ORDERS_DATA VALUES (105,409, DATE '2024-02-20', 'Books', 'Cookbook', 1, 20, 20);
INSERT INTO ORDERS_DATA VALUES (105, 1213,DATE '2024-03-25', 'Clothing', 'Dress', 1, 80, 80);


COMPARING VALUES
SELECT
    ORDER_ID,
    ORDER_DATE,
    TOTAL_AMOUNT,
    LAG(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) AS previous_amount,
    LEAD(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) AS next_amount,
    CASE
        WHEN TOTAL_AMOUNT > LAG(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'HIGHER'
        WHEN TOTAL_AMOUNT < LAG(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'LOWER'
        WHEN TOTAL_AMOUNT = LAG(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'EQUAL'
        ELSE 'FIRST RECORD'
    END AS compared_to_previous,
    CASE
        WHEN TOTAL_AMOUNT > LEAD(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'HIGHER'
        WHEN TOTAL_AMOUNT < LEAD(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'LOWER'
        WHEN TOTAL_AMOUNT = LEAD(TOTAL_AMOUNT, 1, NULL) OVER (ORDER BY ORDER_DATE) THEN 'EQUAL'
        ELSE 'LAST RECORD'
    END AS compared_to_next
FROM
    ORDERS_DATA
ORDER BY
    ORDER_DATE;
    
    
    #Ranking
    SELECT
    ORDER_ID,
    PRODUCT_CATEGORY,
    TOTAL_AMOUNT,
    RANK() OVER (PARTITION BY PRODUCT_CATEGORY ORDER BY TOTAL_AMOUNT DESC) AS category_rank,
    DENSE_RANK() OVER (PARTITION BY PRODUCT_CATEGORY ORDER BY TOTAL_AMOUNT DESC) AS category_dense_rank
FROM
    ORDERS_DATA
ORDER BY
    PRODUCT_CATEGORY, category_rank;
    
    
    #Identifying top records
    SELECT
    ORDER_ID,
    PRODUCT_CATEGORY,
    PRODUCT_NAME,
    TOTAL_AMOUNT,
    category_rank
FROM (
    SELECT
        ORDER_ID,
        PRODUCT_CATEGORY,
        PRODUCT_NAME,
        TOTAL_AMOUNT,
        RANK() OVER (PARTITION BY PRODUCT_CATEGORY ORDER BY TOTAL_AMOUNT DESC) AS category_rank
    FROM
        ORDERS_DATA
)
WHERE
    category_rank <= 3
ORDER BY
    PRODUCT_CATEGORY, category_rank;
    
    
    #Finding the earliest Records
    SELECT
    ORDER_ID,
    PRODUCT_CATEGORY,
    ORDER_DATE,
    PRODUCT_NAME,
    category_order_rank
FROM (
    SELECT
        ORDER_ID,
        PRODUCT_CATEGORY,
        ORDER_DATE,
       PRODUCT_NAME,
        RANK() OVER (PARTITION BY PRODUCT_CATEGORY ORDER BY ORDER_DATE ASC) AS category_order_rank
    FROM
        ORDERS_DATA
)
WHERE
    category_order_rank <= 2
ORDER BY
    PRODUCT_CATEGORY, category_order_rank;
    
    
    #Aggregation
    SELECT
    ORDER_ID,
    PRODUCT_CATEGORY,
    TOTAL_AMOUNT,
    MAX(TOTAL_AMOUNT) OVER (PARTITION BY PRODUCT_CATEGORY) AS max_category_amount,
    MAX(TOTAL_AMOUNT) OVER () AS overall_max_amount
FROM
    ORDERS_DATA
ORDER BY
    ORDER_ID;