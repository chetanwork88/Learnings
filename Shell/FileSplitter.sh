#!/bin/bash

echo "Start Time : $(date)"

#Master File Name
MASTER_FILE=orig.csv

# No Of Files in which the Original files will be split into
SPLIT_FILE_COUNT=5

# Split File Names
SPLIT_FILE_NAME_ARR=("split_11.csv" "split_12.csv" "split_13.csv" "split_14.csv" "split_15.csv")

# Port to Add
PORT_NO_ARR=(9091 9092 9093 9094 9095)

# CUST_ID_START and END Range
CUST_ID_START=1
CUST_ID_END=10

OUTPUT=output/
mkdir -p "$OUTPUT"

#Validate User Input
ValidateInput()
{
    echo "  Validating User Input"

    NO_OF_SPLIT_FILES=${#SPLIT_FILE_NAME_ARR[@]}
    if [ $SPLIT_FILE_COUNT -ne $NO_OF_SPLIT_FILES ]
    then
        echo "    Error - Split File Name (SPLIT_FILE_NAME_ARR) and File Count (SPLIT_FILE_COUNT) does not match."
        exit 1
    fi
}

# Create Master File
CreateMasterFile()
{
    echo "  Creating Master File ..."

    rm -f $MASTER_FILE

    seq $CUST_ID_START $CUST_ID_END > $MASTER_FILE
}

AppendPortNo()
{
    echo "  Appending the Port No to Customer ID ..."

    MSTR_FILE_EXTN="${MASTER_FILE##*.}"
    echo "    MSTR_FILE_EXTN : $MSTR_FILE_EXTN"

    MSTR_FILE_BASE_NM=$(basename "$MASTER_FILE" .${MSTR_FILE_EXTN})
    echo "    MSTR_FILE_BASE_NM : $MSTR_FILE_BASE_NM"

    PORT_APPND_FL_NAME=${MSTR_FILE_BASE_NM}_port_append.${MSTR_FILE_EXTN}
    echo "    PORT_APPND_FL_NAME : $PORT_APPND_FL_NAME"

    TMP_SPLIT_FL_NAME=temp_split_file_
    rm -f ${TMP_SPLIT_FL_NAME}*

    NO_OF_PORTS=${#PORT_NO_ARR[@]}

    idx=0
    while IFS= read -r LINE
    do
        echo "${LINE},${PORT_NO_ARR[$idx]}" >> $PORT_APPND_FL_NAME
        idx=$(( (idx + 1) % $NO_OF_PORTS ))
    done < "$MASTER_FILE"
}

SplitFiles()
{
    echo "  Split master File ..."

    # Get No of records from file
    TOT_REC_CNT=$(wc -l < "$PORT_APPND_FL_NAME")
    echo "    Total No Of records In Master File : $TOT_REC_CNT"

    #Records Per Spilt File
    SPLIT_CNT_REC=$((TOT_REC_CNT/SPLIT_FILE_COUNT))
    echo "    No Of records per Split File : $SPLIT_CNT_REC"

    #Split the file
    split -l "$SPLIT_CNT_REC" "$PORT_APPND_FL_NAME" $TMP_SPLIT_FL_NAME
}

RenameSplitFiles()
{
    echo "  Renaming splitted Files ..."
    
    #Rename file
    idx=0
    for TEMP_FILE in `ls -1 ${TMP_SPLIT_FL_NAME}*`
    do
        #SPLIT_FILE_NAME=${MSTR_FILE_BASE_NM}_${idx}.${MSTR_FILE_EXTN}
        SPLIT_FILE_NAME=${SPLIT_FILE_NAME_ARR[$idx]}
        echo "    Split File Name: $SPLIT_FILE_NAME"
        mv $TEMP_FILE $SPLIT_FILE_NAME
        idx=$((idx + 1))
    done
}

#Validate Input
ValidateInput

#Create Master File
CreateMasterFile

#Append Port No
AppendPortNo

#Split File
SplitFiles

#Rename Split File Names
RenameSplitFiles

mv *.${MSTR_FILE_EXTN} $OUTPUT

echo "End Time : `date`"