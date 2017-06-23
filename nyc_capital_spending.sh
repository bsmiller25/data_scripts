#!/bin/bash

# nyc_capital_spending.sh
# This script downloads and stores NYC capital spending data
# from Checkbook NYC

# It takes a long time to run 

start=$(date +'%T')
echo "Start at: $start"

# make sure we are at the top of the git directory
REPOLOC="$(git rev-parse --show-toplevel)"
cd $REPOLOC

mkdir -p $REPOLOC/data/spending

# if exists, drop table:
if psql nyc -t -A -c 'SELECT * FROM pg_catalog.pg_tables' | grep -qw capital_spending; then
    psql nyc -c 'DROP table capital_spending;'
fi

### define function

spend2psql ()
{ # This function downloads, parses, and pushes to psql
    
    echo "Downloading XML #$1 starting with record #$2"
    wget -q -O $REPOLOC/data/spending/spending.xml --post-data "<request><type_of_data>Spending</type_of_data><records_from>$2</records_from><search_criteria><criteria><name>spending_category</name><type>value</type><value>cc</value></criteria></search_criteria></request>" http://www.checkbooknyc.com/api 
    
    # if there are no results, stop
    if grep -q 'no results' $REPOLOC/data/spending/spending.xml; then
        stop=10
        rm $REPOLOC/data/spending/spending.xml
        echo "No Results. Stopping"
    fi

    # otherwise, push to psql
    echo 'Parsing XML and writing to sql...'
    python $REPOLOC/python/spending.py

    # if the python script broke, return before
    if [ "$?" -ne 0 ]; then echo "Python script failed"; return 1; fi

    # remove file
    rm $REPOLOC/data/spending/spending.xml

} # end of function

stop=0
rec=1
i=1

# loop through downloading and pushing xmls until we reach the end
while [ $stop -lt 1 ] #&& [ $i -lt 5 ] 
do
    # do next file
    spend2psql $i $rec
    if [ "$?" -ne 0 ]; then
        echo "Failed for file #$i starting with record #$rec"
        echo "Retrying"
        spend2psql $i $rec
        if [ "$?" -ne 0 ]; then
            echo "Failed a second time"
            echo "Exiting"
            exit 1
        fi
    fi
    # increment
    i=$[$i+1]
    rec=$[$rec+1000]
done

# complete
end=$(date +'%T')
echo "Finished at: $end"
