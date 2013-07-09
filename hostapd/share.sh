#!/bin/sh
#
# Where is your internet connection from?  Most 3G modems are on ppp0
INET_IFACE="ppp0"
#
# You must have an active connection over your 3G network before running this script
# When you run it, it reads IP address for this connection
INET_IP=$(ifconfig $INET_IFACE |sed -n "/inet addr:.*255.255.255.255/{s/.*inet addr://; s/ .*//; p}")
#
# Using this new assigned IP from your 3G network
# We have to update dhcp.conf router with current INET_IFACE IP address
# !!Warning this sed command will change any "option routers xxx.xxx.xxx.xxx" to the INET_IP in your config file
# Modify the sed command if you need to avoid this because you have some other dhcp setup running
sed -i "s/option\ routers\ [0-9]*.[0-9]*.[0-9]*.[0-9]*;/option\ routers\ $INET_IP;/" /etc/dhcp3/dhcpd.conf
#
# Where is your wifi card?
LAN_IFACE="wlan0"
#
# We need to assign an IP address to your wifi card for the dhcp service
# Force an IP address (if you change this you need to change your dhcpd.conf file too)
Wlan_IP="10.1.1.1"
#
# Configure the wireless interface
ifconfig $LAN_IFACE down
ifconfig $LAN_IFACE $Wlan_IP netmask 255.255.255.0
ifconfig $LAN_IFACE up
#
# Start the wireless AP service layers and turn on the AP in the background with lots of debug messages (-dd)
# you can also change the -dd to -d or remove it for less messages
hostapd -dd ~/hostapd/hostapd_open.conf &
#
# Restart the dhcp server now that the AP is up and running
/etc/init.d/dhcp3-server restart
