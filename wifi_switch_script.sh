#!/bin/sh
set -x
#########################################
# version pre alpha
# all works manualy
# or even you can make the task for cron
# DESCRIPTION what this script do
# this script will switch automatically between known access points
# all you need is
# configure you router in client mode
# then if you wont create new one wifi AP on you router for share the signal (repeater)
# N.B.: not all routers can do that, it's depend's on that model of wifi chip you router have
# create configs for all known AP's in radius of you router
#
#
# DESCRIPTION variables
# KNOWN_APS is the names of the known Access Points separated by space
# KNOWN_CONFIGS is the full path of configs separated by space
#
#
#########################################

#scanning for AP's in range and writing output in file
#iwlist wlan0 scanning | grep -E "ESSID" . 2>&1 | tee /tmp/list_wifi.txt
iwlist wlan0 scanning | grep -E "ESSID" > /tmp/list_wifi.txt
sleep 3

echo 'cat /tmp/list_wifi.txt'

cat /tmp/list_wifi.txt

#if [ `grep -E "busy" /tmp/list_wifi.txt` ]; then
#    logger close script: Device or resource busy
#    exit 0
#fi

#define list of AP's
KNOWN_APS='wnr2000 TP-LINK_47'

for ap in $KNOWN_APS;
    do
        echo $ap >> /tmp/aps.txt
    done
APS_FILE='/tmp/aps.txt'

KNOWN_CONFIGS='wnr2000 tplink47'

for con in $KNOWN_CONFIGS;
    do
        echo $con >> /tmp/cnfs.txt
    done
CONFS_FILE='/tmp/cnfs.txt'


#loop for every known AP
for AP in `cat $APS_FILE`;
    do

        for CONFIG in `cat $CONFS_FILE`;
            do
                if [ -z `grep -E "$AP" /tmp/list_wifi.txt` ]; then
                    #if AP not found in /tmp/list_wifi.txt
                    #delete $AP from temporary array file /tmp/aps.txt
                    echo $AP not found in /tmp/list_wifi.txt - - - deleting...
                    sed -i "s/\<$AP\>//g" $APS_FILE
#                    K_A=`cat /tmp/aps.txt`
#                    echo '$K_A'
#                    echo $K_A
#                    logger $AP deleted from /tmp/aps.txt
                    logger $AP deleted from $APS_FILE

                    #delete $CONFIG from temporary array file /tmp/cnfs.txt
                    sed -i "s/\<$CONFIG\>//g" $CONFS_FILE
#                    CNFS=`cat /tmp/cnfs.txt`
#                    echo '$CNFS'
#                    echo $CNFS
#                    logger $CONFIG deleted from /tmp/cnfs.txt
                    logger $CONFIG deleted from $CONFS_FILE


                    #delete name of AP from temporary array file /tmp/list_wifi.txt
#                    sed -i 's/\<$AP\>//g' /tmp/list_wifi.txt
#                    echo 'cat /tmp/list_wifi.txt'
#                    cat /tmp/list_wifi.txt
#                    logger $AP deleted from /tmp/list_wifi.txt

#                   exit 0

                elif [ -n `grep -E "$AP" /tmp/list_wifi.txt` ]; then
                    #if AP found in /tmp/list_wifi.txt
                    logger $AP found
                    logger $CONFIG used
                    logger restarting WIFI

                    cd /etc/config

                    cp $CONFIG wireless


                    sleep 1
                    wifi down
                    sleep 1
                    wifi up

                        #TODO add condition if internet connection established
                        #TODO exit only if internet connection established
                        exit 0
                fi
            done

    done

rm -rf $CONFS_FILE
rm -rf $APS_FILE
rm -rf /tmp/list_wifi.txt
