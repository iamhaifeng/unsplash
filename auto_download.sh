#!/bin/sh
. /etc/profile

TEMP_JSON=/dev/shm/temp_json
RAW_URL_FILE=/dev/shm/raw_url_file
PAGE_NO=1

#No limit
CLIENT_ID=fa60305aa82e74134cabc7093ef54c8e2c370c47e73152f72371c828daedfcd7

rm -f $TEMP_JSON $RAW_URL_FILE

for PAGE_NO in {1..10}
do
    #wget -O $TEMP_JSON "https://api.unsplash.com/photos/?client_id=${CLIENT_ID}&per_page=10&page=${PAGE_NO}"
    #wget -O $TEMP_JSON "https://api.unsplash.com/search/photos?client_id=${CLIENT_ID}&per_page=10&page=${PAGE_NO}&query=Wallpape
rs desktop"
    wget -O $TEMP_JSON "https://api.unsplash.com/photos/random?client_id=${CLIENT_ID}&count=10&query=Wallpapers desktop"
    FLAG=$?
    if [[ $FLAG -eq 0 ]]
    then
        #jq ".[]|select(.height < .width)" $TEMP_JSON | jq -r .urls.raw >> ${RAW_URL_FILE}
        #jq ".results|.[]" $TEMP_JSON | jq "select(.height < .width)" | jq -r .urls.raw >> ${RAW_URL_FILE}
        jq ".[]" $TEMP_JSON | jq "select(.height < .width)" | jq -r .urls.raw >> ${RAW_URL_FILE}
    fi
    if [[ `cat ${RAW_URL_FILE} | wc -l` -ge 20 ]]
    then
        break
    fi
    #((PAGE_NO=PAGE_NO+1))
done

if [[ `cat ${RAW_URL_FILE} | wc -l` -ge 10 ]]
then
    rm -f $HOME/unsplash/photo/*
fi

cd $HOME/unsplash/photo/
cat $RAW_URL_FILE | while read URL
do
    #PHOTO_NAME=$(echo `echo $URL|cut -c "29-57"`".jpg")
    TEMP=${URL#*com/}
    PHOTO_NAME=${TEMP%\?*}".jpg"
    #wget -O $PHOTO_NAME "${URL}&fm=jpg&fit=scale&w=1440&h=900&q=85"
    wget -O $PHOTO_NAME "${URL}&fm=jpg&w=1440&q=85"
    FLAG=$?
    if [[ $FLAG -ne 0 ]]
    then
        rm -f $PHOTO_NAME
    fi
    sleep 10
done

if [[ `ls *.jpg|wc -l` -ge 5 ]]
then
    CMD_DEL="mdelete *"
else
    CMD_DEL="bin"
fi

#Auto FTP
ftp  -n  << !
open *IP*
user photo *password*
prompt off
$CMD_DEL
bin
lcd $HOME/unsplash/photo/
mput *
!
