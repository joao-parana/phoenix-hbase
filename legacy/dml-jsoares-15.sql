!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql drop table revenue0; create table revenue0 (supplier_no INTEGER, total_revenue DECIMAL(12,2),CONSTRAINT revenue0_PK PRIMARY KEY (supplier_no)); UPSERT INTO revenue0(supplier_no,total_revenue) select l_suppkey, sum(l_extendedprice * (1 - l_discount)) from lineitem where l_shipdate >= TO_TIMESTAMP('1997-05-01') and l_shipdate < TO_TIMESTAMP('1997-08-01') group by l_suppkey; select s_suppkey, s_name, s_address, s_phone, total_revenue from supplier, revenue0 where s_suppkey = supplier_no and total_revenue = ( select max(total_revenue) from revenue0 ) order by s_suppkey; drop table revenue0;
!quit

