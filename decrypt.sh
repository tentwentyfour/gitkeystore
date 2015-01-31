#!/bin/bash

####
#
# Decrypt files
# License: GPL v3
#
##

READONLY=true
FILE=$1


while getopts ":e" opt; do
    case $opt in
        e)
            READONLY=false
            FILE=$2
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

if [ -z $FILE ]; then
    echo "Usage: $0 [-e] filename.asc"
    echo "Use the -e flag if you want to edit the file, not only view."
    echo "It will create a plain-text file and remove the .asc file"
    exit 1
fi

# Remove the file extension from the decrypted destination filename
DEST=${FILE%%.asc}

if $READONLY; then
    gpg -d $FILE
else
    gpg -o $DEST -d $FILE && rm $FILE
fi

