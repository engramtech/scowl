begin;

delete from pos_classes;
insert into pos_classes select distinct pos_class from groups order by pos_class;

delete from usage_notes;
insert into usage_notes select distinct usage_note from groups order by usage_note;

delete from categories;
insert into categories select distinct category from _scowl_combined order by category;

delete from tags;
insert into tags select distinct tag from _scowl_combined order by category;

delete from cluster_map;
insert into cluster_map select * from cluster_map_view;

delete from duplicate_derived;
insert into duplicate_derived select * from duplicate_derived_view;

delete from variant_info;
insert into variant_info select * from variant_info_view;

analyze;
commit;
