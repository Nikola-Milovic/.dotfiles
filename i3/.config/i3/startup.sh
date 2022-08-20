#!/bin/bash
xrandr --output DisplayPort-0 --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-A-0 --primary --mode 2560x1440 --pos 1920x0 --rotate normal --output DVI-D-0 --off

#Sound https://unix.stackexchange.com/questions/65246/change-pulseaudio-input-output-from-shell
pacmd set-default-sink 1

# if [ -z "$1" ]; then
#     echo "Usage: $0 <sinkId/sinkName>" >&2
#     echo "Valid sinks:" >&2
#     pactl list short sinks >&2
#     exit 1
# fi
#
# newSink="$1"
#
# pactl list short sink-inputs|while read stream; do
#     streamId=$(echo $stream|cut '-d ' -f1)
#     echo "moving stream $streamId"
#     pactl move-sink-input "$streamId" "$newSink"
# done
