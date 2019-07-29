#!/bin/bash
# Created by Rich Blair (CompEng0001)
# Date created: 29/07/2019
# Version 2.1.0
# This script has been developed for the UoG students to setup their pis for the enterprise network @ the University of Greenwich
# To run this use bash /opt/Custom-Scripts/wpa_enterprise.sh
# github https://github.com/CompEng0001/RaspberryPiEnterpriseSetup

reset()
{
    echo "Your current wpa_supplicant and interfaces files will be reset"
    read -p 'are you sure Y/N: ' confirmation
    if [ ${confirmation^^} == "Y" ];
        then
        #wpa_supplicant file
        if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ];
        then
            sudo rm /etc/wpa_supplicant/wpa_supplicant.conf
	    echo -e "\033[0;31m Removed \033[0m '/etc/wpa_supplicant.conf'"
        fi
        if [ -f /etc/wpa_supplicant/wpa_supplicant.conf.bak ];
        then
            sudo mv -f /etc/wpa_supplicant/wpa_supplicant.conf.bak /etc/wpa_supplicant/wpa_supplicant.conf
	    echo -e "\033[0;35m Restored\033[0m '/etc/wpa_supplicant/wpa_supplicant.conf from /etc/wpa_supplicant/wpa_supplicant.conf.bak'"
        else
            sudo touch "/etc/wpa_supplicant/wpa_supplicant"
            sudo bash -c 'cat <<EOF> /etc/wpa_supplicant/wpa_supplicant.conf
            ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
            update_config=1
EOF'
            echo -e "\033[0;36m Created \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"
        fi

        #interfaces file
        if [ -f /etc/network/interfaces ];
        then
            sudo rm /etc/network/interfaces
            echo -e "\033[0;31m Removed \033[0m '/etc/network/interfaces'"
        fi
        if [ -f /etc/network/interfaces.bak ];
        then
            sudo mv -f /etc/network/interfaces.bak /etc/network/interfaces
	    echo -e "\033[0;35m Restored\033[0m 'etc/network/interfaces from /etc/network/interfaces.bak'"
        else
            sudo touch "/etc/network/interfaces"
            sudo bash -c 'cat /etc/network/interfaces
            # interfaces(5) file used by ifup(8) and ifdown(8)
            # te that this file is written to be used with dhcpcd
            # for static IP, consutlt /etc/dhcpcd.conf and 'man dhcpcd.conf'
            # include files from /etc/network/interfaces.d:
            source-directory /etc/network/interfaces.d

            auto lo
            iface lo inet loopback

            iface eth0 inet manual'
	    echo -e "\033[0;36m Created \033[0m '/etc/network/interfaces'"
        fi
    elif [ ${confirmation^^} == 'N' ];
    then
        echo "no further action required."
    else
        echo "You need to type Y or N, run the program again."
    fi
}

setupTwo()
{
    read -p 'Enter username@gre.ac.uk : ' USERNAME
    read -s -p 'Enter password : ' PASSWORD
    # SETUP WPA_SUPPLICANT
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ];
then
    sudo mv -f /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
    echo -e "\033[1;34m backedup\033[0m '/etc/wpa_supplicant/wap_supplicant.conf to /etc/wpa_supplicant/wpa_supplicant.conf.bak'"
else
    touch /etc/wpa_supplicant/wpa_supplicant.conf
    echo -e "\033[0;36m created \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"
fi

sudo bash -c 'cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf

ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="eduroam"
        pairwise=CCMP TKIP
        key_mgmt=WPA-EAP
        eap=PEAP
        phase2="auth=MSCHAPV2"
        identity="%%yourusername%%"
        anonymous_identity="%%yourusername%%"
        password="%%yourpassword%%"
        id_str="University"
        priority=3
    }
EOF'
sudo /bin/sed -i "s/%%yourusername%%/${USERNAME}/g" /etc/wpa_supplicant/wpa_supplicant.conf
sudo /bin/sed -i "s/%%yourpassword%%/${PASSWORD}/g" /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\033[1;33m updated \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"

#SETUP NETWORK INTERFACES
if [ -f /etc/network/interfaces ];
then
    sudo mv -f /etc/network/interfaces /etc/network/interfaces.bak
    echo -e "\033[1;34m backedup\033[0m '/etc/network/interfaces to /etc/network/interfaces.bak'"
else
    touch /etc/network/interfaces
    echo -e "\033[0;36m created \033[0m '/etc/network/interfaces'"
fi

sudo bash -c 'cat << EOF > /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d
auto lo 
iface lo inet loopback

auto eth0 
allow-hotplug eth0
iface eth0 inet manual 

auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-roam /etc/wpa_supplicant/wpa_supplicant.conf
iface defualt inet dhcp
        #pre-up wpa_supplicant -B Dwext -i wlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf
        #post-down killall -q wpa_supplicant
EOF'
echo -e "\033[1;33m updated \033[0m '/etc/network/interfaces'"
}

