WITH cte_sales_amounts (staff, sales, year) 
AS (
SELECT  first_name + '  ' + last_name, 
SUM(quantity * list_price * (1 - discount)),  YEAR (order_date)
FROM    sales.orders o    INNER JOIN sales.order_items i
ON i.order_id = o.order_id   
INNER JOIN sales.staffs s ON s.staff_id = o.staff_id
GROUP BY         
first_name + '  ' + last_name,   year (order_date))    
SELECT    staff, sales 
FROM    cte_sales_amounts
WHERE  year = 2018;
-------------------------------------------------------------------------------------
WITH cte_category_counts ( category_id, category_name, product_count)
AS 
(
SELECT 
c.category_id, c.category_name, COUNT(p.product_id)
FROM  production.products p   INNER JOIN production.categories c   
ON c.category_id = p.category_id
INNER JOIN production.categories 
ON c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
),

cte_category_sales(category_id, sales)
AS
(
    SELECT p.category_id,
           SUM(i.quantity * i.list_price * (1 - i.discount))
    FROM sales.order_items i
    INNER JOIN production.products p
        ON p.product_id = i.product_id
    INNER JOIN sales.orders o
        ON o.order_id = i.order_id
    WHERE order_status = 4
    GROUP BY p.category_id
)

SELECT  c.category_id, c.category_name,  c.product_count,  s.sales
FROM cte_category_counts c INNER JOIN cte_category_sales s
ON s.category_id = c.category_id
ORDER BY c.category_name;


--------------------Assignment------------------------------------------------------------------------

/* Problem 1: Identifying Above-Average Revenue Orders
Scenario: The finance team wants to identify high-performing orders. An order is considered "high-performing" 
if its total net revenue is greater than the average net revenue across all orders in the store.

Task:
Using CTEs:

First CTE: Calculate the total net revenue SUM(quantity * list_price * (1 - discount)) for each order_id.
Second CTE: Calculate the average net revenue per order across the entire store.

Main Query: Join or filter using the CTEs to return all order_id values and their revenue where the order revenue 
exceeds the overall average order revenue. */

with cte_total_net_revenue
as
(
select order_id, sum(quantity * list_price * (1 - discount)) as total_net_revenue from sales.order_items
group by order_id
),
cte_average_revenue
as(
select order_id, AVG(quantity * list_price * (1 - discount)) as average_net_revenue from sales.order_items
group by order_id
)
select t.order_id, t.total_net_revenue 
from  cte_total_net_revenue as t 
join cte_average_revenue as a 
on t.order_id = a.order_id
where t.total_net_revenue > a.average_net_revenue 
group by t.order_id,t.total_net_revenue;

/* Problem 2: Category Rank of Most Discounted Line Items
Scenario: Sales managers want to rank the individual items within each order based on the discount 
percentage given, and then filter for only the most heavily discounted items.

Task:
Using a CTE:

Write a CTE that calculates the net line price (quantity * list_price * (1 - discount)) and uses a 
window function (DENSE_RANK() or ROW_NUMBER()) partitioned by order_id and ordered by discount DESC 
to assign a discount rank to each line item.

Main Query: Select from the CTE to retrieve all order_id, item_id, product_id, discount, and net price 
where the discount rank is 1 (the top discounted item(s) per order). */
with cte_max_discount 
as
(
select order_id,item_id, product_id, discount, 
(quantity * list_price * (1 - discount)) as net_price, 
DENSE_RANK() over(partition by order_id
order by discount desc) as discount_rank
from sales.order_items
)
select md.order_id, md.item_id, md.product_id,md.discount, md.net_price,md.discount_rank from cte_max_discount as md
where md.discount_rank = 1;



