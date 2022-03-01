
# airodump-ng automation, even for very distance networks.
================================
 # Auto-Airattack instruction #
================================

# 1a #
Copy chosen interface and save -> <iface>
example -> wlan0

# 1b #
Create a monitor mode with -> airmon or iw ? (a/w)

Warning !!! -> Don't supported air monitor mode, use -> put the iw
solution-> airmon-ng stop <iface> and/or exit, restart the script

# 2 #
(stop scanning Press -> ctrl + c)
Copy traget MAC and save -> <BSSID>
example -> 1A:2B:3C:4D:5E:6F

# 3 #
Write attack time -> <xy>m <xy>s or <xy>s/m
example: nearby -> 1m, almost distant -> 10m, very distant -> 30m

# 4 #
Begin target network monitoring -> aireplay attack after set time

Warning !!! There may be a problem starting the airodump-ng due to multiple command entries...
(xterm window exits immediately or does not appear)
solution -> just exit and restart the script

No problem, if create multiple numbered files, it will automatically find the next one!

The attack time can be changed manually in the script.
(configured for "almost distant" networks by default)
(example -> "nearby" networks, it is sufficient to limit the aireplay attack from 8 to 5, and mdk4 to well below 10-15)
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _

Install:

git clone https://github.com/OutsiderLost/Auto-Airattack

cd Auto-Airattack

chmod +x *.sh

(run)
./Auto-Airattack.sh
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
