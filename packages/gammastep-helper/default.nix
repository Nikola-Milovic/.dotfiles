{
  pkgs,
  lib,
  stdenv,
}:

pkgs.writeShellApplication {
  name = "gammastep-helper";

  runtimeInputs = [
    pkgs.wl-gammarelay-rs
    pkgs.systemd
  ];

  meta = with lib; {
    description = "Helper script to set brightness and temperature using wl-gammarelay and busctl";
    mainProgram = "gammastep-helper";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };

  checkPhase = "";

  text = ''
    #!/usr/bin/env bash

    # Default values
    BRIGHTNESS=""
    TEMPERATURE=""

    # Helper to display usage
    function usage {
      echo "Usage: $0 [-b <brightness>] [-t <temperature>]"
      echo ""
      echo "Options:"
      echo "  -b <brightness>   Set brightness (float between 0.0 and 1.0)"
      echo "  -t <temperature>  Set temperature (integer in Kelvin)"
      exit 1
    }

    # Parse flags
    while getopts ":b:t:" opt; do
      case $opt in
        b)
          BRIGHTNESS="$OPTARG"
          ;;
        t)
          TEMPERATURE="$OPTARG"
          ;;
        *)
          usage
          ;;
      esac
    done

    # Ensure at least one flag is provided
    if [[ -z "$BRIGHTNESS" && -z "$TEMPERATURE" ]]; then
      usage
    fi

    # Apply brightness if specified
    if [[ -n "$BRIGHTNESS" ]]; then
      busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d "$BRIGHTNESS"
    fi

    # Apply temperature if specified
    if [[ -n "$TEMPERATURE" ]]; then
      busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q "$TEMPERATURE"
    fi
  '';
}
