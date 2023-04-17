--C. Ingredient Optimisation
--What are the standard ingredients for each pizza?
-- to solve this question, we need to split the pizza_recipes in other format so we can join the tables.
-- creando funcion para dividir toppings.

SELECT pizza_id,topping_name --,value as  toppings -- el value as topping, es para que genere una columna con cada topping. Value contiene cada valor que separo la funcion string_split
FROM pizza_recipes
CROSS APPLY STRING_SPLIT(CAST(toppings as nvarchar(max)), ',') as S
INNER JOIN pizza_toppings as T ON T.topping_id=S.value
where topping_name like '%cheese%'


select * from pizza_toppings
select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'pizza_toppings' --(esto lo utilizamos para saber que tipo de data tiene nuestra tabla, es util porque nos indico que la columna topping era tipo text, lo cual no es compatible con las funciones que ibamos a utilizar.Por eso se utilizo cast para convertir la columna en nvarchar

--What was the most commonly added extra?
select TOP 1 count(convert(varchar,t.topping_name)) as COUNT, value as ID_TOPPING, (convert(varchar,t.topping_name)) as TOPPING_NAME from customer_orders
CROSS APPLY STRING_SPLIT(CAST(extras as nvarchar(max)), ',') as E
INNER JOIN pizza_toppings as T ON T.topping_id=E.value
where extras <> 'null' 
group by (convert(varchar,t.topping_name)), value
order by count desc

---group by value
--What was the most common exclusion?
select TOP 1 count(convert(varchar,t.topping_name)) as COUNT, value as ID_TOPPING, (convert(varchar,t.topping_name)) as TOPPING_NAME from customer_orders
CROSS APPLY STRING_SPLIT(CAST(exclusions as nvarchar(max)), ',') as EX
INNER JOIN pizza_toppings as T ON T.topping_id=EX.value
where extras <> 'null' 
group by (convert(varchar,t.topping_name)), value
order by count desc
-- SAME BUT REPLACE EXTRAS FOR EXCLUSION IN QUERY

--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
SELECT (convert(varchar, topping_name)) as TOPPING, count(convert(varchar, topping_name)) as CANT
FROM customer_orders AS CO INNER JOIN runner_orders AS RO ON CO.order_id = RO.order_id
LEFT JOIN pizza_recipes AS PR on co.pizza_id = pr.pizza_id
CROSS APPLY STRING_SPLIT(CAST(toppings as nvarchar(max)), ',') as S -- union para separar topings 
INNER JOIN pizza_toppings as T ON T.topping_id=S.value -- union para saber nombre de toppings
where duration <> 'null' -- estas fueron las ordenes canceladas por lo cual no se toma en cuenta.
group by (convert(varchar, topping_name))
order by count(convert(varchar, topping_name)) desc

