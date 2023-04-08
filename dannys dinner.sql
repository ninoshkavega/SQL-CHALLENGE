CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

 -- 1.	What is the total amount each customer spent at the restaurant?

 -- Unir tablas con inner join
 Select customer_id, sum(price) as total_spent
 From Sales as S 
 Inner Join menu as M 
 on S.product_id = M.product_id
 group by customer_id

 -- How many days has each customer visited the restaurant?

 select customer_id, count(distinct(order_date)) as Days 
 from sales 
 group by customer_id

 -- 3.	What was the first item from the menu purchased by each customer?

 WITH CTE AS (
  SELECT customer_id, order_Date, product_name,
         RANK() OVER(PARTITION BY customer_id ORDER BY order_Date ASC) AS RNK
  FROM Sales AS S
  INNER JOIN menu AS M ON S.product_id = M.product_id
)
SELECT customer_id, product_name
FROM CTE
where RNK = 1



 --- aqui se esta haciendo un ranking dentro de cada particion para saber cual fue el primer item comprado x cada cliente.

 -- 4.	What is the most purchased item on the menu and how many times was it purchased by all customers?

 Select TOP 1 count(product_name) as quantity , product_name
 From Sales as S 
 Inner Join menu as M 
 on S.product_id = M.product_id 
 group by product_name
 order by quantity desc
   
   -- now we know ramen is the most purchased product, next we need to know how many times it was purchased by each customer

 Select customer_id, product_name, count(product_name) as quantity
 From Sales as S 
 Inner Join menu as M 
 on S.product_id = M.product_id 
  where product_name like '%ramen%'
 group by product_name, customer_id

 -- 5.	Which item was the most popular for each customer?

WITH CTE AS (
  SELECT 
    product_name, 
    customer_id, 
    COUNT(order_date) as orders, -- aqui estamos contabilizando la cantidad de ordenes --
    RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rnk, -- aqui vamos a rankear las ordenes por cliente,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY COUNT(order_date) DESC) as rn
  FROM 
    SALES as S
    INNER JOIN MENU as M on S.product_id = M.product_id 
  GROUP BY 
    product_name, 
    customer_id
)
SELECT 
  customer_id,
  product_name
FROM 
  CTE
WHERE rnk = 1; -- aqui estamos seleccionando la orden mas popular -- 


-- 6.	Which item was purchased first by the customer after they became a member?
WITH CTE_RANKING AS (
Select s.customer_id, join_date, order_date, product_name,
RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) as rnk
From Sales as S 
 Inner Join members as Mem  on S.customer_id = mem.customer_id 
 join menu as m on S.product_id = m.product_id
   WHERE 
    order_date >= join_date
 ) 
SELECT 
  customer_id,
  product_name
FROM 
  CTE_RANKING
WHERE rnk = 1; 

-- 7.	Which item was purchased just before the customer became a member?

WITH CTE_RANKING2 AS (
Select s.customer_id, join_date, order_date, product_name,
RANK() OVER(PARTITION BY S.customer_id ORDER BY order_date ASC) as rnk
From Sales as S 
 Inner Join members as Mem  on S.customer_id = mem.customer_id 
 join menu as m on S.product_id = m.product_id
   WHERE 
    order_date<join_date
 ) 
SELECT 
  customer_id,
  product_name
FROM 
  CTE_RANKING2
WHERE rnk = 1; 

-- 8.	What is the total items and amount spent for each member before they became a member?

 Select s.customer_id, count(product_name) as cantidad_productos, sum(price) as total_gastado
 From Sales as S 
Inner Join members as Mem  on S.customer_id = mem.customer_id 
join menu as m on S.product_id = m.product_id
   WHERE 
    order_date<join_date
 group by s.customer_id

 --9.	If each $1 spent equates to 10 points
 -- and sushi has a 2x points multiplier - how many points would each customer have?
 -- prumero vamos saber la catidad de puntos por precio
 select 
customer_id, 
 sum(CASE
 when product_name = 'sushi' then price * 10 * 2
 else price *10
 END) as Total_Points
From Sales as S 
 Inner Join menu as M  on S.product_id = m.product_id 
 group by customer_id

-- 10. 

Select * From Sales as S 
Inner Join members as Mem  on S.customer_id = mem.customer_id 
join menu as m on S.product_id = m.product_id

 select 
s.customer_id, 
 sum(CASE
 when order_date between mem.join_date and DATEADD([Day],6,mem.join_date) then price *10*2 -- esta linea aplica la oferta
 when product_name = 'sushi' then price * 10 * 2 -- esta linea indica los puntos obtenidos normalmente
 else price *10
 END) as Total_Points
 From Sales as S 
Inner Join members as Mem  on S.customer_id = mem.customer_id 
inner join menu as m on S.product_id = m.product_id -- hasta aqui tenemos la cantidad total de punto, sin embargo se nos pide la cantidad total del primer mes
WHERE  -- por lo cual debemos filtrar con where
  DATEADD([month], DATEDIFF([month], 0, S.order_date), 0) = '2021-01-01'
GROUP BY 
  S.customer_id

--how many points customer will have at the end of january 
