use sakila;

show tables;

-- exercise
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name. use sakila; -- using sakila DB
select concat(first_name," ", last_name) as full_name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
select * from actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select * from actor where last_name like '%li%' order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name.
alter table actor add middle_name varchar(255) after first_name;

-- 3b. Change the data type of the middle_name column to blobs.
alter table actor modify middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor drop middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, count(last_name) from actor group by last_name order by count(last_name) desc ;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, count(last_name) from actor group by last_name having count(last_name) >= 2 order by count(last_name) desc; 

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
-- Write a query to fix the record.
update actor set first_name = 'HARPO' where first_name = 'GROUCHO' and last_name = 'WILLIAMS';

SELECT * from actor where first_name = 'harpo';

update actor set first_name = 'GROUCHO' where first_name = 'HARPO' AND last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select s.first_name, s.last_name, a.address from staff s inner join address a using(address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select s.staff_id, s.first_name, s.last_name, sum(p.amount) as total_amount from staff s inner join payment p using(staff_id) 
where p.payment_date between '2005-08-01' and '2015-08-30' group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select * from film;
select * from film_actor;

select f.film_id, f.title, count(fa.actor_id) as num_actors from film f inner join film_actor fa using(film_id) group by f.film_id;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select count(film_id) as num_copies from inventory where film_id = (select film_id from film where title = 'Hunchback Impossible');


-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer
-- List the customers alphabetically by last name:
select * from payment;
select * from customer;
select c.first_name, c.last_name, sum(p.amount) from customer c join payment p using(customer_id) group by c.customer_id order by c.last_name;

-- 7a. Use subqueries to display the titles of movies -- starting with the letters K and Q whose language is English.
select * from film;
select * from language;

select title from film where language_id = (select language_id from language where name = 'English') and (title like 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select * from film;
select * from fiLm_actor;
select first_name, last_name from actor where actor_id in (select distinct actor_id from film_actor where film_id = (select film_id from film where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
-- email addresses of all Canadian customers. Use joins to retrieve this information.
select * from customer;
select * from city;
select * from country;
select * from address;

select first_name, last_name, email from customer join address using(address_id) where address_id in
(select address_id from address where city_id in (select city_id from city where country_id = (select country_id from country where country = 'Canada')));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies 
-- for a promotion. Identify all movies categorized as famiy films.
select * from film;
select * from film_category;
select * from category;

select title, description from film where film_id in 
(select film_id from film_category where category_id = (select category_id from category where name = 'Family'));

-- Display the most frequently rented movies in descending order.
select * from film;
select * from rental;
select * from inventory;

select f.title, count(r.rental_id) as rent_movie_frequency from film f 
left join inventory i using(film_id) left join rental r using(inventory_id) 
group by f.film_id order by rent_movie_frequency desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select * from store;
select * from staff;
select * from payment;
with temp_table as (
select st.staff_id, st.first_name, st.last_name, s.store_id from staff st inner join store s on st.staff_id = s.manager_staff_id)
-- select * from temp_table;
select sum(amount) from payment p inner join temp_table t on  p.staff_id = t.staff_id group by t.store_id;

-- or
SELECT sum(payment.amount), payment.staff_id FROM (payment) 
GROUP BY payment.staff_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
select * from store;
select * from address;
select * from city;
select * from country;
select s.store_id, a.address, a.city_id, c.city, ct.country from store s 
inner join address a on s.address_id = a.address_id 
inner join city c on c.city_id = a.city_id 
inner join country ct on c.country_id = ct.country_id;
                
-- 7h. List the top five genres in gross revenue in descending order. 

select c.name, sum(p.amount) as gross_revenue from film f left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id left join inventory i on f.film_id = i.film_id left join rental r using(inventory_id)
inner join payment p on r.rental_id = p.rental_id group by c.name order by gross_revenue desc limit 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue 

create view top_genre_revenue_wise as
select c.name, sum(p.amount) as gross_revenue from film f left join film_category fc on fc.film_id = f.film_id 
left join category c on c.category_id = fc.category_id left join inventory i on f.film_id = i.film_id left join rental r using(inventory_id)
inner join payment p on r.rental_id = p.rental_id group by c.name order by gross_revenue desc limit 5;

-- 8b. How would you display the view that you created in 8a?
select * from top_genre_revenue_wise;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_genre_revenue_wise;


