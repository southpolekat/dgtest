#!/bin/bash

db=dgtest$$
createdb $db
cwd=$(pwd)

psql -d $db -f ~/deepgreendb/share/postgresql/contrib/postgis-2.1/postgis.sql >/dev/null
psql -d $db -f ~/deepgreendb/share/postgresql/contrib/postgis-2.1/spatial_ref_sys.sql >/dev/null

tmpdir=/tmp/dgtest
link=https://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural
mkdir -p $tmpdir
cd $tmpdir
zip="ne_10m_admin_0_countries.zip ne_10m_populated_places.zip"
for f in $zip; do
    [ -f $f ] && continue
    wget $link/$f
    unzip $f
done

shp2pgsql -W LATIN1 \
    -s 4326 \
    ne_10m_admin_0_countries.zip \
    countries > countries.sql
psql -d $db -f countries.sql >/dev/null

shp2pgsql -W LATIN1 \
    -s 4326 \
    ne_10m_populated_places.zipi \
    places> places.sql
psql -d $db -f places.sql >/dev/null

psql -d $db <<END

\timing on

CREATE INDEX c_idx ON countries USING GIST ("geom");
CREATE INDEX p_idx ON places USING GIST ("geom");

-- Normal Spatial Join
SELECT count(*) as cnt, c.name
    FROM countries c
    JOIN places p
    ON ST_Intersects(c.geom, p.geom)
    GROUP BY c.name order by cnt desc limit 1;

-- Use DGIS_sj_Intersects
SELECT count(*) as cnt, c.name
    FROM countries c
    JOIN places p
    ON DGIS_sj_Intersects(c.geom, p.geom)
    GROUP BY c.name order by cnt desc limit 1;

END

cd $cwd
rm -rf $tmpdir

dropdb $db
