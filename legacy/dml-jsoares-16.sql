!set isolation TRANSACTION_READ_COMMITTED
!set maxColumnWidth 30
!sql select p_brand, p_type, p_size, count(distinct ps_suppkey) as supplier_cnt from partsupp, part where p_partkey = ps_partkey and p_brand <> 'Brand#31' and p_type not like 'LARGE PLATED%' and p_size in (47, 31, 18, 19, 48, 7, 39, 22) and ps_suppkey not in ( select s_suppkey from supplier where s_comment like '%Customer%Complaints%' ) group by p_brand, p_type, p_size order by supplier_cnt desc, p_brand, p_type, p_size;
!quit

