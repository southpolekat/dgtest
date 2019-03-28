create schema dgtest;
set search_path = dgtest;

create table tt (i int, x xml)
distributed by (i);


insert into tt values (1, '<Root><Sub>1</Sub><Sub>2</Sub></Root>');
insert into tt values (2, '<Root><Sub>3</Sub><Sub>4</Sub></Root>');

select * from tt;

select xmlagg(x) from tt;

select xml_is_well_formed(x::text) from tt;

select unnest(xpath('.//Sub/text()', x::xml)) from tt;
select xmlelement(name foo);

select xmlconcat('<?xml version="1.1"?><foo/>', '<?xml version="1.1"?><bar/>');

drop schema dgtest cascade;
