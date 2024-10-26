#!/bin/bash

WARP_STATUS=$(nmcli con show --active | grep "WARP")

if [[ -z "$WARP_STATUS" ]]; then
	echo -n "{\"text\":\"| NO WARP |\",\"class\":\"disconnected\",\"icon\":\"🔴\"}"
else
	echo -n "{\"text\":\"| WARP |\",\"class\":\"connected\",\"icon\":\"🟢\"}"
fi
