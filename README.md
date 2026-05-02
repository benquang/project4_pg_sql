# Synthetic Ecommerce Orders Data - SQL Project

## 📖 Overview
This project focuses on creating synthetic transactional data for two main tables Orders & Order_Item with data requirements.

## 📋 Requirements
- PostgreSQL 17.9 +
- `pgAdmin 4` as management tool

## 🚀 Usage
- Open `pgadmin 4`, create a database (eg: lab3_ecommerce_db) then execute the `initial_sql_schemas` script for first necessary data.
- In [/scripts](https://github.com/benquang/project4_pg_sql/tree/main/scripts), run from task 1 to 3 (each task has multiple parts) to following project's requirements.

## 📄 Check data requirements
   1. Orders volume: 2500000 records with defined status distribution
      ```
      WITH status_pool AS (
          SELECT 'PLACED' AS status FROM generate_series(1, 5000*25)  -- 5%
          UNION ALL
          SELECT 'PAID' FROM generate_series(1, 4000*25)              -- 4%
          UNION ALL
          SELECT 'DELIVERED' FROM generate_series(1, 70000*25)        -- 70%
          UNION ALL
          SELECT 'SHIPPED' FROM generate_series(1, 11000*25)          -- 11%
          UNION ALL
          SELECT 'CANCELLED' FROM generate_series(1, 7000*25)         -- 7%
          UNION ALL
          SELECT 'RETURNED' FROM generate_series(1, 3000*25)          -- 3%
      )
      ```

   2. Order items: each product must belong to the same `seller_id` as the order
      
      and randomly selected from product table:
      ```
        WHERE pr2.seller_id = o.seller_id
        ...
        LIMIT (3 + floor(random() * 2))  -- random 3 to 4 products
      ```

      `order_date` value constraint:
      ```
      DATE '2025-08-01'
        + (floor(random() * (DATE '2025-10-31' - DATE '2025-08-01'))) * interval '1 day' AS order_date,
      ```

## ↔️ Optimization compare
   Work with 2500000 records Orders & 8749358 records Order_item in this project, for task3 we have the biggest different runtime excution.
   
   | Query         | Before (Seq Scan)         | After (Partition + Index)  |
   | ------------- |:-------------------------:| -------------------------|
   | 1. Total revenue per month      | 241 ms                | 201 ms |
   | 2. Orders filtered by seller and date     | 106 ms                  |   105 ms |
   | 3. Filter data in order_item by `product_id` | 168 ms                  |    3.5 ms |
   | 4. Find order with highest total_amount | 130 ms                  |    130 ms |
   | 5. List products with highest quantity sold | 500 ms                  |    450 ms |
   | 6. Orders by Seller in October | 140 ms                  |    140 ms |
   | 7. Revenue per Product per Month | 2500 ms                  |    2400 ms |
   | 8. Products Sold per Seller | 1900 ms                  |    1850 ms |
   
## 📊 Dynamic Reports
   1. Monthly Revenue report
      |date|total_orders|total_quantity|total_revenue|
      | --- | --- | --- | --- |
      | 2025-08-01 | 141 | 435 | 10147015168.00 |
      | 2025-08-02 | 137 | 372 | 7914431693.00 | 
      | 2025-08-03 | 126 | 378 | 8028256551.00 |
      
   2. Daily revenue report
      |month|total_orders|total_quantity|total_revenue|
      | --- | --- | --- | --- |
      | 2025-08-01 | 853332 | 8957900 | 229224645904692.00 |
      | 2025-09-01 | 824522 | 8657339 | 221570271807835.00 | 
      | 2025-10-01 | 822146 | 8630622 | 220820438260984.00 |

   3. Seller Performance report
      |seller_id|seller_name|total_orders|total_quantity|total_revenue|
      | --- | --- | --- | --- | --- |
      | 1001 | Sanchez LLC | 11941 | 40527 | 1160080434815.00 |
      | 1016 | Gordon Ltd | 11285 | 38354 | 1110404024906.00 |
      | 1003 | Baker-Carpenter | 8913 | 29383 | 1048304356695.00 |

   4. Top Products per Brand report
      |brand_id|brand_name|product_id|product_name|total_quantity|total_revenue|
      | --- | --- | --- | --- | --- | --- |
      | 1 | Turner-Morris | 21682 | Programmable maximized installation | 14807 | 96595048849.00 |
      | 1 | Turner-Morris | 20992 | Enterprise-wide disintermediate application | 14491 | 294817163386.00 |
      | 2 | Winters Inc | 20648 | Grass-roots bi-directional frame | 14702 | 156011272736.00 |

   5. Top Products per Brand report
      |status|total_orders|total_revenue|
      | --- | --- | --- |
      | CANCELLED | 97023 | 34828514483853.00 |
      | DELIVERED | 969502 | 347927555179480.00 |
      | PAID | 55449| 19865211339635.00 |
      | PLACED | 69258 | 24883414292837.00 |
      | RETURNED | 41404 | 14876510701876.00 |
      | SHIPPED | 151865| 54447941428709.00 |
            
## ⭐ Features
- Generating data using SQL
- PostgreSQL table partitions, index
- Business-revelant reports
