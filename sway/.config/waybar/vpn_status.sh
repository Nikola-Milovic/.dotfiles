#!/bin/bash

VPN_STATUS=$(nmcli con show --active | grep "vpn")

if [[ -z "$VPN_STATUS" ]]; then
	echo -n "{\"text\":\"Disconnected\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
else
	VPN_NAME=$(echo "$VPN_STATUS" | awk '{print $1}')
	echo -n "{\"text\":\"$VPN_NAME\",\"class\":\"connected\",\"icon\":\"🟢\"}"
fi
