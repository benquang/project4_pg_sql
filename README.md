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
   1. Orders volume: 2500000 records
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

   2. Execution time for each method:
      So we have a 200 STATUS response for getting product successfully, with ~100 products/2 minutes so the estimated execution time is about 66 hours.
      ```
        [OK] GET JSON successfully for product 1391347
        [OK] GET JSON successfully for product 74897599
        [OK] GET JSON successfully for product 154155413
        [OK] GET JSON successfully for product 253117062
      ```

      The exection time for aiohttp + asyncio method is about 90 minutes, this is numbers of ERROR products:
      ```
      Numbers of ERROR products: 9456
      ERROR Catgeory:
      - HTTP 404: 6638
      - HTTP 429: 2810
      - 'NoneType' object is not iterable: 8
      ```
   3. Execution again for 429 & 404 ERROR products and save to CSV list of product ids:
      We retry for list of 429 ERROR products and get more sucessfully products (2698/2810 [OK]). For list of 404 ERROR products (with retry request 5 times and 1 second sleep time), we found that all of them are NOT FOUND product from Tiki API, so from 200000 unique product ids, we get:
       ```
      Total of GET successfully products: 193242 
      Numbers of ERROR products: 6758
      - HTTP 404: 6750
      - 'NoneType' object is not iterable: 8 (the image information is NULL, we can ignore this or check again to get them)
      ```

## ⭐ Features
- Asynchronous API requests
- JSON data export
- Error handling and logging
- Detail project's description: https://www.notion.so/Project-2-30fdcb66205b80d3a523d99b8ea08b45

## SUPERVISOR for Request Programming
- Check this link: https://www.notion.so/Supervisor-on-Ubuntu-316dcb66205b807da38aebe7549dbafb?source=copy_link
