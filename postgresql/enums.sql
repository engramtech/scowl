create type pos as enum ('?','c','pp','d','i','n0','ns','nss','np','nsp','nssp','v0','vd','vd2','vn','vg','vs','vs2','vs3','vs4','m0','ms','aj0','aj1','aj2','av0','av1','av2','a0','a1','a2','pn0','pn1','pns','pnd','pnp','pnr0','pnrs','ds','d1','d2','abbr','s','pre','suf','wp','we','wes','wep','weps','x');
create type base_pos as enum ('','n_v','aj_av','n','v','m','aj','av','a','pn','c','pp','d','i','d1','d2','abbr','s','pre','suf','wp','we','x');
create type rank_symbol as enum ('','*','-','@','~','!');
create type variant_symbol as enum ('','.','=','?','v','~','V','-','@','x');
create type region as enum ('','US','GB','CA','AU');
create type spelling as enum ('_','A','B','Z','C','D');
