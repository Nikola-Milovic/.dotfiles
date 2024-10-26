#!/bin/bash

WARP_STATUS=$(nmcli con show --active | grep "WARP")

if [[ -z "$WARP_STATUS" ]]; then
	warp-cli disconnect
else
	warp-cli connect
fi
