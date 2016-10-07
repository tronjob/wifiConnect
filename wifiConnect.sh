#!/bin/bash

ESSID_MAIN="OverLord I"
ESSID_BACKUP="OverLord II"
WLAN_IFACE=wlan0
WIFI_DRIVER=rt61pci #may not be necessary - it's just a workaround
WPA_CONFIG_PATH=/etc/wpa_supplicant/wpa_supplicant.conf 

#reload the Wifi card kernel driver - workaround stupid bug.
modprobe -r $WIFI_DRIVER
modprobe $WIFI_DRIVER
rm -f /var/run/wpa_supplicant/$WLAN_IFACE

iwconfig wlan0 essid $ESSID_MAIN
dhclient -r $WLAN_IFACE #release current ip (if any)

### DEBUG ###
#iwlist wlan0 scan #verificar detecção de APs
#dhclient -1 $WLAN_IFACE #para debugging - output "verboso" activo
#############
echo "Connecting to $ESSID_MAIN..."
wpa_supplicant -B -c$WPA_CONFIG_PATH -i$WLAN_IFACE -Dwext

dhclient -1 -q $WLAN_IFACE

if [ $? -eq 0 ]; then
    echo "Connected to $ESSID_MAIN!"
    exit 0;
else
    echo "Connection to $ESSID_MAIN unsuccessful."
    echo "Attempting backup network $ESSID_BACKUP."
    if [ -e /var/run/wpa_supplicant/$WLAN_IFACE ]; then
	rm -f /var/run/wpa_supplicant/$WLAN_IFACE
    fi

#run wpa_supplicant - daemon mode - switch -B to -d to debug.
    wpa_supplicant -B -c$WPA_CONFIG_PATH -i$WLAN_IFACE -Dwext

#run dhclient
    dhclient $WLAN_IFACE
fi
