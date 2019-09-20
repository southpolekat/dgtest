drop table if exists meal_xml;

create table meal_xml ( i int, meal xml)
distributed by (i);

insert into meal_xml values (1,
'<meal size="big" price="10">
    <drink>coke</drink>
    <food>burger</food>
    <dessert>
        <fruit>apple</fruit>
        <fruit>grape</fruit>
    </dessert>
</meal>');

insert into meal_xml values(2,
'<meal price="5">
    <food>noodle</food>
</meal>');

select i, xpath('/', meal) from meal_xml;
select i, xpath('food', meal) from meal_xml;
select i, xpath('/meal/food', meal) from meal_xml;
select i, xpath('//fruit', meal) from meal_xml;
select i, xpath('//fruit/text()', meal) from meal_xml;
select i, xpath('@size', meal) from meal_xml;
select i, xpath('/meal/@size', meal) from meal_xml;
select i, xpath('/meal[@size="big"]', meal) from meal_xml;
select i, xpath('/meal[@price<9]', meal) from meal_xml;
