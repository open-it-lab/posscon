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

# variables
gravatar=true

# use separate directories so that the job is parallelizable
mkdir output/
mkdir vcard/
mkdir mecard/
mkdir qrcode/
mkdir img/

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
    lname=`echo $p | awk -F\; '{print $1}'`
    lnameclean=`echo "$lname" | sed 's/[^a-zA-Z0-9]//g'`
    fname=`echo $p | awk -F\; '{print $2}'`
    phone=`echo $p | awk -F\; '{print $3}'`
    email=`echo $p | awk -F\; '{print $4}'`
    org=`echo $p | awk -F\; '{gsub("&", "\\\\\\\\&");print $5}'`
    title=`echo $p | awk -F\; '{print $6}'`
    limited=`echo $p | awk -F\; '{print $7}'`
    titleclean=`echo "$title" | sed 's/[^a-zA-Z0-9]//g'`

    limitedfull=""
    if [[ "$limited" = "W" ]] ; then
        limitedfull="Wednesday"
    elif [[ "$limited" = "T" ]] ; then
        limitedfull="Thursday"
    else
        limitedfull=""
    fi    

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
# TITLE:$title" > vcard/$h.vcard

#     emailhash=`echo -n $email | md5sum | awk '{print $1}'`
#     echo $emailhash
#     echo "curl -I  --stderr /dev/null http://www.gravatar.com/avatar/$emailhash?d=404 | head -1 | cut -d' ' -f2"
#     echo `curl -I  --stderr /dev/null http://www.gravatar.com/avatar/$emailhash?d=404 | head -1 | cut -d' ' -f2`
#     if [[ "`curl -I  --stderr /dev/null http://www.gravatar.com/avatar/$emailhash?d=404 | head -1 | cut -d' ' -f2 | sed 's/[^a-zA-Z0-9]//g'`" != "404" ]] ; then
#         echo "PHOTO;JPEG:http://www.gravatar.com/avatar/$emailhash" >> vcard/$h.vcard
#     fi

#     echo "ORG:$org
# ADR;HOME:;;;$city;$state
# TEL;CELL:$phone
# EMAIL:$email
# END:VCARD" >> vcard/$h.vcard



#     echo "BEGIN:VCARD
# VERSION:3.0
# N:$lname;$fname
# FN:$fname $lname
# ORG:$org" > vcard/$h.vcard

#     emailhash=`echo -n $email | md5sum | awk '{print $1}'`
#     if [[ "`curl -I  --stderr /dev/null http://www.gravatar.com/avatar/$emailhash?d=404 | head -1 | cut -d' ' -f2 | sed 's/[^a-zA-Z0-9]//g'`" != "404" ]] ; then
#         echo "PHOTO;VALUE=URL;TYPE=JPEG:http://www.gravatar.com/avatar/$emailhash" >> vcard/$h.vcard
#     fi

#     echo "TEL;TYPE=CELL:$phone
# EMAIL;TYPE=PREF,INTERNET:$email
# END:VCARD" >> vcard/$h.vcard

    # qrencode -o qrcode/$h.png -s 50 < vcard/$h.vcard
    qrencode -o qrcode/$h.png -s 50 < mecard/$h.mecard
    mogrify -shave 200x200 qrcode/$h.png

    emailhash=`echo -n $email | md5sum | awk '{print $1}'`
    if [[ "$gravatar" == "true" && "`curl -I  --stderr /dev/null http://www.gravatar.com/avatar/$emailhash?d=404 | head -1 | cut -d' ' -f2 | sed 's/[^a-zA-Z0-9]//g'`" != "404" ]] ; then
        wget "http://www.gravatar.com/avatar/$emailhash?s=500" -O "img/$h.png"
        badgename="img/$h.png"
    elif [[ $title = "SPEAKER" ]]; then
        badgename="fig/speaking"
    else
        badgename="fig/attending"
    fi

    ./lanyard.sh output/$titleclean-$lnameclean-$h "$fname" "$lname" "$title" "$org" qrcode/$h.png $badgename "$limitedfull"

    # use this to only run one at a time, for sanity checking
    # break

    if [[ $2 && "$2" = "true" ]]; then
        evince output/$titleclean-$lnameclean-$h.pdf
    fi

done < $file
