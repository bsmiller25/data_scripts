import xmltodict
import glob
import datetime
import sqlalchemy as sql
import pandas as pd
import subprocess
import os

# make sure we are at the top of the repo
wd = subprocess.check_output('git rev-parse --show-toplevel', shell = True)
os.chdir(wd[:-1]) #-1 removes \n

# connect to sql
engine = sql.create_engine('postgresql://localhost:5432/nyc')

# XML parser
def parse_spending(f):    
    # read in xml file
    with open(f) as fd:
        doc = xmltodict.parse(fd.read())
    # parse
    transactions = doc['response']['result_records']['spending_transactions']['transaction']
    cols = [k for k in transactions[0].keys()]
    file_transactions = pd.DataFrame()
    for t in transactions:
        new = pd.DataFrame()
        for c in cols:
            new[c] = [t[c]]
        file_transactions = pd.concat([file_transactions, new])    
    return(file_transactions)


print('Parsing file at: ' + datetime.datetime.now().strftime('%H:%M:%S'))
df = parse_spending('./data/spending/spending.xml')
df.to_sql('capital_spending', engine, if_exists='append', index = False)
