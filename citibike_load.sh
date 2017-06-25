#!/bin/bash

DIR="$(git rev-parse --show-toplevel)"

# load Citi Bike Data and push to psql

# 2016 Citi Bike Data
for m in $(seq -w 5 12)
do
  curl -o $DIR/data/citibike_2016$m.zip https://s3.amazonaws.com/tripdata/2016$m-citibike-tripdata.zip
  unzip -o $DIR/data/citibike_2016$m.zip -d $DIR/data/ 
  mv $DIR/data/2016$m-citibike-tripdata.csv $DIR/data/citibike_2016$m.csv 
  rm $DIR/data/citibike_2016$m.zip
done

# 2017 Citi Bike Data
for m in $(seq 1 3)
do 
  curl -o $DIR/data/citibike_20170$m.zip https://s3.amazonaws.com/tripdata/20170$m-citibike-tripdata.csv.zip
  unzip -o $DIR/data/citibike_20170$m.zip -d $DIR/data/ 
  mv $DIR/data/20170$m-citibike-tripdata.csv $DIR/data/citibike_20170$m.csv
  rm $DIR/data/citibike_20170$m.zip
done

# push the Citi Bike Data to psql
python $DIR/python/citibike_load.py

# update permissions and geometries
echo 'Updating permissions and geometries for Citi Bike tables'
psql nyc -f $DIR/sql/citibike_load.sql

# clean up
#rm $DIR/data/citibike*

# done
echo 'Citi Bike data loaded to psql'
