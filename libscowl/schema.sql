begin;

--
-- constant tables
--
-- the tables are populated using constdata.sql
--

create table poses (
  order_num integer not null unique,
  pos text not null primary key,
  base_pos text not null references base_poses(base_pos) deferrable initially deferred,
  pos_category text not null check (pos_category in ('', 'special', 'wordpart', 'nonword')),
  descr text,
  note text,
  extra_info text
) without rowid;

create table base_poses (
  order_num integer not null unique,
  base_pos text not null primary key,
  lemma_pos text references poses(pos),
  pos_category text not null check (pos_category in ('', 'special', 'wordpart', 'nonword')),
  descr text,
  extra_info text
) without rowid;

create table ranks (
  order_num integer not null unique,
  rank_symbol text not null primary key,
  rank_descr text
) without rowid;

create table variant_levels (
  variant_level integer primary key check (0 <= variant_level and variant_level <= 9),
  variant_symbol text not null unique,
  variant_descr text,
  legacy_level integer not null
);

create table regions (
  order_num not null unique,
  region text not null primary key,
  region_descr text
) without rowid;

create table spellings (
  order_num not null unique,
  spelling text not null primary key,
  region text not null references regions(region),
  spelling_descr text not null
) without rowid;

--
-- normal tables
--

create table groups (
  group_id integer primary key,
  base_pos text not null references base_poses(base_pos),
  pos_class text not null default '',
  defn_note text not null default '',
  usage_note text not null default '',
  lemma_rank text not null default '' references ranks(rank_symbol)
);

create table words (
  word_id integer primary key,
  group_id integer not null references groups(group_id) on delete cascade,
  lemma_id integer not null references words(word_id),
  pos text not null references poses(pos),
  word text not null,
  entry_rank text default null references ranks(rank_symbol)
);

create unique index words_lemma on words(group_id, word) where word_id = lemma_id;
create index words_lemma_id on words(lemma_id);
create index words_word on words (word);
create index words_idx on words (group_id, pos);

create table lemma_variant_info (
  lemma_id integer not null references words(word_id) on delete cascade,
  spelling text not null references spellings(spelling),
  variant_level smallint not null default 0 references variant_levels(variant_level),
  primary key (lemma_id, spelling)
) without rowid;

create table derived_variant_info (
  word_id integer not null references words(word_id) on delete cascade,
  spelling text not null default '_' references spellings(spelling),
  variant_level smallint not null references variant_levels(variant_level),
  primary key (word_id, spelling)
) without rowid;

create table scowl_data (
  level integer not null check(5 <= level and level <= 95),
  category text not null default '',
  region text not null default '' references regions(region),
  tag text not null default '',
  group_id integer not null references groups(group_id) on delete cascade,
  pos text not null references poses(pos),
  --foreign key (group_id, pos) references words(group_id, pos),
  primary key (level, region, category, tag, group_id, pos)
) without rowid;
create index scowl_data_index on scowl_data(group_id, pos);

create table scowl_override (
  level integer not null check(5 <= level and level <= 95),
  category text not null default '',
  region text not null default '' references regions(region),
  tag text not null default '',
  word_id integer not null references words(word_id),
  primary key (level, region, category, tag, word_id)
) without rowid;
create index scowl_override_index on scowl_override(word_id);

create table cluster_comments (
  headword text not null primary key,
  other_words text not null,
  comment text not null
);

create table group_comments (
  group_id integer not null references groups(group_id) on delete cascade,
  word text not null,
  other_words text not null,
  comment text not null,
  primary key (group_id, word)
);

create table lemma_comments (
  lemma_id integer not null references words(word_id) on delete cascade,
  order_num int not null,
  comment text,
  primary key (lemma_id, order_num)
);

--
-- extra tables
--  
-- these tables are populated when exporting but not used when importing
--

create table clusters (
  cluster_id integer primary key
);

create table pos_classes (
  pos_class not null primary key
) without rowid;

create table usage_notes (
  usage_note not null primary key
) without rowid;

create table categories (
  category text not null primary key
) without rowid;

create table tags (
  tag text not null primary key
) without rowid;

--
-- materialized views
--
-- populate by using corresponding view that doesn't end in '_mview'
--

create table cluster_map (
  group_id integer not null primary key,
  cluster_id integer not null
);
create index cluster_map_idx on cluster_map(cluster_id);

create table duplicate_derived (
  group_id integer not null,
  word text not null,
  primary key (group_id, word)
) without rowid;

create table variant_info (
  word_id integer not null,
  spelling text not null,
  variant_level smallint not null,
  lemma_variant_level,
  derived_variant_level,
  primary key (word_id, spelling)
) without rowid;

--
-- internal tables
--

create table _variables (
  var text not null primary key,
  val text
);

create table _combined (
  group_id integer primary key,
  other_id integer not null 
);

--
--
--

commit;
