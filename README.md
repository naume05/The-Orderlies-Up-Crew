```SQL
# The-Orderlies-Up-Crew
```

#  PL/SQL Window Functions Assignment

## Introduction:

**Our Project Information**

**1. Names:  Derrick Niyuhire ID: 25243**
**2. Names: Naume Murungi   ID: 26334**
---

## Objective
This project demonstrates the use of **SQL Window Functions** on a generic orders dataset using Oracle PL/SQL. The functions used include:

- `LAG()`, `LEAD()` – for comparing current rows with previous/next.
- `RANK()`, `DENSE_RANK()`, `ROW_NUMBER()` – for ordering and ranking within groups.
- Aggregate functions like `MAX()` – with and without `PARTITION BY`.

---

## 🗂️ Dataset Used

### `ORDERS_DATA`

```sql
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


![OrdersTable](https://github.com/user-attachments/assets/adc67ebc-9ba4-4632-8a28-bd4688342db1)

![OrdersDataTable](https://github.com/user-attachments/assets/04aca950-c5d5-41ac-ba2c-72e373ccfcb0)

1.comparison
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

Explanation: 
LAG(): This window function retrieves the total_amount from the previous row within the result set, ordered by order_date.
Explanation:
LEAD(): This window function retrieves the total_amount from the next row within the result set, ordered by order_date

![Comparison](https://github.com/user-attachments/assets/aa09d02c-a9a2-4a01-a89e-53aef6b9b9a7)

2. Ranking
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

Explanation:
RANK() OVER (PARTITION BY product_category ORDER BY total_amount DESC): This window function assigns a rank to each row within each product_category based on the total_amount in descending order (highest amount gets rank 1). If there are ties (same total_amount), they receive the same rank, and the next rank is skipped

DENSE_RANK() OVER (PARTITION BY product_category ORDER BY total_amount DESC): This window function also assigns a rank to each row within each product_category based on the total_amount in descending order. However, unlike RANK(), when there are ties, DENSE_RANK() assigns the same rank, and the next rank is consecutive (no ranks are skipped)

![Ranking](https://github.com/user-attachments/assets/823f7c1c-39ec-4772-927d-2608553852ab)




3.Identifying Top Records
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

Explanation:
1.Inner Query: We first use a subquery to calculate the rank of each order within its product_category based on the total_amount in descending order, using the RANK() function. This handles duplicate total_amount values by assigning them the same rank
2.Outer Query: The outer query then selects the orders where the category_rank is less than or equal to 3. This effectively retrieves the top 3 orders based on total_amount within each product_category.

![Test runs5](./RankFunction.jpg)


4.SELECT
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

Explanation:
1. Inner Query: We use a subquery to calculate the rank of each order within its product_category based on the order_date in ascending order (earliest date gets rank 1). We use RANK() here as well to handle potential ties in the earliest order dates
Used to get the earliest employees, sales, etc.
2. Outer Query: The outer query selects the orders where the category_order_rank is less than or equal to 2. This retrieves the first two orders based on the order_date within each product_category


![Test runs6](./RowNumberFunction.jpg)
5.SELECT
    ORDER_ID,
    PRODUCT_CATEGORY,
    TOTAL_AMOUNT,
    MAX(TOTAL_AMOUNT) OVER (PARTITION BY PRODUCT_CATEGORY) AS max_category_amount,
    MAX(TOTAL_AMOUNT) OVER () AS overall_max_amount
FROM
    ORDERS_DATA
ORDER BY
    ORDER_ID;

Explanation
MAX(total_amount) OVER (PARTITION BY product_category): This window function calculates the maximum total_amount within each product_category.

MAX(total_amount): The aggregate function to calculate the maximum value of the total_amount column.

OVER (PARTITION BY product_category): Specifies that the aggregation should be performed separately for each unique value in the product_category column.

MAX(total_amount) OVER (): This window function calculates the overall maximum total_amount across all rows in the orders_data table.

MAX(total_amount): The aggregate function.

OVER (): An empty OVER() clause indicates that the aggregation should be performed over the entire result set

![Test runs7](./AggregateFunction.jpg)

## Findings
Based on the data, there's a strong indication that the "Laptop" consistently represents a high-value transaction for the business, evidenced by its appearance as the highest single order. Furthermore, the early adoption of "Laptop" and "Science Fiction Novel" suggests initial customer interest in the Electronics and Books categories, respectively.

## Conclusion
The application of window functions effectively illuminated key aspects of the order data, including peak transactions and the commencement of product sales within categories. This detailed analysis provides valuable intelligence for strategic business decisions and a deeper understanding of sales performance.
________________________________________




**Repository:** [https://github.com/naume05/The-Orderlies-Up-Crew/edit/main/README.md]
