create database adventureworks1;
drop database adventureworks1;
select * from dimsalesterritory;
select * from dimproductmerge;
select * from dimsales;
select * from dimcustomer;
select * from dimdate;

/* find total profit, average profit, max profit, min profit, count and distinct count of customerkey from dimsales table use adventureworks1 database */

use adventureworks1;
select round(sum(profit),0) as Total_profit,
round(avg(profit),0) as Average_profit,
round(max(profit),0) as maximum_profit,
round(min(profit),0) as minimum_profit,
count(customerkey) as Total_customers,
count(distinct(customerkey)) as Unique_customers from dimsales;

/* find total unitprice for each salesterritorykey from dimsales table use adventureworks1 */

select SalesTerritoryKey, round(sum(UnitPrice),0) as Total_unitprice from dimsales
group by SalesTerritoryKey
order by Total_unitprice desc;

/* find the customername whose yearlyincome is less than avg income from dimcustomer table */

select concat(firstname,"-", lastname) as customername, yearlyincome from dimcustomer
where YearlyIncome < (select avg(YearlyIncome) as avgincome from dimcustomer);

/* use adventureworks1. categorize the products into high, medium and low status with respect to safetystocklevel  column as per  following condition :
high : safetystocklevel > 800
medium: safetystocklevel >500
low : safetystocklevel <=500 */

select englishproductname, safetystocklevel,
case
when safetystocklevel>800 then "High"
when safetystocklevel>500 then "Medium"
else "Low"
end as product_status
from dimproductmerge
order by SafetyStockLevel desc; 

#Using dimsalesterritory table show result with self join 

select T1.salesterritorykey, T1.salesterritoryregion, T1.salesterritorygroup, T2.salesterritoryalternatekey, T2.salesterritorycountry
from dimsalesterritory as T1
inner join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey;

select T1.salesterritorykey, T1.salesterritoryregion, T1.salesterritorygroup, T2.salesterritoryalternatekey, T2.salesterritorycountry
from dimsalesterritory as T1
left join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey;

select T1.salesterritorykey, T1.salesterritoryregion, T1.salesterritorygroup, T2.salesterritoryalternatekey, T2.salesterritorycountry
from dimsalesterritory as T1
right join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey;

select T1.salesterritorykey, T1.salesterritoryregion, T1.salesterritorygroup, T2.salesterritoryalternatekey, T2.salesterritorycountry
from dimsalesterritory as T1
left join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey
union
select T1.salesterritorykey, T1.salesterritoryregion, T1.salesterritorygroup, T2.salesterritoryalternatekey, T2.salesterritorycountry
from dimsalesterritory as T1
right join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey;

select T1.salesterritoryregion, T2.salesterritorycountry
from dimsalesterritory as T1
cross join dimsalesterritory as T2
on T1.SalesTerritoryKey=T2.SalesTerritoryAlternateKey;


#Find aggregate value of reorderpoint for each englishproductsubcategoryname using window function from dimproductmerge table

select distinct (englishproductsubcategoryname),
sum(reorderpoint)over(partition by englishproductsubcategoryname) as Total_reorderpoint,
avg(reorderpoint)over(partition by englishproductsubcategoryname) as avg_reorderpoint,
max(reorderpoint)over(partition by englishproductsubcategoryname) as max_reorderpoint,
min(reorderpoint)over(partition by englishproductsubcategoryname) as min_reorderpoint,
count(reorderpoint)over(partition by englishproductsubcategoryname) as count_of_reorderpoint
from dimproductmerge;

# create inout procedure for countrywise profit

delimiter //
create procedure Get_country_profit(In input_salesorderlinenumber int,
In input_salesterritorycountry varchar(20))
begin
select
input_salesorderlinenumber as salesorderlinenumber,
input_salesterritorycountry as country,
sum(profit) as Total_profit
from dimsales ds join dimsalesterritory dst
on ds.salesterritorykey=dst.salesterritorykey
where ds.salesorderlinenumber=input_salesorderlinenumber and dst.salesterritorycountry=input_salesterritorycountry ;
end //
delimiter ;

call Get_country_profit(2,"canada");
drop procedure Get_country_profit;


# create view as kpi1 as avg of extendedamount from dimsales table using adventureworks1 database

create view kpi1 as
select avg(ExtendedAmount) as avg_extendedamount from dimsales;
select * from kpi1;
drop view kpi1;

# find avg productstandardcost using CTE

with avg_productstandardcost as(
select avg(productstandardcost) from dimsales) 
select * from avg_productstandardcost;

# create function difference between tax amount and freight from dimsales table

delimiter //
create function difference(taxamt decimal(10,2), freight decimal(10,2)) 
returns decimal(10,2)
deterministic
begin
return taxamt-freight;
end //

select taxamt,freight,difference(taxamt,freight) from dimsales;

# Find name of customers whose occupation is management from dimcustomertable using where function

select distinct customeralternatekey,firstname,lastname,englishoccupation,englisheducation from dimcustomer
where englishoccupation like"%management%";


