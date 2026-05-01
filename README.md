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
   1. Orders volume: 2500000 records with defined status distribution

   Colons can be used to align columns.
   
   | Query         | Before (Seq Scan)         | After (Partition + Index  |
   | ------------- |:-------------------------:| -------------------------|
   | col 3 is      | 241.234 ms                | 200 ms |
   | col 2 is      | centered                  |   $12 |
   | zebra stripes | are neat                  |    $1 |
   
   There must be at least 3 dashes separating each header cell.
   The outer pipes (|) are optional, and you don't need to make the 
   raw Markdown line up prettily. You can also use inline Markdown.
   
   Markdown | Less | Pretty
   --- | --- | ---
   *Still* | `renders` | **nicely**
   1 | 2 | 3
      
## ⭐ Features
- Asynchronous API requests
- JSON data export
- Error handling and logging
- Detail project's description: https://www.notion.so/Project-2-30fdcb66205b80d3a523d99b8ea08b45

## SUPERVISOR for Request Programming
- Check this link: https://www.notion.so/Supervisor-on-Ubuntu-316dcb66205b807da38aebe7549dbafb?source=copy_link
