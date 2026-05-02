# Synthetic Ecommerce Orders Data - SQL Project

## 📖 Overview
This project focuses on creating synthetic transactional data for two main tables Orders & Order_Item with data requirements.

## 📋 Requirements
- PostgreSQL 17.9 +
- `pgAdmin 4` as management tool

## 🚀 Usage
Run the .py file for each method using for fetching Tiki product data (aiohttp & requests):
```bash
python src/aiohttp_method.py
```

## 📊 Check data requirements
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

## 📊 Optimization compare
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
   
      
## ⭐ Features
- Asynchronous API requests
- JSON data export
- Error handling and logging
- Detail project's description: https://www.notion.so/Project-2-30fdcb66205b80d3a523d99b8ea08b45

## SUPERVISOR for Request Programming
- Check this link: https://www.notion.so/Supervisor-on-Ubuntu-316dcb66205b807da38aebe7549dbafb?source=copy_link
