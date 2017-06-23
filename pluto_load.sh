#!/bin/bash

# download pluto data and push to psql
DIR="$(git rev-parse --show-toplevel)"
cd $DIR/data/

# download pluto data and push to psql
for b in bx bk mn qn si
do
    #download and unzip
    wget -O $b'pluto.zip' 'http://www1.nyc.gov/assets/planning/download/zip/data-maps/open-data/'$b'_mappluto_16v2.zip'
    unzip -o -d $b'pluto/' $b'pluto.zip'

    # if table exists, drop it
    if psql nyc -t -A -c 'SELECT * FROM pg_catalog.pg_tables' | grep -qw $b'mappluto'; then
        psql nyc -q -c 'DROP TABLE '$b'mappluto'
    fi

    # write new table to psql
    echo 'writing '$b' to sql -- this takes a minute'
    shp2pgsql $b'pluto/'${b^^}'MapPLUTO.shp' | psql -q -d nyc 

    # clean up
    echo 'cleaning up '$b
    rm -r $b'pluto'
    rm $b'pluto.zip'
    echo 'complete '$b

done

