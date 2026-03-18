{
  pkgs,
  lib,
}:

pkgs.writeShellApplication {
  name = "networkmon-analyze";

  runtimeInputs = with pkgs; [
    coreutils
    gawk
    gnugrep
    gnused
    iproute2
    networkmanager
    tailscale
  ];

  meta = with lib; {
    description = "Analyze networkmon logs — generate a report file you can feed to any LLM";
    mainProgram = "networkmon-analyze";
    license = licenses.mit;
    platforms = platforms.linux;
  };

  # No errexit — grep returning 0 matches (exit 1) must not kill the script
  bashOptions = [
    "nounset"
    "pipefail"
  ];

  checkPhase = "";

  text = ''
    LOG_DIR="''${NETWORKMON_LOG_DIR:-/var/log/networkmon}"
    LOG_FILE="$LOG_DIR/events.jsonl"
    REPORT_DIR="''${NETWORKMON_REPORT_DIR:-$LOG_DIR}"

    HOURS=1
    MODE="summary"
    TAIL_N=50

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --hours|-h)  HOURS="$2"; shift 2;;
            --report|-r) MODE="report"; shift;;
            --tail|-t)   MODE="tail"; TAIL_N="''${2:-50}"; shift; [[ "''${1:-}" =~ ^[0-9]+$ ]] && shift || true;;
            --issues|-i) MODE="issues"; shift;;
            --changes|-c) MODE="changes"; shift;;
            --live)      MODE="live"; shift;;
            --help)
                cat <<'HELPEOF'
    networkmon-analyze — analyze networkmon logs

    Usage: networkmon-analyze [OPTIONS]

    Modes (default: summary):
      (none)            Print a human-readable summary to stdout
      --report,  -r     Generate a markdown report file for LLM analysis
      --issues,  -i     Print only issue events (one per line)
      --changes, -c     Print only state-change events (one per line)
      --tail [N], -t    Print last N raw JSONL events (default: 50)
      --live            Tail the log file in real time (Ctrl+C to stop)

    Options:
      --hours N, -h N   Time window to analyze (default: 1)
      --help            Show this help

    Report mode (--report):
      Writes a self-contained markdown file with system state, monitoring
      summary, and raw event data. Feed it to any LLM (ChatGPT, Claude, etc.)
      for root-cause analysis. Output path is printed to stdout.

    Examples:
      networkmon-analyze                    # summary of last hour
      networkmon-analyze -h 24              # summary of last 24 hours
      networkmon-analyze --report -h 12     # 12h report for LLM
      networkmon-analyze --issues -h 6      # issues from last 6 hours
      networkmon-analyze --live             # watch events in real time

    Environment variables:
      NETWORKMON_LOG_DIR       Log directory      (default: /var/log/networkmon)
      NETWORKMON_REPORT_DIR    Report output dir   (default: same as log dir)

    See also: networkmon --help
    HELPEOF
                exit 0;;
            *) echo "Unknown option: $1"; exit 1;;
        esac
    done

    if [[ ! -f "$LOG_FILE" ]]; then
        echo "No log file at $LOG_FILE"
        echo "Is the networkmon service running?  systemctl status networkmon"
        exit 1
    fi

    cutoff=$(date -u -d "$HOURS hours ago" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || echo "")

    filter_by_time() {
        if [[ -n "$cutoff" ]]; then
            awk -v c="$cutoff" '{ if(match($0, /"ts":"([^"]+)"/, a) && a[1] >= c) print }' "$LOG_FILE"
        else
            cat "$LOG_FILE"
        fi
    }

    # ─── summary (reusable, writes to stdout) ─────────────────────────

    do_summary() {
        local data
        data=$(filter_by_time)
        local total checks issues changes journals
        total=$(echo "$data" | wc -l | tr -d ' ')
        checks=$(echo "$data" | grep '"type":"check"' | wc -l | tr -d ' ')
        issues=$(echo "$data" | grep '"type":"issue"' | wc -l | tr -d ' ')
        changes=$(echo "$data" | grep '"type":"change"' | wc -l | tr -d ' ')
        journals=$(echo "$data" | grep '"type":"journal"' | wc -l | tr -d ' ')

        echo "=== networkmon summary — last ''${HOURS}h ==="
        echo ""
        echo "Events: $total total ($checks checks, $issues issues, $changes changes, $journals journal)"
        echo ""

        if (( issues > 0 )); then
            echo "-- Issues --------------------------------------------------------"
            echo ""
            echo "$data" | grep '"type":"issue"' | \
                grep -oP '"cat":"[^"]*"' | sort | uniq -c | sort -rn | \
                while read -r count cat; do
                    cat_name=$(echo "$cat" | tr -d '"' | cut -d: -f2)
                    printf "  %4d x %s\n" "$count" "$cat_name"
                done
            echo ""
            echo "  Recent:"
            echo "$data" | grep '"type":"issue"' | tail -10 | \
                while IFS= read -r line; do
                    local ts cat detail
                    ts=$(echo "$line" | grep -oP '"ts":"[^"]*"' | cut -d'"' -f4)
                    cat=$(echo "$line" | grep -oP '"cat":"[^"]*"' | cut -d'"' -f4)
                    detail=$(echo "$line" | grep -oP '"detail":"[^"]*"' | cut -d'"' -f4)
                    printf "    %s  %-15s  %s\n" "$ts" "$cat" "$detail"
                done
            echo ""
        fi

        if (( changes > 0 )); then
            echo "-- State Changes -------------------------------------------------"
            echo ""
            echo "$data" | grep '"type":"change"' | \
                while IFS= read -r line; do
                    local ts key from to
                    ts=$(echo "$line" | grep -oP '"ts":"[^"]*"' | cut -d'"' -f4)
                    key=$(echo "$line" | grep -oP '"key":"[^"]*"' | cut -d'"' -f4)
                    from=$(echo "$line" | grep -oP '"from":"[^"]*"' | cut -d'"' -f4)
                    to=$(echo "$line" | grep -oP '"to":"[^"]*"' | cut -d'"' -f4)
                    printf "  %s  %s: %s -> %s\n" "$ts" "$key" "$from" "$to"
                done
            echo ""
        fi

        echo "-- DNS Performance -----------------------------------------------"
        echo ""
        local dns_fail dns_ok
        dns_fail=$(echo "$data" | grep '"type":"check"' | grep '"dns_def_ok":0' | wc -l | tr -d ' ')
        dns_ok=$(echo "$data" | grep '"type":"check"' | grep '"dns_def_ok":1' | wc -l | tr -d ' ')
        echo "  Default DNS:  $dns_ok ok / $dns_fail fail"
        local avg_dns
        avg_dns=$(echo "$data" | grep '"type":"check"' | \
            grep -oP '"dns_def_ms":\K[0-9]+' | \
            awk '{sum+=$1; n++} END{if(n>0) printf "%.0f", sum/n; else print "n/a"}')
        local avg_dir
        avg_dir=$(echo "$data" | grep '"type":"check"' | \
            grep -oP '"dns_dir_ms":\K[0-9]+' | \
            awk '{sum+=$1; n++} END{if(n>0) printf "%.0f", sum/n; else print "n/a"}')
        echo "  Avg latency:  ''${avg_dns}ms (default)  ''${avg_dir}ms (direct)"
        local max_dns
        max_dns=$(echo "$data" | grep '"type":"check"' | \
            grep -oP '"dns_def_ms":\K[0-9]+' | sort -n | tail -1)
        echo "  Max latency:  ''${max_dns:-n/a}ms"
        echo ""

        echo "-- Ping Stats ----------------------------------------------------"
        echo ""
        local gw_loss_events ext_loss_events
        gw_loss_events=$(echo "$data" | grep '"type":"check"' | grep -oP '"ping_gw_loss":\K[0-9]+' | awk '$1>0' | wc -l | tr -d ' ')
        ext_loss_events=$(echo "$data" | grep '"type":"check"' | grep -oP '"ping_cf_loss":\K[0-9]+' | awk '$1>0' | wc -l | tr -d ' ')
        echo "  Gateway loss events:  $gw_loss_events / $checks"
        echo "  External loss events: $ext_loss_events / $checks"
        local avg_gw_ms
        avg_gw_ms=$(echo "$data" | grep '"type":"check"' | \
            grep -oP '"ping_gw_ms":\K[0-9.]+' | \
            awk '{sum+=$1; n++} END{if(n>0) printf "%.1f", sum/n; else print "n/a"}')
        echo "  Avg gateway RTT:     ''${avg_gw_ms}ms"
        echo ""

        echo "-- HTTP Checks ---------------------------------------------------"
        echo ""
        local gh_fail go_fail
        gh_fail=$(echo "$data" | grep '"type":"check"' | grep -oP '"http_github":\K[0-9]+' | grep -v '200\|301\|302' | wc -l | tr -d ' ')
        go_fail=$(echo "$data" | grep '"type":"check"' | grep -oP '"http_google":\K[0-9]+' | grep -v '200\|301\|302' | wc -l | tr -d ' ')
        echo "  GitHub failures:  $gh_fail / $checks"
        echo "  Google failures:  $go_fail / $checks"
        echo ""

        if (( journals > 0 )); then
            echo "-- Journal Events ------------------------------------------------"
            echo ""
            echo "  By source:"
            echo "$data" | grep '"type":"journal"' | \
                grep -oP '"src":"[^"]*"' | sort | uniq -c | sort -rn | head -5 | \
                while read -r count src; do
                    printf "    %4d x %s\n" "$count" "$(echo "$src" | cut -d'"' -f4)"
                done
            echo ""
            local rebinds link_changes
            rebinds=$(echo "$data" | grep '"type":"journal"' | grep -i 'rebind' | wc -l | tr -d ' ')
            link_changes=$(echo "$data" | grep '"type":"journal"' | grep -i 'linkchange\|link.change' | wc -l | tr -d ' ')
            (( rebinds > 0 )) && echo "  WARNING: Tailscale rebind events: $rebinds"
            (( link_changes > 0 )) && echo "  WARNING: Link change events: $link_changes"
            echo ""
        fi

        echo "-- Docker veth Count ---------------------------------------------"
        echo ""
        local min_v max_v
        min_v=$(echo "$data" | grep '"type":"check"' | grep -oP '"veth_count":\K[0-9]+' | sort -n | head -1)
        max_v=$(echo "$data" | grep '"type":"check"' | grep -oP '"veth_count":\K[0-9]+' | sort -n | tail -1)
        echo "  Range: ''${min_v:-?} - ''${max_v:-?}"
        echo ""
    }

    # ─── issues / changes / tail ──────────────────────────────────────

    do_issues() {
        filter_by_time | grep '"type":"issue"' | \
            while IFS= read -r line; do
                local ts cat detail
                ts=$(echo "$line" | grep -oP '"ts":"[^"]*"' | cut -d'"' -f4)
                cat=$(echo "$line" | grep -oP '"cat":"[^"]*"' | cut -d'"' -f4)
                detail=$(echo "$line" | grep -oP '"detail":"[^"]*"' | cut -d'"' -f4)
                printf "%s  %-15s  %s\n" "$ts" "$cat" "$detail"
            done
    }

    do_changes() {
        filter_by_time | grep '"type":"change"' | \
            while IFS= read -r line; do
                local ts key from to
                ts=$(echo "$line" | grep -oP '"ts":"[^"]*"' | cut -d'"' -f4)
                key=$(echo "$line" | grep -oP '"key":"[^"]*"' | cut -d'"' -f4)
                from=$(echo "$line" | grep -oP '"from":"[^"]*"' | cut -d'"' -f4)
                to=$(echo "$line" | grep -oP '"to":"[^"]*"' | cut -d'"' -f4)
                printf "%s  %s: %s -> %s\n" "$ts" "$key" "$from" "$to"
            done
    }

    do_tail() { tail -n "$TAIL_N" "$LOG_FILE"; }
    do_live() { echo "Tailing $LOG_FILE ..."; tail -f "$LOG_FILE"; }

    # ─── report generation ────────────────────────────────────────────

    do_report() {
        local ts_now report_file
        ts_now=$(date +"%Y-%m-%d_%H%M%S")
        report_file="$REPORT_DIR/networkmon-report-''${ts_now}.md"

        mkdir -p "$REPORT_DIR"

        # Collect raw data
        local raw_issues raw_changes raw_journals
        raw_issues=$(filter_by_time | grep '"type":"issue"' | tail -50)
        raw_changes=$(filter_by_time | grep '"type":"change"' | tail -30)
        raw_journals=$(filter_by_time | grep '"type":"journal"' | tail -50)

        # Collect current system state
        local resolv_conf nm_status ts_status route_table iface_info
        resolv_conf=$(cat /etc/resolv.conf 2>/dev/null || echo "unreadable")
        nm_status=$(nmcli general status 2>/dev/null || echo "unavailable")
        ts_status=$(tailscale status 2>/dev/null || echo "unavailable")
        route_table=$(ip route show 2>/dev/null | head -10 || echo "unavailable")
        iface_info=$(ip -4 addr show 2>/dev/null | head -30 || echo "unavailable")

        {
            cat <<EOF
    # Network Diagnostics Report

    Generated: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
    Time window: last ''${HOURS}h
    Host: $(hostname)

    ## Instructions

    You are a Linux network diagnostics expert. This report was generated by
    an automated network monitor running on a NixOS system. Analyze the data
    below and identify the root cause of intermittent connectivity issues.

    The user reports:
    - Getting randomly logged out of websites
    - GitHub requiring multiple refreshes
    - Tailscale connectivity between machines is intermittent
    - Issues started a few weeks ago

    ## System Configuration

    - NixOS with impermanence (root filesystem wiped on reboot)
    - NetworkManager with: dhcp=internal, dns=none, rc-manager=unmanaged
    - Tailscale with MagicDNS enabled (writes to resolv.conf)
    - Docker (creates/destroys veth interfaces which trigger network events)
    - Ethernet only (no WiFi)
    - Static nameservers configured: 1.1.1.1, 9.9.9.9, 8.8.8.8

    ## Current System State

    ### resolv.conf
    \`\`\`
    $resolv_conf
    \`\`\`

    ### NetworkManager
    \`\`\`
    $nm_status
    \`\`\`

    ### Tailscale
    \`\`\`
    $ts_status
    \`\`\`

    ### Routing Table
    \`\`\`
    $route_table
    \`\`\`

    ### Network Interfaces
    \`\`\`
    $iface_info
    \`\`\`

    ## Monitoring Summary

    \`\`\`
    $(do_summary)
    \`\`\`

    ## Raw Issue Events (JSONL)

    \`\`\`json
    $raw_issues
    \`\`\`

    ## Raw State Change Events (JSONL)

    \`\`\`json
    $raw_changes
    \`\`\`

    ## Raw Journal Events (JSONL)

    \`\`\`json
    $raw_journals
    \`\`\`

    ## What I Need

    1. **Root cause analysis** — what is causing the intermittent connectivity?
    2. **Specific evidence** — point to events/patterns in the data above
    3. **Recommended fixes** — concrete NixOS configuration changes or commands
    4. **Priority** — which fix to apply first
    EOF
        } > "$report_file"

        echo "Report written to: $report_file"
        echo ""
        echo "Feed it to any LLM:"
        echo "  cat $report_file | pbcopy              # macOS clipboard"
        echo "  cat $report_file | wl-copy              # Wayland clipboard"
        echo "  cat $report_file | xclip -selection c   # X11 clipboard"
        echo ""
        echo "Or attach it directly to ChatGPT, Claude, etc."
    }

    # ─── dispatch ─────────────────────────────────────────────────────

    case "$MODE" in
        summary)  do_summary;;
        report)   do_report;;
        tail)     do_tail;;
        issues)   do_issues;;
        changes)  do_changes;;
        live)     do_live;;
    esac
  '';
}
