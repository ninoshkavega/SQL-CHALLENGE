-- A. PART A: PIZZA METRICS 
--- STUDY CASE QUESTION 
--How many pizzas were ordered?
--How many unique customer orders were made?
--How many successful orders were delivered by each runner?
--How many of each type of pizza was delivered?
--How many Vegetarian and Meatlovers were ordered by each customer?
--What was the maximum number of pizzas delivered in a single order?
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--How many pizzas were delivered that had both exclusions and extras?
--What was the total volume of pizzas ordered for each hour of the day?
--What was the volume of orders for each day of the week?

-- How many pizzas were ordered?
SELECT COUNT(*) AS 'TOTAL DE ORDENES' FROM PortfolioProject..customer_orders

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS 'ORDENES UNICAS POR CLIENTES' FROM customer_orders 

-- How many successful orders were delivered by each runner?
-- Para resolver esta pregunta podemos hacer un filtrado utilizando la columna
-- pickup time 
SELECT runner_id, count(distinct(ro.order_id)) as 'Ordenes por Runner' FROM customer_orders as CO
 Inner Join runner_orders as RO
 on CO.order_id = RO.order_id 
 WHERE pickup_time <> 'null'
 group by runner_id

 --How many of each type of pizza was delivered?
 select pizza_id, count(co.order_id) as 'ordenes'
 FROM customer_orders as CO
 Inner Join runner_orders as RO
 on CO.order_id = RO.order_id 
 WHERE pickup_time <> 'null'
 group by pizza_id

 -- How many Vegetarian and Meatlovers were ordered by each customer?
 select cast(pn.pizza_name as varchar(max)) as 'pizza_name', co.customer_id,
 count(co.order_id) as 'pizza ordered'
 FROM 
  customer_orders as co 
  INNER JOIN pizza_names as pn on co.pizza_id = pn.pizza_id 
  GROUP BY 
 CAST(pn.pizza_name AS varchar(max)), customer_id;
 -- aqui tuvimos que utilizar lafuncion cast para convertir el tipo de 
 -- dato de pizza name a uno compatible con la operacion 

 -- What was the maximum number of pizzas delivered in a single order?
 select top 1 co.order_id, count(pizza_id)  as 'cantidad ordenada'
 from customer_orders as co
INNER JOIN runner_orders as ro on co.order_id = ro.order_id 
where pickup_time <> 'null'
 group by co.order_id
 order by count(pizza_id) desc
 -- anotacion: contamos la cantidad de pizza por orden

 --For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

  SELECT co.customer_id,
       SUM(CASE 
          WHEN (exclusions IS NOT NULL AND exclusions <> 'null' AND LEN(exclusions) > 0)
               OR (extras IS NOT NULL AND extras <> 'null' AND LEN(extras) > 0)
          THEN 1 
          ELSE 0 
       END) AS 'changes', -- en esta primera parte establecimos las condiciones que indica que hubieron cambios, en este caso todas aquellas donde no hay null 
	   -- y el valor es mayor a 0 en ambas columnas exclusions y extras, indica entonces que hubo cambios. 
	   -- a continuacion establecemos las mismas condciones pero al reves, para indicar que no hubo cambios. 
	    SUM(CASE 
          WHEN (exclusions IS NOT NULL AND exclusions <> 'null' AND LEN(exclusions) > 0)
               OR (extras IS NOT NULL AND extras <> 'null' AND LEN(extras) > 0) 
          THEN 0
          ELSE 1 
       END) AS 'NO changes'
FROM customer_orders AS co 
INNER JOIN runner_orders AS ro ON co.order_id = ro.order_id
WHERE pickup_time <> 'null' -- PARA FILTRAR LOS QUE NO DICEN NULL FUERON CANCELADOS POR ESO SE COLOCA ESTO PARA EXCLUIR ESOS PEDIDOS
GROUP BY co.customer_id;
         

-- How many pizzas were delivered that had both exclusions and extras?

SELECT count(co.pizza_id) as Pizzas_Delivered_With_Changes
FROM customer_orders AS co 
INNER JOIN runner_orders AS ro ON co.order_id = ro.order_id
WHERE pickup_time <> 'null' 
AND (exclusions IS NOT NULL AND exclusions <> 'null' AND LEN(exclusions) > 0)
AND (extras IS NOT NULL AND extras <> 'null' AND LEN(extras) > 0) 

--What was the total volume of pizzas ordered for each hour of the day?

select Column_Name, Data_Type from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = 'customer_orders'

select DATEPART(HOUR,order_time) AS 'HORA',
COUNT(*) as 'Pizzas Ordenadas'
from customer_orders
group by DATEPART(HOUR,order_time)

-- aqui estamos utilizando la funcion datepart para extraer las horas, luego se contabiliza todo agrupandolo por hora.

-- What was the volume of orders for each day of the week?

SELECT 
  DATENAME(WEEKDAY, order_time) as day, 
  COUNT(*) as ordered_pizzas 
FROM 
  customer_orders 
GROUP BY 
  DATENAME(WEEKDAY,order_time);