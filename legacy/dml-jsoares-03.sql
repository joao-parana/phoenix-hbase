!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select l_orderkey, sum(l_extendedprice * (1 - l_discount)) as revenue, o_orderdate, o_shippriority from customer, orders, lineitem where c_mktsegment = 'BUILDING' and c_custkey = o_custkey and l_orderkey = o_orderkey and o_orderdate < TO_TIMESTAMP('1995-03-15') and l_shipdate > TO_TIMESTAMP('1995-03-15') group by l_orderkey, o_orderdate, o_shippriority order by revenue desc, o_orderdate;
!quit
