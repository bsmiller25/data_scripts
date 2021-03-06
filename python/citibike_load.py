'''

load the citibike trips data to psql
load the citibike stations data to psql

'''
import datetime
import glob
import pandas as pd
import sqlalchemy as sql
import subprocess
import os

# make sure we are at the top of the repo
wd = subprocess.check_output('git rev-parse --show-toplevel', shell=True)
os.chdir(wd[:-1])  # -1 removes \n

# sql connection
engine = sql.create_engine('postgresql://localhost:5432/nyc')

stations = pd.DataFrame()
# import each file and push each file
print('Loading Citi Bike Data to python')
for f in glob.glob(wd[:-1].decode("utf-8")+'/data/citibike*'):
    print('Loading: ' + f)
    print(str(datetime.datetime.now()))
    new_month = pd.read_csv(f)
    new_month.columns = [i.lower().replace(' ', '') for i in new_month.columns]
    print('Converting datetimes')
    try:
        new_month['starttime'] = pd.to_datetime(new_month['starttime'],
                                                format='%m/%d/%Y %H:%M:%S')
    except:
        try:
            new_month['starttime'] = pd.to_datetime(new_month['starttime'])
        except: 
            raise ValueError('Weird datetime')
    try:
        new_month['stoptime'] = pd.to_datetime(new_month['stoptime'],
                                               format='%m/%d/%Y %H:%M:%S')
    except:
        try:
            new_month['stoptime'] = pd.to_datetime(new_month['stoptime'])
        except:
            raise ValueError('Weird datetime')
    new_month.to_sql('citibike_trips',
                     con=engine,
                     if_exists='append',
                     index=False)
    new_stations = new_month[['startstationid',
                              'startstationname',
                              'startstationlatitude',
                              'startstationlongitude']].drop_duplicates()
    new_stations.columns = ['id', 'name', 'lat', 'lon']
    stations = pd.concat((stations, new_stations)).drop_duplicates()

# write stations table to psql
print('Writing citibike stations table to psql')
stations.to_sql('citibike_stations',
                con=engine,
                if_exists='replace',
                index=False)

