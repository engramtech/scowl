begin;

create view _scowl_combined as
select level, category, region, tag, group_id, pos, null as word_id
from scowl_data
union all
select level, category, region, tag, null, null, word_id
from scowl_override;
select * from _scowl_combined limit 0;

-- notes on scowl_ view:
--   - left join everywhere to prevent SQLite from reordering the join in most cases
--     - in particular, without a left join doing "select distinct word from scowl_ where ..." will cause
--       SQLite to scan the words table even if most of the entries in words will not be used
--     - but not cross join (as the documentation suggestions) as that will prevent reordering in all cases,
--       for example when doing "select * from scowl_ where word = ?";
--   - variant_info is a materialized view as SQLite will materialize the view in all cases adding a fixed amount of
--     overhead, even to simple queries such as "select * from scowl_ where word = ?"

create view _scowl_main as
select group_id, lemma_id, word_id,
       level, category, region, tag, pos, base_pos, pos_category, pos_class, usage_note,
       coalesce(spelling,'_') as spelling, coalesce(variant_level,0) as variant_level, coalesce(legacy_level,0) as legacy_level,
       lemma_variant_level, derived_variant_level,
       word,
       lemma_rank, entry_rank
  from scowl_data
  left join words using (group_id, pos)
  left join groups using (group_id)
  left join base_poses using (base_pos)
  left join variant_info using (word_id)
  left join variant_levels using (variant_level)
;
create view _scowl_override as
select group_id, lemma_id, word_id,
       level, category, region, tag, pos, base_pos, pos_category, pos_class, usage_note,
       spelling, 0 as variant_level, 0 as legacy_level,
       cast(null as smallint) as lemma_variant_level, cast(null as smallint) as derived_variant_level,
       word,
       lemma_rank, entry_rank
  from scowl_override
  left join words using (word_id)
  left join groups using (group_id)
  left join base_poses using (base_pos)
  left join (select spelling from spellings) as s on spelling = '_'
;

create view scowl_ as
select *, false as override from _scowl_main
union all
select *, true as override from _scowl_override;
select * from scowl_ limit 0;

create view scowl_v0 as
  select level, category, region, tag, pos, base_pos, pos_category, pos_class, usage_note, override, spelling, variant_level, legacy_level, word
  from scowl_;
select * from scowl_v0 limit 0;

create view duplicate_derived_view as
with duplicate_derived as (
  select word
   from (select (select max(cluster_id) from clusters where cluster_id <= group_id) as cluster_id, word
           from words
           join (select word_id as lemma_id, word as lemma from words) as lemmas using (lemma_id)
          where word_id != lemma_id) as q
   group by word
   having count (distinct cluster_id) > 1
), s as (
  select cluster_id, group_id, word, level, variant_level
    from scowl_ join cluster_map using (group_id)
    where word_id != lemma_id and word in (select * from duplicate_derived))
select distinct b.group_id, word
  from s a join s b using (word)
  where a.cluster_id != b.cluster_id and (a.level < b.level or (a.level = b.level and a.variant_level <= b.variant_level));
select * from duplicate_derived_view limit 0;

commit;
