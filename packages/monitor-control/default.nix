{ pkgs, stdenv }:

pkgs.writeShellApplication {
  name = "monitor-control";

  runtimeInputs = [ pkgs.ddcutil ];

  meta = with pkgs.lib; {
    description = "Script to set brightness and contrast for monitors using ddcutil";
    mainProgram = "monitor-control";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };

  checkPhase = "";

  text = ''
    usage() {
      echo "Usage: $0 [-b VALUE] [-c VALUE] [-m IDS]"
      echo "  -b, --brightness VALUE   Set brightness to VALUE (0-100)"
      echo "  -c, --contrast VALUE     Set contrast to VALUE (0-100)"
      echo "  -m, --monitors IDS       Monitor IDs to apply settings (e.g., -m 1 2)"
      echo "  -h, --help               Show this help message"
      exit 1
    }

    if [ "$#" -eq 0 ]; then
      usage
    fi

    # Initialize variables
    brightness=""
    contrast=""
    monitor_ids=()

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
      case "$1" in
        -b|--brightness)
          brightness="$2"
          shift 2
          ;;
        -c|--contrast)
          contrast="$2"
          shift 2
          ;;
        -m|--monitors)
          shift
          while [[ "$#" -gt 0 && ! "$1" =~ ^- ]]; do
            monitor_ids+=("$1")
            shift
          done
          ;;
        -h|--help)
          usage
          ;;
        *)
          echo "Unknown option: $1"
          usage
          ;;
      esac
    done

    # Validate input
    if [[ -z "$brightness" && -z "$contrast" ]]; then
      echo "Error: At least one of --brightness or --contrast must be specified."
      usage
    fi

    # If no monitors specified, detect all
    if [[ "''${#monitor_ids[@]}" -eq 0 ]]; then
      monitor_ids=($(ddcutil detect | grep -oP '(?<=Display )\d+'))
      if [[ "''${#monitor_ids[@]}" -eq 0 ]]; then
        echo "Error: No monitors detected."
        exit 1
      fi
    fi

    # Apply settings to each monitor
    for monitor in "''${monitor_ids[@]}"; do
      if [[ -n "$brightness" ]]; then
        ddcutil -d "$monitor" setvcp 10 "$brightness" >/dev/null
      fi
      if [[ -n "$contrast" ]]; then
        ddcutil -d "$monitor" setvcp 12 "$contrast" >/dev/null
      fi
    done
  '';
}
