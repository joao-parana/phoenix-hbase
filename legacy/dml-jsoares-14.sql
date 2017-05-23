!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select 100.00 * sum(case when p_type like 'PROMO%' then l_extendedprice * (1 - l_discount) else 0 end) / sum(l_extendedprice * (1 - l_discount)) as promo_revenue from lineitem, part where l_partkey = p_partkey and l_shipdate >= TO_TIMESTAMP('1994-03-01') and l_shipdate < TO_TIMESTAMP('1994-04-01');
!quit

