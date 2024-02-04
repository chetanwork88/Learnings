#/bin/bash

echo "Start Time : `date`"

#Master File Name
MASTER_FILE=orig.csv

#No Of Files in which the Original files will be splitted into
SPLIT_FILE_COUNT=5

#Port to Add
PORT_NO=(9091 9092 9093 9094 9095)

#CUST_ID_START and END Range
CUST_ID_START=100000
CUST_ID_END=200000

# Create Master File
CreateMasterFile()
{
    echo "Creating Master File ..."

    rm -f $MASTER_FILE
    while [ $CUST_ID_START -le $CUST_ID_END ]
    do
        echo "$CUST_ID_START" >> $MASTER_FILE
        CUST_ID_START=$((CUST_ID_START+1))
    done
}

AppendPortNo()
{
    echo "Appending the Port No to Customer ID ..."

    MSTR_FILE_BASE_NM=$(basename "$MASTER_FILE" .csv)
    PORT_APPND_FL_NAME=${MSTR_FILE_BASE_NM}_port_append.csv
    #echo "PORT_APPND_FL_NAME : $PORT_APPND_FL_NAME"
    rm -f $PORT_APPND_FL_NAME
    TMP_SPLIT_FL_NAME=temp_split_file_
    rm -f ${TMP_SPLIT_FL_NAME}*

    NO_OF_PORTS=${#PORT_NO[@]}

    idx=0
    while IFS= read -r LINE
    do
        echo "${LINE},${PORT_NO[$idx]}" >> $PORT_APPND_FL_NAME
        idx=$(( (idx + 1) % $NO_OF_PORTS ))
    done < "$MASTER_FILE"
}

SplitFiles()
{
    echo "Split master File ..."

    #Get No of records from file
    TOT_REC_CNT=`cat $PORT_APPND_FL_NAME | wc -l`
    echo "Total No Of records In Master File : $TOT_REC_CNT"

    #Records Per Spilt File
    SPLIT_CNT_REC=$((TOT_REC_CNT/SPLIT_FILE_COUNT))
    echo "No Of records per Split File : $SPLIT_CNT_REC"

    #Split the file
    split -l "$SPLIT_CNT_REC" "$PORT_APPND_FL_NAME" $TMP_SPLIT_FL_NAME

    #Rename file
    idx=0
    for TEMP_FILE in `ls -1 ${TMP_SPLIT_FL_NAME}*`
    do
        idx=$((idx + 1))
        #echo "Temp File : $TEMP_FILE"
        mv $TEMP_FILE ${MSTR_FILE_BASE_NM}_${idx}.csv
    done
}

#Create Master File
CreateMasterFile

#Append Port No
AppendPortNo

#Split File
SplitFiles

mkdir -p output
mv orig_* output/

echo "End Time : `date`"