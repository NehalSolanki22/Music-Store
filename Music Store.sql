-- Set 1 Beginner

select * from Album

with Dup as(
select * ,ROW_NUMBER() over (partition by first_name,Last_name order by customer_id) as [No.]from customer
)
select * from Dup 
where [No.]>1

select * from customer
select * from employee
select * from track
select * from artist
select * from genre
select * from invoice
select * from invoice_line
select * from media_type
select * from playlist
select * from playlist_track

--Q 1: Who is the Senior most employee based on job title?

select top 1 * from employee
order by levels desc

--Ans is Mohan Madan

--Q 2: Which Countries have the most invoices?

select billing_country,COUNT(billing_country) from invoice
group by billing_country
order by 2 desc

-- Answer is USA

--Q 3: what are the top3 values of total invoice

select top 3 i.invoice_id,sum(ie.unit_price * ie.quantity) as [Price]from invoice as i
left join invoice_line as ie
on ie.invoice_id=i.invoice_id
group by i.invoice_id
order by 2 desc

--OR

select top 3 invoice_id,total from invoice
order by total desc

-- Answer is The top 3 invoice values are 23.76,19.8 and 19.8

--Q 4: Which City has the best Customers? We Would like to throw a promotional Music Festival in the city we made the most
--money.Write a query that returns one city that has the highest sum of invoice totals.Return both city name & sum of all invoice totals


select top 3 i.billing_city,round(sum(ie.unit_price * ie.quantity),2) as [Price]from invoice as i
left join invoice_line as ie
on ie.invoice_id=i.invoice_id
group by i.billing_city
order by 2 desc

--OR

select billing_City,SUM(total) as Total from invoice
group by billing_city
order by 2 desc

--Q 5: Who is the Best Customer?The Customer who has spent the most money will be declared the best customer.Write the query
--that returns the person who has spent the most money

select top 1 (c.first_name + c.last_name) as [Name], sum(total) as Total from invoice as i
left join customer as c
on c.customer_id=i.customer_id
group by c.first_name,c.last_name
order by 2 desc


-- Set 2 Moderate

--Q 1 : Write query to return the email,first name,last name & Genre of all Rock Music Listeners.Return Your list orderd alphabetically
--by email starting with A

select distinct(c.first_name + c.last_name) as [Full Name],c.email from customer as c
left join invoice as i
on i.customer_id=c.customer_id
left join invoice_line as ie
on ie.invoice_id=i.invoice_id
left join track as t
on ie.track_id=t.track_id
where t.genre_id=(select g.genre_id as [Genre Total] from track as t 
left join genre as g
on t.genre_id=g.genre_id
where g.name='Rock'
group by g.name,g.genre_id) 
order by c.email 

--Q 2: Lets invite the artists who have written the most rock music in our dataset.Write a query that returns the artist name
--and total track count of top 10 rock bands

select top 10 a.name as [Artist],count(a.name) as [Total Songs] from artist as a
left join album2 as al
on al.artist_id=a.artist_id
left join track as t
on t.album_id=al.album_id
where t.genre_id=(select genre_id from genre
where name like 'Rock')
group by a.name
order by 2 desc


--Q 3 : Return all the track names that have a song length longer than the average song length.Return the Name and millisecond for each track
--order by the song length with the longest song listed first

select [name],milliseconds from track
where milliseconds > (select AVG(milliseconds) from track)
order by 2 desc

--Set 3  Advance

--Q 1 : Find How much Money Spent by each Customer on Artist? Write a Query to return customer name, artist name and total spent

select (c.first_name+c.last_name) as [Full Name],ar.name as [Artist],sum(ie.quantity*ie.unit_price) as [Total] from customer as c
left join invoice as i 
on i.customer_id=c.customer_id
left join invoice_line as ie
on ie.invoice_id=i.invoice_id
left join track as t
on ie.track_id=t.track_id
left join album2 as al
on al.album_id=t.album_id
left join artist as ar
on ar.artist_id=al.artist_id
group by c.first_name,c.last_name,ar.name
order by [Total] desc

-- Q 2: We want to find out the most popular music genre for each country.we determine the most popular genre as the genre with the highest 
--amount of purchases.Write a query that returns each country along with the top genre. for the countries where the maximum
--number of purchases is shared return all genres


with Country as(
select c.country as [country_name],g.name as [genre_name] ,count(ie.quantity) as [Highest Purchases],ROW_NUMBER() over (partition by c.country order by count(ie.quantity) desc)   as [No.] from invoice as i
left join invoice_line as ie
on ie.invoice_id=i.invoice_id
left join customer as c
on c.customer_id=i.customer_id
left join track as t
on ie.track_id=t.track_id
left join genre as g
on g.genre_id=t.genre_id
group by c.country,g.name

)
select country_name,genre_name,[highest Purchases] from Country
where [No.]<=1


--Q3: Write a query that determines the customer that have spent the most on music for each country.write the query which
--returns the country along with the top customer and how much they spent.For countries where top amount spent is shared,
--provide all customer who spent this amount


with Country as(
select c.country as [country_name],c.first_name as [Name],sum(total) as [Total Spent],ROW_NUMBER() over (partition by c.country  order by sum(total) desc)   as [No.] from customer as c
left join invoice  as i
on i.customer_id=c.customer_id
group by c.country,c.first_name
)
select [Name],country_name,[Total Spent] from Country
where [No.]<=1


