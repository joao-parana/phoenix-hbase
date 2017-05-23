!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select s_name, s_address from supplier, nation where s_suppkey in ( select ps_suppkey from partsupp, ( select l_partkey agg_partkey, l_suppkey agg_suppkey, 0.5 * sum(l_quantity) AS agg_quantity from lineitem where l_shipdate >= TO_TIMESTAMP('1994-01-01') and l_shipdate < TO_TIMESTAMP('1995-01-01') group by l_partkey, l_suppkey ) agg_lineitem where agg_partkey = ps_partkey and agg_suppkey = ps_suppkey and ps_partkey in ( select p_partkey from part where p_name like 'forest%' ) and ps_availqty > agg_quantity ) and s_nationkey = n_nationkey and n_name = 'UNITED KINGDOM' order by s_name;
!quit

