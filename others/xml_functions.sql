SELECT XMLPARSE (DOCUMENT '<?xml version="1.0"?><book><title>Manual</title><chapter>1</chapter></book>');

SELECT XMLPARSE (CONTENT '<book><title>Manual</title><chapter>1</chapter></book>');


SELECT '<foo>bar</foo>'::xml;
SELECT xml '<foo>bar</foo>';

SELECT xmlserialize ( CONTENT '<foo>bar</foo>' AS char(14));
SELECT xmlserialize ( CONTENT '<foo>bar</foo>' AS varchar);
SELECT xmlserialize ( CONTENT '<foo>bar</foo>' AS text );

SET XML option CONTENT;	-- default
SET XML option DOCUMENT;

SELECT xpath('/my:a/text()', '<my:a xmlns:my="http://example.com">test</my:a>',
             ARRAY[ARRAY['my', 'http://example.com']]);


DROP TABLE IF EXISTS meal_xml;
CREATE TABLE meal_xml ( meal xml ) ;
INSERT INTO meal_xml values ('<meal><drink>coke</drink><food>burger</food><food>fries</food></meal>');
SELECT xpath('//drink', meal) from meal_xml;
SELECT xpath('/meal/drink', meal) from meal_xml;
SELECT xpath('/meal/drink/text()', meal) from meal_xml;
SELECT xpath('//food/text()', meal) from meal_xml;
SELECT xpath_exists('/meal/food', meal) from meal_xml;
SELECT xpath_exists('/meal/dessert', meal) from meal_xml;


SELECT xmlcomment('hello');

SELECT xmlconcat('<a>1</a>', '<b>2</b>');

SELECT xmlelement(name a);

SELECT xmlelement(name a, xmlattributes('x' as y));

SELECT xmlelement(name a, xmlattributes('x' as y), '1', '2', '3');

SELECT xmlforest(1 as a, 2 as b);

SELECT xmlpi(name php, 'echo "hello";');

SELECT xmlroot(xmlparse(document '<?xml version="1.1"?><content>abc</content>'),
               version '1.0', standalone yes);

INSERT INTO meal_xml values ('<meal><dessert>ice-cream</dessert></meal>');
SELECT xmlagg(meal) from meal_xml; 

SELECT xmlexists('//drink[text() = ''coke'']' PASSING BY REF meal) from meal_xml;

SELECT xml_is_well_formed('<a>1</a>');
SELECT xml_is_well_formed_content('<a>1</a>');
SELECT xml_is_well_formed_document('<a>1</a>');
