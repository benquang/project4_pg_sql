/* II. Optimization techniques*/
/* Part 1*/

/*1. Total revenue per month*/
explain analyze
select date_trunc('month', order_date) as month,
		sum(total_amount) as revenue
from orders
group by date_trunc('month', order_date)
order by month;

/*2. Orders filtered by seller and date*/
select order_id, order_date, total_amount
from orders
where seller_id = 1025 and order_date between '2025-08-01' AND '2025-10-31'
order by order_date;

/*3. Filter data in order_item by product_id*/
select * 
from order_item
where product_id = 20005

/*4. Find order with highest total_amount*/
select *
from orders
order by total_amount DESC
limit 1

/*5. List products with highest quantity sold*/
select product_id, sum(quantity) as total_quantity_sold
from order_item
group by product_id
order by total_quantity_sold
limit 1

/*6. Orders by Seller in October*/
select seller_id, count(order_id) as total_orders
from orders
where order_date >= '2025-10-01' AND order_date <= '2025-10-31'
group by seller_id
order by total_orders DESC

/*7. Revenue per Product per Month*/
select date_trunc('month', order_date) as month, 
		oi.product_id,
		sum(oi.subtotal) as revenue
from orders o
join order_item oi on o.order_id = oi.order_id
group by month, oi.product_id
order by month, revenue DESC

/*8. Products Sold per Seller*/
select o.seller_id, 
		oi.product_id,
		sum(oi.quantity) as total_sold
from orders o
join order_item oi on o.order_id = oi.order_id
group by o.seller_id, oi.product_id
order by o.seller_id, total_sold DESC


