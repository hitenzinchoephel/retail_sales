		
	 -- Drop the table if it is exist in the database
		DROP TABLE IF EXISTS retail_sales;	

		select * from retail_sales; 
     -- Create a table called retail_sales
	
		CREATE TABLE retail_sales (
				INVOICE_ID INT PRIMARY KEY,
				CITY VARCHAR(50),
				CATEGORY VARCHAR(50),
				UNIT_PRICE NUMERIC(10, 2) NOT NULL CHECK (UNIT_PRICE > 0),
				QUANTITY INT NOT NULL CHECK (QUANTITY > 0),
				SALE_DATE DATE NOT NULL,
				SALE_TIME TIME,
				PAYMENT_METHOD VARCHAR(20) NOT NULL
			);
			

		-- PERFORM SOME BASIC EXPLORATIONS 
		
		
			-- Q.1 find the total number records in the table
			select count(*) from retail_sales; 
			
			-- invoice id is not null
			select count(invoice_id) from retail_sales;  
			-- Answer. There is 9969 rows in the table
			
			-- Q.2 find total number of unique city 
			select distinct city from retail_sales;
			-- Answer:  There are total of 98 unique cities
			-- Q.3 find total number of unique category 
			select distinct category from retail_sales;
			-- Answer: there is 6 unique category 
		
			-- CHECK FOR NULL VALUES -
			--  Note: 
			-- invoice id  is the primary key and 
			-- we will check if there is null primary key 
			  
		-- Q.4 Lets check if there is a null value 
		
			select * from retail_sales 
			where invoice_id is null;
			
		-- Answer. There is no null value in the records
		
		-- Sales Performance and Revenue Analysis
		
		-- Q.5 What are the total sales revenue and number of transactions over a specific period?
			select 
				 date_part('year' ,sale_date) as sales_year, 
				 count(*) as total_transaction,
				 sum(unit_price * quantity) as total_revenue 
		    from retail_sales
			group by sales_year
			order by 1
			
			
		-- Q.6 Which categories generate the highest and lowest revenue?
		
	
			SELECT
			    'Highest Revenue' AS type,
			    category,
			    total_revenue
			FROM (
			    SELECT
			        category,
			        SUM(unit_price * quantity) AS total_revenue,
			        RANK() OVER (ORDER BY SUM(unit_price * quantity) DESC) as rn_desc
					FROM
			        retail_sales
			    GROUP BY
			        category
			) AS ranked_categories
			WHERE rn_desc = 1
			
			union all
			
			SELECT
			    'Lowest Revenue' AS type,
			    category,
			    total_revenue
			FROM (
			    SELECT
			        category,
			        SUM(unit_price * quantity) AS total_revenue,
			        RANK() OVER (ORDER BY SUM(unit_price * quantity) ASC) as rn_asc
			    FROM
			        retail_sales
			    GROUP BY
			        category
			) AS ranked_categories
			WHERE rn_asc = 1;
	
		
		-- Q.7 Which  cities generate the highest and lowest revenue?
		
		        (select
				   'Lowest_revenue' as type,
					city, 
					sum(unit_price * quantity)as total_revenue
				from retail_sales 
				group by city
				order by total_revenue 
				limit 1 )

				union 

				( 
				select
				   'Highest_revenue' as type,
					city, 
					sum(unit_price * quantity)as total_revenue
				from retail_sales 
				group by city
				order by total_revenue desc
				limit 1) 


				-- Alternative solutions to find highest and lowest revenue
			
				-- Find the city which generated highest revenue. 

				select 
				city,
				sum(unit_price * quantity) as total 
				from retail_sales
				group by 1
				order by total desc
				limit 1 ; 

				-- Find the city which generated lowest revenue. 

				select 
				city,
				sum(unit_price * quantity) as total 
				from retail_sales
				group by 1
				order by total 
				limit 1 ; 
				
			-- Answer: Weslaco generate the highest revenue and Lake Jackson generat the lowest revenue
				
		
		-- Q.8 What is the average order value, and how does it vary by category?
		
				select 
				category,
				round(avg(unit_price * quantity),2) as avg_sales
				from retail_sales
				group by category
				order by avg_sales desc;
				
		
		-- Q.9 What is the average order value, and how does it vary by city?
		        select 
				city,
				round(avg(unit_price * quantity),2) as avg_sales
				from retail_sales
				group by city
				order by avg_sales desc;
			
		
		-- Customer and Purchasing Trends
		
		-- Q.10 What are the most common payment methods used by customers?
			select payment_method,
				   count(*) as cnt 
			from retail_sales
			group by payment_method
			order by cnt desc ;
		-- Answer: Credit , Ewallet , Cash are the payment method used from higest to lowest

		

		-- Q.11 Find the payment method usage trend in past years 


		With cte as (

		select 
			extract( year from sale_date) as order_year,
			payment_method,
			count(*) as pm_cnt
		from retail_sales
		group by order_year, payment_method
		order by 1
		)

		select 
		payment_method,

		sum(case when order_year ='2020' then pm_cnt else 0 end) as sales_2020,
		sum(case when order_year ='2021' then pm_cnt else 0 end) as sales_2021,
		sum(case when order_year ='2022' then pm_cnt else 0 end) as sales_2022,
		sum(case when order_year ='2019' then pm_cnt else 0 end) as sales_2019,
		sum(case when order_year ='2023' then pm_cnt else 0 end) as sales_2023

		from cte 
		group by payment_method

	-- Finding - Over the past years , mostly used payment method is credit card followed by ewallet and then cash. 
	-- Cash payment method is low compared to credit card and eWallet. 
	-- So it is recommended to build seamless and robustic Credit card and ewallet payment systems to ensure smooth customer exp
	
	
		-- Q.12 Which days of the week have the highest sales volume?
			select 
			to_char(sale_date,'Day') as day_of_week ,
			count(*) as cnt  from retail_sales
			group by 1
			order by cnt desc ;
			-- Answer: There is no big differences in sales in most of the days of week except on Monday. Monday is little slower
			
	
		
		-- Operational Insights
		
		-- Q.13 How does sales performance vary by time of day (e.g., morning vs. evening)?
			-- Note: Store opens from morning 6 to late night 23 ( 11pm)
			
			With time_shifts as (
			    select
			        case
			            when sale_time >= TIME '06:00:00' and sale_time < TIME '12:00:00' then 'morning'
			            when sale_time >= TIME '12:00:00' and sale_time < TIME '17:00:00' then 'afternoon'
			            when sale_time >= TIME '17:00:00' and sale_time < TIME '21:00:00' then 'evening'
			            else 'late_night'
			        end as sale_shift,
			        unit_price * quantity AS total_sales
			    from
			        retail_sales
			)
			select
			    sale_shift,
			    sum(total_sales) as total_revenue
			from
			    time_shifts
			group by
			    sale_shift
			order by
			    total_revenue desc;	
		
		
		-- Q.14 Is there a correlation between unit price and quantity purchased?
		
				select 
				corr(unit_price, quantity) as price_quantity_correlation
				from retail_sales
		
		-- Answer: The coefficient range for unit price and quantity is  0.062 which is negligible. so it means there is no relationship 
		
		
		-- Growth and Optimization
		
		-- Q.15 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
		
			 
			With cte as
			(    
				select 
				    extract(YEAR FROM sale_date) as year,
				    extract(MONTH FROM sale_date) as month,
				    avg(unit_price * quantity) as avg_sale,
				    rank() over(partition by extract(year from sale_date) order by avg(unit_price * quantity) desc) as rnk
				FROM retail_sales
				GROUP BY 1, 2
			) 
			select year,
			       month,
			       round(avg_sale,2) as average_sale
			from cte 
			WHERE rnk = 1
		
		
		-- Q.15 . Find top 3 category sales by each city 

		-- Solution 1
		
		With city_sales as (
		select 
			city,
			category,
			sum(unit_price * quantity) as sales,
			row_number() over (partition by city order by sum(unit_price * quantity) desc) as rn
		from retail_sales
		group by city, category )
		
		select * 
		from city_sales
		where rn <=3; 
		
		
		-- Solution 2
		With city_sales as (
		select 
			city,
			category,
			sum(unit_price * quantity) as sales
		from retail_sales
		group by city, category )
		
		select * 
		from 
		(select * ,	row_number() over (partition by city order by sales desc) as rn
		from city_sales
		) a 
		where rn <=3
		

		-- Solution 3
		
		With city_sales as (
		select 
			city,
			category,
			sum(unit_price * quantity) as sales
		from retail_sales
		group by city, category ), 
		
		sale_rank as (
			select * ,	row_number() over (partition by city order by sales desc) as rn
		from city_sales
		)
		select * 
		from  sale_rank 
		where rn <=3
		
		
		 -- Q.16 Find year over year growth in sales  
		
		with cte as (
			select 
			distinct extract('Year' from sale_date) as year, 
			sum(unit_price * quantity) as yearly_sale
		from retail_sales
		group by year
		order by year ), 
		cte_sales as (
		
		select *, lag(yearly_sale,1,yearly_sale) over(order by year ) as previous_sale
		from cte )
		
		select *,  round((yearly_sale - previous_sale) *100 / previous_sale ,2) as yoy_growth
		from cte_sales
		
		--Q.17  Find month over month growth in past three year. [2021,2022,2023] 
		
		With monthly_sales as (
		
		select
			date_part('year',sale_date) as order_year,
			date_part('month', sale_date) as order_month,
			sum(unit_price * quantity) as sales
		from retail_sales
		group by 1,2

		)
		select 
			order_month,
			sum(case when order_year ='2019' then sales else 0 end) as sales_2019,
			sum(case when order_year ='2020' then sales else 0 end) as sales_2020,
			sum(case when order_year ='2021' then sales else 0 end) as sales_2021,
			sum(case when order_year ='2022' then sales else 0 end) as sales_2022,
			sum(case when order_year ='2023' then sales else 0 end) as sales_2023
		from monthly_sales
		group by order_month
		order by order_month

    -- Note: 
	-- Here is missing sales data in year 2019, We don't have sales information from month April to December. So i did a cross verifications
		
		select 
			max(date_part('month', sale_date)) 
		from retail_sales 
		where extract(year from sale_date) =2019

		Findings: 
		
		-- There is a huge volumn of credit card users compared to cash. so it is important to focus 
		-- on credit card usage given that cash transaction is well reported 
		
		
		-- There is no big differences on sales on day of the week except on monday.
		-- Monday seems perform little poor than other days
		
		
		-- There are more sales in afternoon and evening from that 12:00:00 to 21:00:00  12:00pm to 9:00pm 
		-- there is very less late night sales which is after 9:00 PM 


        --  Find the month over month sales growth in year 2023 
		
				With cte as (
				        select 
						to_char(sale_date,'yyyy/mm') as month,
						sum(unit_price * quantity) as sales
						from retail_sales
						where extract(year from sale_date) =2023
						group by month
				)
				select 
				
				* ,
				round( ((sales - previous_sale) *100)/previous_sale
				,2) as mom_growth
				
				from(
				
				select * , 
				lag(sales,1,sales) over( order by month) as previous_sale
				from cte  )

				

				-- create a stored procedure to get sales by city 
				-- pass a city name as parameters

				


		



	

			
					
						
						
		
		
		
		
		
		
		
