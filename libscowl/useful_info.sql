.mode list

select concat_ws(': ',base_pos,descr) from base_poses order by order_num;

select '';

select concat_ws(': ',p.pos,b.descr,nullif(p.name, b.descr)) from poses p left join base_poses b using(base_pos) order by b.order_num,p.order_num;

