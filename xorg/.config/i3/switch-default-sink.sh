#!/bin/bash

SINK=$(pacmd list-sinks | grep '  index' | cut -f6 -d' ')
pacmd set-default-sink ${SINK}
pacmd list-sink-inputs | grep index | while read line; do
	pacmd move-sink-input $(echo $line | cut -f2 -d' ') ${SINK}
done
