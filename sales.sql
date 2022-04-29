-- inspecting Data
select * from sales

-- checking unique value
 select Distinct status from sales
 select Distinct year_id from sales
 select Distinct productline from sales
 select Distinct country from sales
 select Distinct dealsize from sales
 select Distinct  territory from sales
 
-- Analysis
 select productline,sum(sales) Revenue from sales
  group by productline order by 2 desc 
 
 select year_id,sum(sales) Revenue from sales
  group by year_id order by 2 desc
  
 select dealsize,sum(sales) Revenue from sales
  group by dealsize order by 2 desc
  
-- 	what was the best month for sales in a specific year ? what's Revenue for the month?

Select month_id,sum(sales) Revenue,count(ordernumber) frequency from sales
 where year_id = 2004
 group by month_id order by 2 desc
                 -- base on product
Select month_id,productline,sum(sales) Revenue,count(ordernumber) frequency from sales
 where year_id = 2003 and month_id = 11
 group by month_id,productline order by 3 desc
 
-- RFM analysis
drop table rfm
with recursive rfm as(
Select
 customername,
 sum(sales) order$,
 avg(sales) avgorder$,
 count(ordernumber) orders,
 max(orderdate) lastorder,
 (select max(orderdate) from sales) lastsales,
 extract(day from (select max(orderdate) from sales) - max(orderdate)) lastorderday
 from sales
 group by customername
 ),
 rfmc as(
	 Select rfm.*,
	  Ntile(4) over (order by lastorderday) rfm_lastoday,
	  Ntile(4) over (order by orders) rfm_orders,
	  Ntile(4) over (order by order$) rfm_avgoday
    from rfm
 )
 select 
     rfmc.*,concat (rfm_lastoday,rfm_orders,rfm_avgoday) rfm_cell_string
	into rfm
	from rfmc 
                    select * from rfm
					
select customername,rfm_lastoday,rfm_orders,rfm_avgoday,
   case 
     when rfm_cell_string in('412','411','413','421','431','311','312','321') then 'lost customers'
	 when rfm_cell_string in('323','333','312','211','331','341','342','333','413','434') then 'Sliping customers'
	 when rfm_cell_string in('144','112','124','122','121','142','132','143','133','231','232','233','214','244','243') then 'new customers'
	 when rfm_cell_string in('332','322','344','334','433') then 'loyal customers'
 end rfm_segment
from rfm

-- what two more item are often sold together and convert the result to a row 

   select distinct ordernumber,(select string_agg(productcode,',') 
   from sales p where ordernumber in ( select ordernumber from (
	select ordernumber,count(*) Num_o_ords
 from sales  where STATUS = 'Shipped'
  group by ordernumber ) ornm 
  where Num_o_ords = 3) and 
  p.ordernumber = s.ordernumber) productcode
   from sales s order by 2
  