setupThreeB()
{
    read -p 'Enter username@gre.ac.uk : ' USERNAME
    read -s -p 'Enter password : ' PASSWORD
    # SETUP WPA_SUPPLICANT
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ];
then
    sudo mv -f /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
    echo -e "\033[1;34m backedup\033[0m '/etc/wpa_supplicant/wpa_supplicant.conf to /etc/wpa_supplicant/wpa_supplicant.conf.bak'"
else
    touch /etc/wpa_supplicant/wpa_supplicant.conf
    echo -e "\033[0;36m created \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"
fi

sudo bash -c 'cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="eduroam"
        pairwise=CCMP TKIP
        group=CCMP TKIP
        key_mgmt=WPA-EAP
        eap=PEAP
        phase1="peapelabel=0"
        phase2="auth=MSCHAPV2"
        identity="%%yourusername%%"
        anonymous_identity="%%yourusername%%"
        password="%%yourpassword%%"
        id_str="University"
        priority=3
    }
EOF'

sudo /bin/sed -i "s/%%yourusername%%/${USERNAME}/g" /etc/wpa_supplicant/wpa_supplicant.conf
sudo /bin/sed -i "s/%%yourpassword%%/${PASSWORD}/g" /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\033[1;33m updated \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"

#SETUP NETWORK INTERFACES
if [ -f /etc/network/interfaces ]
then
sudo cp -f /etc/network/interfaces /etc/network/interfaces.bak
echo -e "\033[1;34m backedup\033[0m '/etc/network/interfaces to /etc/network/interfaces.bak'"
else
touch /etc/network/interfaces
echo -e "\033[0;36m created \033[0m '/etc/network/interfaces'"
fi

sudo bash -c 'cat << EOF > /etc/network/interfaces
# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

#auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
#   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
        pre-up wpa_supplicant -B Dwext -i wlan0 -c/etc/wpa_supplicant/wpa_supplicant.conf
        post-down killall -q wpa_supplicant
EOF'
echo -e "\033[1;33m updated \033[0m '/etc/network/interfaces'"
}

setupThreeBPlus()
{
    read -p 'Enter username@gre.ac.uk : ' USERNAME
    read -s -p 'Enter password :' PASSWORD

# SETUP WPA_SUPPLICANT
if [ -f /etc/wpa_supplicant/wpa_supplicant.conf ]
then
        sudo mv -f /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.bak
echo ""
echo -e "\033[1;34m backedup\033[0m '/etc/wpa_supplicant/wpa_supplicant.conf to /etc/wpa_supplicant/wpa_supplicant.conf.bak"
else
touch etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\033[0;36m created \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"
fi

sudo bash -c 'cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
        ssid="eduroam"
        key_mgmt=WPA-EAP
        eap=PEAP
        identity="%%yourusername%%"
        anonymous_identity="%%yourusername%%"
        password="%%yourpassword%%"
        phase2="auth=MSCHAPV2"
        id_str="University"
        priority=3
    }
EOF'

sudo /bin/sed -i "s/%%yourusername%%/${USERNAME}/g" /etc/wpa_supplicant/wpa_supplicant.conf
sudo /bin/sed -i "s/%%yourpassword%%/${PASSWORD}/g" /etc/wpa_supplicant/wpa_supplicant.conf
echo -e "\033[1;33m updated \033[0m '/etc/wpa_supplicant/wpa_supplicant.conf'"

if [ -f /etc/network/interfaces ]
then
sudo cp -f /etc/network/interfaces /etc/network/interfaces.bak
echo -e "\033[1;34m backedup\033[0m '/etc/network/interfaces to etc/network/interfaces.bak'"
else
touch /etc/network/interfaces
sudo bash -c 'cat <<EOF> /etc/network/interfaces

# interfaces(5) files used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult etc/dhcpcd.conf and 'man dhcpcd/conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces/d
EOF'
echo -e "\033[0;36m created \033[0m '/etc/network/interfaces'"
fi
}

# Instructions begins...
echo""
echo -e "\033[0;33m....................wpa_enterprise.sh is running...................\033[0m"
echo 'To initialise the wpa_supplicant and interface files correctly,'
read -p 'please enter the pi model number: 2 ,3B, 3B+ or R to reset files back to default: ' piVersion

case "${piVersion^^}" in
R) # this resets wpa_supplicant and interfaces files to defualt settings
    reset
	echo -e "\033[0;32m Notice  \033[0m 'config files have been reset to their default settings'";;
2) # this creates wpa_supplicant interfaces files wth enterprise network settings
    setupTwo
	echo -e "\033[0;32m Notice  \033[0m 'config files have been update successfully'";;

3B) # this creates wpa_supplicant interfaces files wth enterprise network settings
    setupThreeB
	echo -e "\033[0;32m Notice  \033[0m 'config files have been updated successfully'";;

3B+)
    # This creates wpa_supplicant file with enterprise network settings
    setupThreeBPlus
	echo -e "\033[0;32m Notice  \033[0m 'config files have been updated successfully'";;
*) echo 'Enter a pi version number, 1 ,2 ,3B or 3B+ :';;
esac
