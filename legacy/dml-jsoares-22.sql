!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select cntrycode, count(*) as numcust, sum(c_acctbal) as totacctbal from ( select SUBSTR(c_phone,1,2) as cntrycode, c_acctbal from customer where SUBSTR(c_phone,1,2) in ('19', '29', '25', '23', '26', '11', '34') and c_acctbal > ( select avg(c_acctbal) from customer where c_acctbal > 0.00 and SUBSTR(c_phone,1,2) in ('19', '29', '25', '23', '26', '11', '34') ) and not exists ( select * from orders where o_custkey = c_custkey ) ) as custsale group by cntrycode order by cntrycode;
!quit
