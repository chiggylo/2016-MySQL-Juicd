#show databases;
use juicd;
show tables;
-- Show the inside of table --
 select * from customer;
-- select * from comprises;
 select * from employee;
-- select * from juice;
-- select * from juicecup;
-- select * from linemgr;
-- select * from manages;
 select * from nonjuice;
 select * from outlet;
 select * from hasjuice;
 select * from hasnonjuice;
 select * from customerorder;
 select * from worksat order by jempid desc;
-- Question 1 --
select * from customer where jcardnum = 1000;

-- Question 2 --
#select sum(NJ.quantity) + sum(J.quantity) from hasnonjuice NJ, hasjuice J; product sold... I think
#select count(orderID) from customerorder; no. of orders... I think
-- Question 3 --
#select E.`name`, O.`address` from outlet O, employee E, manages M
#where O.jStoreId = M.jStoreId and M.jEmpId = E.jEmpId;

-- Question 4 --
#select E.`name`, O.`address` from worksat W, employee E, outlet O
#where  W.jEmpId = E.jEmpId and W.jStoreId = O.jStoreId and W.percentage = 100;

-- Question 5 --
#select `name`,`address`,`percentage` from employee natural join worksat group by jEmpId;

-- Question 6 --
#select max(jPoints) as Maximum, min(jPoints) as Minimum, avg(jPoints) as Average from customer;

-- Question 7 --
#select name, count(supervisee) from linemgr LM,  employee E 
#where  E.jEmpID = LM.supervisor group by supervisor;

-- Question 8 --
#select address, count(orderID) as `Total of Order` from outlet O, customerorder CO 
#where jStoreID = outletID group by outletID;

-- Question 9 --
#select jname, percentage from comprises, juice 
#where juiceid = jid and cupid = 1000;

-- Question 10 --
#select C.cupid, sum(J.perMl*C.percentage*JC.size/10000) as `price($)` from comprises C, juicecup JC, juice J
#where C.cupid = JC.cupid and C.juiceID = J.jID and c.cupid = 1000;

-- complex queries --

-- Question 1 --
#select address, count(orderID) as `Total Order`,date from outlet, customerorder
#where outletid = jstoreid group by date;

-- Question 2 --
#select cupid, count(juiceid) as `number of ingredient` from comprises 
#group by cupid having `number of ingredient` > 2;

-- Question 3 --
#select `name`, `address` from employee where `name` not in (
#select `name` from employee natural join worksat);

-- Question 4 -- 
#select orderid from customerorder where orderid not in (select orderid from hasnonjuice);

-- Question 5 --
drop function if exists juiceCupCost;
delimiter $$
create function juiceCupCost(id INT) returns double 
begin
declare cost double;
set cost = (select sum(J.perMl*C.percentage*JC.size/100) as `price($)` from comprises C, juicecup JC, juice J where C.cupid = JC.cupid and C.juiceID = J.jID and c.cupid = id);
return cost;
end$$
delimiter ;

select juiceCupCost(10);
-- Question 6 --

drop function if exists juiceOrderCost;
delimiter $$
create function juiceOrderCost(id int) returns double
begin
declare totalcost double default 0;
declare loops int;
declare pos int default 0;
set loops = (select count(cupid) from hasjuice where orderid = id);
while loops != 0 do
set totalcost = totalcost + juiceCupCost((select cupid from hasjuice where orderid = id limit pos,1))*(select quantity from hasjuice where cupid = (select cupid from hasjuice where orderid = id limit pos,1));
set pos = pos +1;
set loops = loops - 1;
end while;
return totalcost;
end$$
delimiter ;

select juiceordercost(2);

-- additional functionality --
-- question 1 --
drop function if exists totalOrderCost;
delimiter $$
create function totalOrderCost(id int) returns double
begin
declare numRows int;
declare totalcost double default 0;
declare product_id int;
declare no_quantity int;
declare price int;
declare loops int default 0;
declare nonjuice CURSOR FOR
select prodID, quantity from hasnonjuice where orderid = id;
set totalcost = totalcost + juiceOrderCost(id);
open nonjuice;
select FOUND_ROWS() into numRows;
while loops < numRows do
fetch nonjuice into product_id, no_quantity;
set totalcost = totalcost + (select perItem from nonjuice where prodid = product_id)*no_quantity*100;
set loops = loops + 1;
end while;
close nonjuice;
return totalcost;
end$$
delimiter ;

select totalordercost(2);

-- question 2 --
drop view if exists customerpricedorder;
create view customerpricedorder as 
select `date`,customerid, `orderid`, totalordercost(orderid) as `ordercost` from customerorder;

select * from customerpricedorder;

-- question 3 --
drop table if exists customerofMonths;
drop procedure if exists listCofM;
delimiter $$
create procedure listCofM()
begin
declare startyear int;
declare endyear int;
declare startmonth int;
declare endmonth int;
declare cid int;
declare cide text;
set startyear = (select year(`date`) from customerpricedorder order by `date` asc limit 1); # lowest 
set endyear = (select year(`date`) from customerpricedorder order by `date` desc limit 1); # highest
set startmonth = (select month(`date`) from customerpricedorder order by `date` asc limit 1) -1; # lowest 
set endmonth = (select month(`date`) from customerpricedorder order by `date` desc limit 1);

create table customerOfMonths( `year` int, `month` text, CofM int, CofMemail text);

while startyear != endyear or startmonth != endmonth do
set startmonth = startmonth +1;
set cid = (select customerid from customerpricedorder where ordercost = (select max(ordercost) from customerpricedorder where year(date) = startyear and month(date) = startmonth) + 0);
set cide = (select email from customer where jcardnum = cid);

insert into customerofmonths values(
startyear,
(SELECT MONTHNAME(STR_TO_DATE(startmonth, '%m'))),
(select customerid from customerpricedorder where ordercost = (select max(ordercost) from customerpricedorder where year(date) = startyear and month(date) = startmonth)),
cide
);

if startmonth = 12 then
set startyear = startyear + 1;
set startmonth = 0;
end if;

end while;

end$$
delimiter ;


#select * from customerpricedorder where ordercost = (select max(ordercost) from customerpricedorder where year(date) = 2015 and month(date) = 2);


#select year(`date`),month(`date`),day(`date`) from customerpricedorder order by `date` asc limit 1; # lowest 

#select year(`date`), month(`date`),day(`date`) from customerpricedorder order by `date` desc limit 1; # highest
call listcofm();


-- insert into customerofmonths values(
-- (select year(`date`) from customerorder limit 1), 
-- (SELECT MONTHNAME(STR_TO_DATE((select month(`date`) from customerorder limit 1), '%m'))), 
-- (select customerid from customerorder limit 1), 
-- (select email from customer limit 1)
-- );


select * from customerofmonths;

