use sakila;

-- List number of films per category.
select category_id, sum(film_id) from sakila.film_category
group by category_id
order by category_id; 


-- Display the first and last names, as well as the address, of each staff member.
select first_name, last_name, address_id from sakila.staff; 



-- Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name.
select c.last_name as customer, sum(p.amount) as total_amount from sakila.customer as c
join sakila.payment as p
on c.customer_id = p.customer_id
group by c.last_name
order by c.last_name;



--                         lab 2

use sakila;
-- Write a query to display for each store its store ID, city, and country.

select c.city as city, s.store_id as store_id, co.country as country  from sakila.city c
join sakila.country as co
on c.country_id = co.country_id
left join sakila.store as s
on s.last_update = co.last_update;

-- Write a query to display how much business, in dollars, each store brought in.
select s.store_id as store, sum(p.amount) as total_amount from sakila.store as s
join sakila.customer as c
on s.store_id = c.store_id
join sakila.payment as p
on c.customer_id = p.customer_id
group by s.store_id
order by total_amount;

-- What is the average running time of films by category?
select c.name as name, avg(f.length) as average_movie_length from sakila.category as c
join sakila.film_category as fc
on c.category_id = fc.category_id
join sakila.film as f
on f.film_id = fc.film_id
group by c.name
order by average_movie_length; 

-- Which film categories are longest?
select c.name as name, avg(f.length) as average_movie_length from sakila.category as c
join sakila.film_category as fc
on c.category_id = fc.category_id
join sakila.film as f
on f.film_id = fc.film_id
group by c.name
order by average_movie_length desc; 

-- Display the most frequently rented movies in descending order.
select*from sakila.rental
order by inventory_id desc;

-- List the top five genres in gross revenue in descending order.
select c.name as category_name, sum(p.amount) as gross_revenue  from sakila.category as c
left join sakila.film_category as fc
on fc.category_id = fc.category_id
left join sakila.inventory as i
on fc.film_id = i.film_id
left join sakila.rental as r
on i.inventory_id = r.inventory_id
left join sakila.payment as p
on r.rental_id = p.rental_id
group by name
order by gross_revenue
limit 5;

-- Is "Academy Dinosaur" available for rent from Store 1?
select f.title, s.store_id , inventory_id, i.last_update from sakila.film as f
join sakila.inventory as i
on f.film_id = i.film_id 
join sakila.store as s
on i.store_id = s.store_id
where f.title = 'Academy Dinosaur' and s.store_id ='1';

use sakila;

--                       lab 4

-- Get all pairs of actors that worked together.

select fa1.film_id, concat(a1.first_name, ' ', a1.last_name), concat(a2.first_name, ' ', a2.last_name)
from sakila.actor as a1
inner join sakila.film_actor as fa1
on a1.actor_id = fa1.actor_id
inner join film_actor fa2
on (fa1.film_id = fa2.film_id) and (fa1.actor_id != fa2.actor_id)
inner join actor a2
on a2.actor_id = fa2.actor_id;



-- Get all pairs of customers that have rented the same film more than 3 times.

SET sql_mode=(SELECT REPLACE(@@sql_mode, 'ONLY_FULL_GROUP_BY', ''));

select r1.customer_id, r1.inventory_id, count(r1.rental_id) as 'Times_rented', r2.customer_id, count(r2.rental_id) as ' Times_rented_2' from sakila.rental as r1
join sakila.rental as r2
on r1.customer_id <> r2.customer_id
and r1.inventory_id = r2.inventory_id
group by r1.customer_id, r2.customer_id
having (count(r1.rental_id)>3) and (count(r2.rental_id)>3);


--  Get all possible pairs of actors and films.
select * from (
 select distinct actor_id from sakila.actor
 ) sub1
 cross join (
select distinct film_id from sakila.film_actor
) sub2; 

use sakila;
--                         lab 5

-- How many copies of the film Hunchback Impossible exist in the inventory system?

select f.film_id, f.title, i.film_id, i.inventory_id from 
sakila.film as f 
join sakila.inventory as i 
on f.film_id = i.film_id 
where f.title = 'Hunchback Impossible';

use sakila;

-- List all films longer than the average.

select film_id, title, sum(length)/count(title) as average from sakila.film;

select title, length from sakila.film
where title in (
select title as title from(
select avg(length) as average, title
from sakila.film
where title <> ' ' 
group by title
having average > 115
order by length desc
) sub1
);


-- Use subqueries to display all actors who appear in the film Alone Trip

select title, film_id from sakila.film where title = 'Alone Trip';

select actor_id from sakila.film_actor where film_id = '17'; 

select f.title, f.film_id, a.actor_id from sakila.film as f
join sakila.film_actor as a 
on f.film_id = a.film_id
where f.film_id = '17';

select title, film_id, actor_id from sakila.film
where title in(
select title from(
select  actor_id
from sakila.film_actor
where title <> ' '
having title = 'Alone Trip') sub1
);



-- Identify all movies categorized as family films.
select c.name, fc.film_id from sakila.category as c
join sakila.film_category as fc
on c.category_id = fc.category_id
where c.name = 'family';



-- Get name and email from customers from Canada using subqueries
select*from sakila.country;
select c.city_id, c.country_id;

select concat(first_name, ' ' , last_name), email
from sakila.customer as cust
join address as addd
on cust.address_id = addd.address_id
join city as city
on city.city_id = addd.city_id
join country as country
on country.country_id = city.country_id
where country = 'Canada';

-- Which are films starred by the most prolific actor?
select title from sakila.film where film_id in
(select film_id from film_actor where actor_id =
(select actor_id from
(select actor_id, count(*) as mycount from film_Actor 
group by actor_id 
order by mycount 
desc limit 1) as c));


-- Films rented by most profitable customer.
select a.customer_id, concat(a.first_name,' ', a.last_name) as 'Full_name', b.payment_id, max(Amount_spent) as 'Amount_money'
from sakila.customer as a 
join (select payment_id, customeR_id, rental_id, count(amount) as 'Amount_spent'
from sakila.payment group by customer_id) as b
on b.customer_id = a.customer_id;

select customer_id, count(amount) as 'Amount_spent'
from sakila.payment group by customer_id;


-- Customers who spent more than the average.

select * from customer;
select *from payment group by customer_id;

select avg(amount) as average from payment;

#checking sum
select customer_id, sum(amount) as abc from payment group by 1;

#checking avg
select avg(abc) from (select customer_id, sum(amount) as abc from payment group by 1) as xxx;

select customer_id, sum(amount) as abc from payment
group by customer_id
 having sum(amount) > (select avg(abc) from (select customer_id, sum(amount) as abc
 from payment group by 1) as xxx);


--                            lab 6

use sakila;
 
 
-- For each film, list actor that has acted in more films.
use sakila;

select f_a1.actor_id, sub1.num_movies, f_a1.film_id, row_number() 
over (partition by f_a1.film_id order by sub1.num_movies desc) 
as ranking from film_actor as f_a1
join (select actor_id, count(film_id) as 'num_movies' from film_actor as f_a2
group by actor_id
order by num_movies desc) 
as sub1 on sub1.actor_id = f_a1.actor_id; 












