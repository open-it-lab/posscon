#!/bin/bash

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -lt $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` csv-to-process [show-pdf] [last-n]"
  echo ""
  echo "csv-to-process: the name of the csv file"
  echo "show-pdf: either true or false, indicating that the pdf should be displayed after every run"
  echo "last-n: the last n-number of csv rows should be checked, all if left off"
  exit $E_BADARGS
fi

# use separate directories so that the job is parallelizable
mkdir output/
mkdir vcard/
mkdir qrcode/

if [[ $3 ]]; then
    tail -n $3 $1 > reg-temp.csv
    file=reg-temp.csv
else
    file=$1
fi

# the indices here correspond to the csv column where the data is
# kept; notice that the format is actually simicolon-delimited files,
# so check that the input does not have semicolons in it, or quotes
# for that matter
while read p; do
    fname=`echo $p | awk -F\; '{print $6}'`
    lname=`echo $p | awk -F\; '{print $5}'`
    org=`echo $p | awk -F\; '{print $7}'`
    title=`echo $p | awk -F\; '{print $28}'`
    email=`echo $p | awk -F\; '{print $17}'`
    phone=`echo $p | awk -F\; '{print $16}'`
    city=`echo $p | awk -F\; '{print $12}'`
    state=`echo $p | awk -F\; '{print $13}'`

    h=`echo "$fname$lname$org$title$email$phone$city$state" | md5sum | awk '{print $1}'`

    # skip files for which we've already generated lanyards
    if [ -f "output/$h.pdf" ] ; then
        continue
    fi

    # dump vcard to file
    echo "BEGIN:VCARD
VERSION:2.1
N:$lname;$fname
FN:$fname $lname
TITLE:$title
ORG:$org
ADR;HOME:;;;$city;$state
TEL;CELL:$phone
EMAIL:$email
END:VCARD" > vcard/$h.vcard

    qrencode -o qrcode/$h.png -s 50 < vcard/$h.vcard
    mogrify -shave 200x200 qrcode/$h.png

    ./lanyard.sh output/$h "$fname" "$lname" "$title" "$org" qrcode/$h.png

    # use this to only run one at a time, for sanity checking
    # break

    if [[ $2 && "$2" = "true" ]]; then
        evince output/$h.pdf
    fi

done < $file
