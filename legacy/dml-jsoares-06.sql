!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select sum(l_extendedprice * l_discount) as revenue from lineitem where l_shipdate >= TO_TIMESTAMP('1994-01-01') and l_shipdate < TO_TIMESTAMP('1995-01-01') and l_discount between 0.05 - 0.01 and 0.05 + 0.01 and l_quantity < 25;
!quit
