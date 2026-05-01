use dannys_dinner;
select * from sales;

-- 1) What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) from sales s join menu m on s.product_id = m.product_id group by customer_id;

-- 2) How many days has each customer visited the restaurant?
select customer_id , count(distinct order_date) from sales group by customer_id;

-- 3) First item purchased by each customer
select customer_id, product_name, ranks from
(select s.customer_id, m.product_name, dense_rank() over(partition by customer_id order by order_date) as ranks from sales as s join menu as m using (product_id)) t
 where ranks = 1;

-- 4) What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, max from (select product_name,count(*) as max, row_number() over(order by count(*) desc) as yes
from menu join sales using (product_id) group by product_name)t where yes = 1;

-- 5) Which item was the most popular for each customer?
select customer_id, product_name, order_count
from (select s.customer_id,m.product_name,COUNT(*) AS order_count, rank() over (partition by s.customer_id order by  COUNT(*) desc) as rnk
from sales s
join menu m using (product_id)
group by s.customer_id, m.product_name) t
where rnk = 1;


-- 6)Which item was purchased first by the customer after they became a member?
select customer_id, product_name, order_date from
(select customer_id, product_name, order_date, dense_rank() over(partition by customer_id order by order_date) as dates from sales as s  
join members as m on customer_id = c_id 
join menu as mem using (product_id)
where order_date>= join_date)t where dates = 1;

-- 7) Which item was purchased just before the customer became a member?
select customer_id, product_name, order_date from
(select customer_id, product_name, order_date, dense_rank() over(partition by customer_id order by order_date) as dates from sales as s  
join members as m on customer_id = c_id 
join menu as mem using (product_id)
where order_date<= join_date)t where dates = 1;

-- 8) What is the total items and amount spent for each member before they became a member?
select customer_id, count(*) from sales join members on customer_id = c_id join menu 
using (product_id) where order_date < join_date group by customer_id;

-- 9)If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id,sum(case when m.product_name = 'sushi' then m.price * 20
else m.price * 10 end) as points
from sales s
join menu m using (product_id)
group by s.customer_id;
