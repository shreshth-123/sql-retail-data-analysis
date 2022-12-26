

---Q1.	What is the total number of rows in each of the 3 tables in the database?
          SELECT count(1) as tot_rows FROM Customer
          SELECT count(1) as tot_rows FROM prod_cat_info
          SELECT count(1) as tot_rows FROM Transactions

/*Q2. What is the total number of transactions that have a return? */
          SELECT COUNT(transaction_id) AS ret_trns
          FROM Transactions
          WHERE QTY<0
          
 /*Q3.  As you would have noticed, the dates provided across the datasets are not in a correct format.
    As first steps, pls convert the date variables into valid date formats before proceeding ahead.*/
            
	   select convert(date,tran_date,105) as tran_date from Transactions

	   select convert(date,dob,105) as Dob from Customer
	  

/* Q4.	What is the time range of the transaction data available for analysis? 
        Show the output in number of days, months and years simultaneously in different columns.*/
          select
          datediff(day,min(tran_date),max(tran_date)) as days,
          datediff(month,min(tran_date),max(tran_date)) as months,
          datediff(year,min(tran_date),max(tran_date)) as years 
		  from Transactions


 /*Q5.Which product category does the sub-category “DIY” belong to?  */

         SELECT prod_cat
         FROM prod_cat_info
         where prod_subcat = 'diy'


                      -------- ANALYSIS---------


   /* Q1. WHICH CHANNEL IS USED FREUQUENTY FOR TRANSACTIONS*/


   /* Q2.What is the count of Male and Female customers in the database?*/

         select count(customer_id) as males
		 from customer
		 where Gender = 'M'
        
         select count(customer_id) as Females
         from Customer
          where Gender = 'F'
     
   /* Q3.From which city do we have the maximum number of customers and how many?*/
   
   select top 1 city_code, count(customer_id)
   from customer
   group by city_code
   order by count(city_code) desc 
   /* Q4.How many sub-categories are there under the Books category?  */

		select prod_subcat,prod_cat 
		from prod_cat_info
		where prod_cat = 'Books'

   /* Q5.What is the maximum quantity of products ever ordered?   */

        select max(qty) as Maximum_QTY_SOLD 
		from Transactions
		where Qty>0

   /* Q6.What is the net total revenue generated in categories Electronics and Books?*/

       /* change the  datatype to float */
         alter table transactions alter column total_amt float
		  select  sum(total_amt) as net_revenue 
          from Transactions as x 
          inner join 
          prod_cat_info as y 
          on x.prod_cat_code=y.prod_cat_code and x.prod_subcat_code=y.prod_sub_cat_code 
          group by prod_cat
          having y.prod_cat in ('Electronics','Books')


    /* Q7.How many customers have >10 transactions with us, excluding returns? */

         select count(customer_id) as no_of_customer from 
         (
          select customer_id  , count(transaction_id) as transactions 
          from Customer as x
          inner join Transactions as y
          on x.customer_id=y.cust_id
          where total_amt>0
          group by  customer_Id
          having count(transaction_id)>10
          )
          t1
  
    /* Q8.What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?*/
   
	 
	     select sum(net_revenue) as total_combined_revenue from
         (
         select sum(total_amt) as net_revenue, Store_type 
         from Transactions as x 
          inner join 
          prod_cat_info as y 
          on x.prod_cat_code=y.prod_cat_code and x.prod_subcat_code=y.prod_sub_cat_code 
          group by prod_cat , Store_type
          having y.prod_cat in ('Electronics','Clothing') and x.Store_type like 'Flagship%'
         )t1
	
     /* Q9.What is the total revenue generated from “Male” customers in “Electronics” category? 
	       Output should display total revenue by prod sub-cat.*/
          
          select  prod_subcat, sum(total_amt) as tot_revenue
          from Transactions as t
          inner join prod_cat_info as p
          on t.prod_cat_code=p.prod_cat_code and t.prod_subcat_code=p.prod_sub_cat_code
          inner join Customer as c
          on t.cust_id=c.customer_Id
           where prod_cat='Electronics' and gender='M'
          group  by prod_subcat
          
     /* Q10.What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales? */
         
		 -- CHANGING THE DATATYPES--
		  select * from Transactions
          alter table transactions alter column qty int
          alter table transactions alter column rate int
          alter table transactions alter column tax float

        --ANS10.

            Select Top 5 prod_subcat,
            Sum(Case When Qty < 0 Then Qty Else 0 end )* 100/Sum(Case When Qty > 0 Then Qty Else 0 end ) [asReturn%],
            100 + Sum(Case When Qty < 0 Then Qty Else 0 end )* 100/Sum(Case When Qty > 0 Then Qty Else 0 end ) [Sales %]
            from Transactions as x
			inner join prod_cat_info as y
			on x.prod_cat_code=y.prod_cat_code
			and x.prod_subcat_code=y.prod_sub_cat_code
            group by prod_subcat
            Order By [Sales %]


    /*Q11.For all customers aged between 25 to 35 years find what is the net total revenue generated
         by these consumers in last 30 days of transactions from max transaction date available in the data? */


         select cust_id,sum(total_amt) as revenue 
		 from Transactions
		 where cust_id in 
		 (
		 select customer_Id from Customer 
		 where datediff(YEAR,convert(date,DOB,105),getdate()) between 25 and 35
		 )
		 and convert(date,tran_date,105) between dateadd(day,-30,(select max(convert(date,tran_date,105)) from Transactions))
		 and (select max(convert(date,tran_date,105)) from Transactions)
		 group by cust_id



    /*Q12.Which product category has seen the max value of returns in the last 3 months of transaction?*/
 
           select top 1 prod_cat,sum(total_amt) as max_returns from Transactions as X
           inner join prod_cat_info as Y
           on x.prod_cat_code=y.prod_cat_code
           and x.prod_subcat_code=y.prod_sub_cat_code
           where total_amt<0
           and convert(date,tran_date,105) between dateadd(month,-3,(select max(convert(date,tran_date,105)) from Transactions))
           and (select max (convert(date,tran_date,105)) from Transactions)
           group by prod_cat
           order by max_returns desc




   /*Q13.Which store-type sells the maximum products; by value of sales amount and by quantity sold?*/

           select TOP 1 store_type, sum(Qty) as tot_qt, sum(total_amt) as tot_rev
           from Transactions
           group by Store_type
           ORDER BY SUM(QTY) DESC
	      


  /* Q14.What are the categories for which average revenue is above the overall average. */

          SELECT  prod_cat
          FROM Transactions AS x
          INNER JOIN 
          prod_cat_info AS y
          ON X.prod_cat_code=Y.prod_cat_code
          group by prod_cat
          having avg(total_amt) > (select(avg(total_amt)) from Transactions)


  /*Q15.Find the average and total revenue by each subcategory for the categories which are among 
        top 5 categories in terms of quantity sold.*/ 

         select  prod_cat ,PROD_SUBCAT,sum(total_amt) as total_revenue , avg(total_amt) as average_revenue   from Transactions as x
         inner join 
         prod_cat_info as y
         on x.prod_cat_code=y.prod_cat_code and x.prod_subcat_code=y.prod_sub_cat_code
		 WHERE prod_cat in 
		    (
		    select top 5 prod_cat
		    from Transactions as a
		    inner join prod_cat_info as b
		    on a.prod_cat_code=b.prod_cat_code
		    and a.prod_subcat_code=b.prod_sub_cat_code
			group by prod_cat
			order by sum(qty) desc
			)
         group by prod_cat,prod_subcat
         

  /* END Q15*/