#!/bin/bash

VPN_NAME=$(nmcli con show --active | grep "vpn" | awk '{print $1}')
if [[ ! -z "$VPN_NAME" ]]; then
	nmcli con down id "$VPN_NAME"
fi
