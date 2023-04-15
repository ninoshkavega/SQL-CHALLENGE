-- B. Runner and Customer Experience
-
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT DATEADD(week, DATEDIFF(week, 0, registration_date), 0) +4 AS 'WEEK', count(runner_id) as 'Runner Per Week'
from runners -- se agrega +4 para que de como resultado el 2021-01-01 delo contrario la funcion tira otra fecha 
group by DATEADD(week, DATEDIFF(week, 0, registration_date), 0) 
-- al usar la funcion datediff, calculamos la diferencia 2 dos fecha usando como unidad la semana. El 0 representa por default la fecha inicial
-- de sql server menos la fecha de la columna registration_Dat
-- al usar la funcion dateadd se utiliza para agregar unidades, en este caso estamos agregando semanas al resultado de DATEDIFF, y el tercer argumento que es '0' indica que no vams a agregar nada
-- en otras palabras, si registration_date es un lunes, el resultado sería la fecha correspondiente a ese lunes. Si registration_date es un miércoles, el resultado sería la fecha correspondiente al lunes de esa semana. Si registration_date es un sábado, el resultado sería la fecha correspondiente al lunes de la semana siguiente.
--
--
--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id,AVG(CONVERT(INT,SUBSTRING(duration,1,2))) as Tiempo_Promedio
from runner_orders
where duration <> 'null'
GROUP BY runner_id
--
SELECT runner_id,AVG(DATEDIFF(minute, order_time, pickup_time)) as avg_minutes_to_pickup
from runner_orders as RO inner join customer_orders as CO on ro.order_id = co.order_id
where pickup_time <> 'null'
group by runner_id order by avg_minutes_to_pickup asc


--Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- para anilizar o  dar un vistazo de la cantidad de pizzas por numero de orden
select co.order_id, count(co.order_id) as 'cantidad por orden' 
from runner_orders as RO inner join customer_orders as CO on ro.order_id = co.order_id
where pickup_time <> 'null'
group by co.order_id
--
WITH CTE AS (
select co.order_id, count(co.order_id)as CANT_PIZZAS, AVG(DATEDIFF(minute,order_time, pickup_time)) as PREP_TIME
from runner_orders as RO inner join customer_orders as CO on ro.order_id = co.order_id
where pickup_time <> 'null'
Group by co.order_id)
SELECT CANT_PIZZAS, AVG(PREP_TIME) AS AVG_PREP_TIME FROM CTE  GROUP BY CANT_PIZZAS
select* from runner_orders
--What was the average distance travelled for each customer?
SELECT CO.customer_id, avg(convert(float,REPLACE(Distance, 'km',' '))) as DISTANCE_IN_KM 
from runner_orders as RO inner join customer_orders as CO on ro.order_id = co.order_id
where pickup_time <> 'null'
group by CO.customer_id
--What was the difference between the longest and shortest delivery times for all orders?
select  max(CONVERT(INT,SUBSTRING(duration,1,2))) - min(CONVERT(INT,SUBSTRING(duration,1,2)))   as DIFERENCIA_DE_TIEMPO
from runner_orders
where duration <> 'null'

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT runner_id, avg((convert(float,REPLACE(Distance, 'km',' '))) / (CONVERT(float,SUBSTRING(duration,1,2)))) as SPEED
FROM runner_orders 
WHERE distance <> 'null'
group by runner_id

--What is the successful delivery percentage for each runner?


SELECT runner_id, 
  COUNT(*) as 'Total Deliveries', 
  SUM(CASE WHEN Pickup_time <> 'null' THEN 1 ELSE 0 END) as 'Successful Deliveries',
  CAST(SUM(CASE WHEN Pickup_time <> 'null' THEN 1 ELSE 0 END) as float) / COUNT(*) * 100 as 'Success Percentage'
FROM runner_orders
GROUP BY runner_id


