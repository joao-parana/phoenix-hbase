!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select c_count, count(*) as custdist from ( select c_custkey, count(o_orderkey) as c_count from customer left outer join orders on c_custkey = o_custkey and o_comment not like '%pending%packages%' group by c_custkey ) c_orders group by c_count order by custdist desc, c_count desc;
!quit
