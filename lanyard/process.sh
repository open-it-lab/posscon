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
mkdir mecard/
mkdir qrcode/

if [[ $3 ]]; then
    tail -n $3 $1 > reg-temp.csv
else
    # skip first line
    tail -n +2 $1 > reg-temp.csv
fi

file=reg-temp.csv

# the indices here correspond to the csv column where the data is
# kept; notice that the format is actually simicolon-delimited files,
# so check that the input does not have semicolons in it, or quotes
# for that matter
while read p; do
    # fname=`echo $p | awk -F\; '{print $6}'`
    # lname=`echo $p | awk -F\; '{print $5}'`
    # org=`echo $p | awk -F\; '{print $7}'`
    # title=`echo $p | awk -F\; '{print $28}'`
    # email=`echo $p | awk -F\; '{print $17}'`
    # phone=`echo $p | awk -F\; '{print $16}'`
    # city=`echo $p | awk -F\; '{print $12}'`
    # state=`echo $p | awk -F\; '{print $13}'`
    # lname=`echo $p | awk -F\; '{print $1}'`
    # lname=`echo $p | awk -F\; '{gsub("'\''", "\\'\''");print $1}'`
    # fname=`echo $p | awk -F\; '{gsub("'\\''", "\\\\'\\''");print $2}'`
    lname=`echo $p | awk -F\; '{print $1}'`
    lnameclean=`echo "$lname" | sed 's/[^a-zA-Z0-9]//g'`
    fname=`echo $p | awk -F\; '{print $2}'`
    phone=`echo $p | awk -F\; '{print $3}'`
    email=`echo $p | awk -F\; '{print $4}'`
    org=`echo $p | awk -F\; '{gsub("&", "\\\\\\\\&");print $5}'`
    title=`echo $p | awk -F\; '{print $6}'`
    titleclean=`echo "$title" | sed 's/[^a-zA-Z0-9]//g'`

    h=`echo "$fname$lname$phone$email$org$title" | md5sum | awk '{print $1}'`

    # skip files for which we've already generated lanyards
    if [ -f "output/$titleclean-$lnameclean-$h.pdf" ] ; then
        continue
    fi

    echo "MECARD:N:$fname $lname;ORG:$org;TEL:$phone;EMAIL:$email;;" > mecard/$h.mecard

    # dump vcard to file
#     echo "BEGIN:VCARD
# VERSION:2.1
# N:$lname;$fname
# FN:$fname $lname
# TITLE:$title
# ORG:$org
# ADR;HOME:;;;$city;$state
# TEL;CELL:$phone
# EMAIL:$email
# END:VCARD" > vcard/$h.vcard

    # qrencode -o qrcode/$h.png -s 50 < vcard/$h.vcard
    qrencode -o qrcode/$h.png -s 50 < mecard/$h.mecard
    mogrify -shave 200x200 qrcode/$h.png

    if [[ $title = "SPEAKER" ]]; then
        ./lanyard.sh output/$titleclean-$lnameclean-$h "$fname" "$lname" "$title" "$org" qrcode/$h.png fig/speaking
    else
        ./lanyard.sh output/$titleclean-$lnameclean-$h "$fname" "$lname" "$title" "$org" qrcode/$h.png fig/attending
    fi

    # use this to only run one at a time, for sanity checking
    # break

    if [[ $2 && "$2" = "true" ]]; then
        evince output/$titleclean-$lnameclean-$h.pdf
    fi

done < $file
