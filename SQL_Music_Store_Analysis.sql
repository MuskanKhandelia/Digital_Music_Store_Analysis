create database musicstoredata;

#Senior most employee 
select * 
from employee 
order by levels desc 
limit 1;

#Countries that have the most invoices
select billing_country,count(*) as count 
from invoice 
group by billing_country 
order by count desc;

#Top 3 values of total invoice
select * 
from invoice 
order by total desc 
limit 3;

#Cities that has the best customers
select billing_city,round(sum(total),3) as invoice_total 
from invoice 
group by billing_city 
order by invoice_total desc;

#Customer who has spent the most money
select c.customer_id,c.first_name,c.last_name,round(sum(total),3) as total 
from customer as c inner join invoice as i 
on c.customer_id = i.customer_id 
group by c.customer_id 
order by total desc 
limit 1;

#Rock Music Listeners
select distinct first_name,last_name,email 
from customer as c inner join invoice as i 
on c.customer_id = i.customer_id 
inner join invoice_line as il 
on i.invoice_id = il.invoice_id 
where il.invoice_id in 
(select track_id 
from track as t inner join genre as g 
on t.genre_id = g.genre_id 
where g.name = 'Rock')
order by email;

#Artist name and total track count of top 10 rock bands
select a.artist_id,a.name,count(*) as number_of_songs 
from artist as a inner join album as al
on a.artist_id = al.artist_id 
inner join track as t 
on al.album_id = t.album_id
inner join genre as g 
on t.genre_id = g.genre_id 
where g.name = 'Rock'
group by a.artist_id
order by number_of_songs desc
limit 10;

#Track names that have a song length longer than the average song length. 
select name,milliseconds
from track 
where milliseconds > 
(select avg(milliseconds) 
from track)
order by milliseconds desc;

#Amount spent by each customer on best selling artist
with best_selling_artist as 
(select ar.artist_id as artist_id,ar.name as artist_name,sum(il.unit_price*quantity) as total_sales
from invoice_line as il inner join track as t
on  il.track_id = t.track_id
inner join album as a
on t.album_id = a.album_id 
inner join artist as ar
on a.artist_id = ar.artist_id
group by 1
order by 3 desc
limit 1)
select c.customer_id,c.first_name,c.last_name,bsa.artist_name,sum(il.unit_price*quantity) as total_amount_spent
from customer as c inner join invoice as i 
on c.customer_id = i.customer_id
inner join invoice_line as il 
on i.invoice_id = il.invoice_id
inner join track as t
on  il.track_id = t.track_id
inner join album as a
on t.album_id = a.album_id 
inner join best_selling_artist as bsa 
on a.artist_id = bsa.artist_id 
group by 1
order by 5 desc;

#Most popular music Genre for each country
with popular_genre as 
(select g.genre_id,g.name,country,count(*) as purchases,
row_number() over (partition by country order by count(*) desc) as rowno
from customer as c inner join invoice as i 
on c.customer_id = i.customer_id
inner join invoice_line as il
on i.invoice_id = il.invoice_id
inner join track t 
on il.track_id = t.track_id
inner join genre as g
on t.genre_id = g.genre_id
group by country, genre_id
order by 3 asc,4 desc)
select * from popular_genre where rowno = 1;

#Customer that has spent the most on music for each country
with best_customer as 
(select c.customer_id,c.first_name,c.last_name,billing_country,sum(total) as total_spending,
row_number() over(partition by billing_country order by sum(total) desc) as rowno
from customer as c inner join invoice as i 
on c.customer_id = i.customer_id
group by i.billing_country,i.customer_id
order by 4 asc,5 desc)
select * from best_customer where rowno = 1;

