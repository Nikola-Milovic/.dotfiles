{
  pkgs,
  lib,
}:

pkgs.writeShellApplication {
  name = "networkmon";

  runtimeInputs = with pkgs; [
    dnsutils # dig
    curl
    iputils # ping
    iproute2 # ip
    networkmanager # nmcli
    tailscale
    util-linux # flock
    systemd # journalctl
    coreutils
    gawk
    gnugrep
  ];

  meta = with lib; {
    description = "Continuous network connectivity monitor — polls DNS, ping, HTTP, NM, Tailscale and logs issues as JSONL";
    mainProgram = "networkmon";
    license = licenses.mit;
    platforms = platforms.linux;
  };

  # No errexit — checks are allowed to fail without killing the daemon
  bashOptions = [
    "nounset"
    "pipefail"
  ];

  checkPhase = "";

  text = ''
    if [[ "''${1:-}" == "--help" || "''${1:-}" == "-h" ]]; then
        cat <<'HELPEOF'
    networkmon — continuous network connectivity monitor

    Runs in a loop, polling network state every INTERVAL seconds and logging
    results as JSONL. Designed to run as a systemd service.

    Each cycle checks:
      DNS     Resolution via default nameserver and direct (1.1.1.1)
      Ping    Gateway, 1.1.1.1, 8.8.8.8 — latency and packet loss
      HTTP    GET https://github.com and https://www.google.com
      NM      NetworkManager connectivity state
      TS      Tailscale backend state
      Iface   Primary interface carrier and operstate
      Veths   Docker veth interface count (churn indicator)
      Journal NetworkManager/Tailscale events from journald

    State changes (IP, gateway, DNS, NM, Tailscale, interface, carrier) are
    detected and logged. Issues (DNS failure, packet loss, HTTP errors, NM
    limited connectivity, interface down) get their own log entries.

    Log format:
      One JSON object per line (JSONL) in $LOG_DIR/events.jsonl
      Event types: start, stop, check, issue, change, journal

    Environment variables:
      NETWORKMON_INTERVAL   Check interval in seconds   (default: 30)
      NETWORKMON_LOG_DIR    Log output directory         (default: /var/log/networkmon)
      NETWORKMON_IFACE      Primary network interface    (default: enp119s0)

    NixOS module:
      custom.services.networkmon = {
        enable = true;
        interval = 30;          # seconds
        interface = "enp119s0";
        logDir = "/var/log/networkmon";
      };

    See also: networkmon-analyze --help
    HELPEOF
        exit 0
    fi

    CHECK_INTERVAL="''${NETWORKMON_INTERVAL:-30}"
    LOG_DIR="''${NETWORKMON_LOG_DIR:-/var/log/networkmon}"
    LOG_FILE="$LOG_DIR/events.jsonl"
    MAX_LOG_BYTES=$((50 * 1024 * 1024))

    PRIMARY_IFACE="''${NETWORKMON_IFACE:-enp119s0}"
    DNS_TEST_DOMAIN="github.com"
    DNS_DIRECT_SERVER="1.1.1.1"
    PING_TARGETS=("1.1.1.1" "8.8.8.8")
    HTTP_TARGETS=("https://github.com" "https://www.google.com")

    declare -A PREV
    CYCLE=0
    LAST_JOURNAL_TS=""

    # ─── helpers ──────────────────────────────────────────────────────

    mkdir -p "$LOG_DIR"

    json_escape() {
        local s="$1"
        s="''${s//\\/\\\\}"
        s="''${s//\"/\\\"}"
        s="''${s//$'\n'/\\n}"
        s="''${s//$'\r'/}"
        s="''${s//$'\t'/\\t}"
        printf '%s' "$s"
    }

    log_event() {
        local etype="$1"; shift
        local ts line
        ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        line=$(printf '{"ts":"%s","type":"%s"' "$ts" "$etype")
        while [[ $# -ge 2 ]]; do
            local k="$1" v="$2"; shift 2
            if [[ "$v" =~ ^-?[0-9]+\.?[0-9]*$ ]] && [[ "$v" != "" ]]; then
                line+=$(printf ',"%s":%s' "$k" "$v")
            else
                line+=$(printf ',"%s":"%s"' "$k" "$(json_escape "$v")")
            fi
        done
        line+="}"
        (
            flock -x 200
            echo "$line" >> "$LOG_FILE"
        ) 200>"$LOG_FILE.lock"
    }

    rotate_log() {
        if [[ -f "$LOG_FILE" ]]; then
            local sz
            sz=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
            if (( sz > MAX_LOG_BYTES )); then
                mv "$LOG_FILE" "''${LOG_FILE}.old"
            fi
        fi
    }

    # ─── probes ───────────────────────────────────────────────────────

    get_ip()           { ip -4 addr show "$PRIMARY_IFACE" 2>/dev/null | awk '/inet /{print $2; exit}' | cut -d/ -f1; }
    get_gw()           { ip route show default 2>/dev/null | awk '/default via/{print $3; exit}'; }
    get_resolv_ns()    { awk '/^nameserver/{print $2}' /etc/resolv.conf 2>/dev/null | head -1; }
    get_resolv_hash()  { md5sum /etc/resolv.conf 2>/dev/null | awk '{print $1}'; }
    get_iface_state()  { cat "/sys/class/net/$PRIMARY_IFACE/operstate" 2>/dev/null || echo "unknown"; }
    get_iface_carrier(){ cat "/sys/class/net/$PRIMARY_IFACE/carrier" 2>/dev/null || echo "0"; }

    check_nm() {
        local raw
        raw=$(nmcli -t general status 2>/dev/null) || { echo "unknown|unknown"; return; }
        local state conn
        state=$(echo "$raw" | cut -d: -f1)
        conn=$(echo "$raw" | cut -d: -f2)
        echo "$state|$conn"
    }

    check_tailscale() {
        local raw
        raw=$(tailscale status --json 2>/dev/null) || { echo "error"; return; }
        echo "$raw" | grep -oP '"BackendState"\s*:\s*"\K[^"]+' || echo "unknown"
    }

    check_dns() {
        local server="$1" domain="$2"
        local t0 t1 ms out
        t0=$(date +%s%N)
        out=$(dig +short +timeout=3 +tries=1 "$domain" "@$server" 2>&1) || true
        t1=$(date +%s%N)
        ms=$(( (t1 - t0) / 1000000 ))
        if [[ -z "$out" || "$out" == *"timed out"* || "$out" == *"SERVFAIL"* || "$out" == *"connection refused"* ]]; then
            echo "fail|$ms|$out"
        else
            echo "ok|$ms"
        fi
    }

    check_ping() {
        local target="$1" out loss avg
        out=$(ping -c 3 -W 2 -q "$target" 2>&1) || true
        loss=$(echo "$out" | awk -F'[, %]+' '/packet loss/{for(i=1;i<=NF;i++) if($i=="packet") print $(i-1)}')
        avg=$(echo "$out" | awk -F'[= /]+' '/min\/avg\/max/{print $7}')
        echo "''${loss:-100}|''${avg:-0}"
    }

    check_http() {
        local url="$1"
        curl -s -o /dev/null -w "%{http_code}|%{time_total}" \
            --connect-timeout 5 --max-time 10 "$url" 2>/dev/null || echo "000|0"
    }

    count_veths() {
        local n
        n=$(ip link show 2>/dev/null | grep -c 'veth') || true
        echo "''${n:-0}"
    }

    # ─── journal (polled, no background process) ──────────────────────

    check_journal() {
        local since="''${LAST_JOURNAL_TS:-$CHECK_INTERVAL seconds ago}"
        LAST_JOURNAL_TS=$(date +"%Y-%m-%d %H:%M:%S")

        journalctl --since "$since" --no-pager -o short-iso \
            -u NetworkManager -u tailscaled -u systemd-networkd 2>/dev/null | \
        while IFS= read -r line; do
            if echo "$line" | grep -qiE \
                'link.?change|rebind|disconnect|deactivat|activat|dhcp|lease|carrier|roam|DNS|error|warn|fail|lost|timeout|address.*changed|renewed|expired|state change'; then
                local src
                src=$(echo "$line" | awk '{print $3}' | cut -d'[' -f1 | tr -d ':')
                log_event "journal" "src" "$src" "msg" "$line"
            fi
        done
    }

    # ─── change detection ─────────────────────────────────────────────

    detect_change() {
        local key="$1" val="$2"
        local prev="''${PREV[$key]:-}"
        if [[ -n "$prev" && "$val" != "$prev" ]]; then
            log_event "change" "key" "$key" "from" "$prev" "to" "$val"
        fi
        PREV[$key]="$val"
    }

    # ─── one check cycle ──────────────────────────────────────────────

    run_cycle() {
        (( CYCLE++ )) || true

        local ip gw resolv_ns resolv_hash iface_state carrier
        local nm_raw nm_state nm_conn ts_state veth_count
        ip=$(get_ip)
        gw=$(get_gw)
        resolv_ns=$(get_resolv_ns)
        resolv_hash=$(get_resolv_hash)
        iface_state=$(get_iface_state)
        carrier=$(get_iface_carrier)
        nm_raw=$(check_nm)
        nm_state="''${nm_raw%%|*}"
        nm_conn="''${nm_raw##*|}"
        ts_state=$(check_tailscale)
        veth_count=$(count_veths)

        # DNS
        local dns_def dns_def_status dns_def_ms
        dns_def=$(check_dns "''${resolv_ns:-100.100.100.100}" "$DNS_TEST_DOMAIN")
        dns_def_status="''${dns_def%%|*}"
        dns_def_ms=$(echo "$dns_def" | cut -d'|' -f2)

        local dns_dir dns_dir_status dns_dir_ms
        dns_dir=$(check_dns "$DNS_DIRECT_SERVER" "$DNS_TEST_DOMAIN")
        dns_dir_status="''${dns_dir%%|*}"
        dns_dir_ms=$(echo "$dns_dir" | cut -d'|' -f2)

        # Ping — gateway + two external
        local pgw pgw_loss pgw_ms
        pgw=$(check_ping "''${gw:-192.168.1.1}")
        pgw_loss="''${pgw%%|*}"
        pgw_ms="''${pgw##*|}"

        local pext pext_loss pext_ms
        pext=$(check_ping "''${PING_TARGETS[0]}")
        pext_loss="''${pext%%|*}"
        pext_ms="''${pext##*|}"

        local pext2 pext2_loss pext2_ms
        pext2=$(check_ping "''${PING_TARGETS[1]}")
        pext2_loss="''${pext2%%|*}"
        pext2_ms="''${pext2##*|}"

        # HTTP
        local hgh hgh_code hgh_time
        hgh=$(check_http "''${HTTP_TARGETS[0]}")
        hgh_code="''${hgh%%|*}"
        hgh_time="''${hgh##*|}"

        local hgo hgo_code hgo_time
        hgo=$(check_http "''${HTTP_TARGETS[1]}")
        hgo_code="''${hgo%%|*}"
        hgo_time="''${hgo##*|}"

        # Journal events since last cycle
        check_journal

        # ── log periodic check ────────────────────────────────────────
        log_event "check" \
            "cycle" "$CYCLE" \
            "ip" "''${ip:-none}" \
            "gw" "''${gw:-none}" \
            "iface" "$iface_state" \
            "carrier" "$carrier" \
            "nm_state" "$nm_state" \
            "nm_conn" "$nm_conn" \
            "ts_state" "$ts_state" \
            "resolv_ns" "''${resolv_ns:-none}" \
            "veth_count" "$veth_count" \
            "dns_def_ok" "$([[ $dns_def_status == "ok" ]] && echo 1 || echo 0)" \
            "dns_def_ms" "$dns_def_ms" \
            "dns_dir_ok" "$([[ $dns_dir_status == "ok" ]] && echo 1 || echo 0)" \
            "dns_dir_ms" "$dns_dir_ms" \
            "ping_gw_loss" "$pgw_loss" \
            "ping_gw_ms" "$pgw_ms" \
            "ping_cf_loss" "$pext_loss" \
            "ping_cf_ms" "$pext_ms" \
            "ping_goog_loss" "$pext2_loss" \
            "ping_goog_ms" "$pext2_ms" \
            "http_github" "$hgh_code" \
            "http_github_s" "$hgh_time" \
            "http_google" "$hgo_code" \
            "http_google_s" "$hgo_time"

        # ── detect state changes ──────────────────────────────────────
        detect_change "ip" "''${ip:-none}"
        detect_change "gw" "''${gw:-none}"
        detect_change "resolv" "$resolv_hash"
        detect_change "nm" "$nm_state|$nm_conn"
        detect_change "ts" "$ts_state"
        detect_change "iface" "$iface_state"
        detect_change "carrier" "$carrier"

        # ── log issues ────────────────────────────────────────────────
        if [[ "$dns_def_status" == "fail" ]]; then
            log_event "issue" "cat" "dns_fail" \
                "detail" "Default DNS (''${resolv_ns:-?}) failed to resolve $DNS_TEST_DOMAIN" \
                "dns_dir_ok" "$([[ $dns_dir_status == "ok" ]] && echo 1 || echo 0)" \
                "resolv_ns" "''${resolv_ns:-?}"
        fi
        if [[ "$dns_def_status" == "ok" && "''${dns_def_ms:-0}" -gt 500 ]]; then
            log_event "issue" "cat" "dns_slow" \
                "detail" "Default DNS took ''${dns_def_ms}ms" "ms" "$dns_def_ms"
        fi
        if [[ "''${pgw_loss:-100}" != "0" ]]; then
            log_event "issue" "cat" "gw_loss" \
                "detail" "Gateway packet loss: ''${pgw_loss}%" "loss_pct" "$pgw_loss"
        fi
        if [[ "''${pext_loss:-100}" != "0" ]]; then
            log_event "issue" "cat" "ext_loss" \
                "detail" "External (1.1.1.1) packet loss: ''${pext_loss}%" "loss_pct" "$pext_loss"
        fi

        local ok_http="200 301 302"
        if [[ ! " $ok_http " =~ " ''${hgh_code:-0} " ]]; then
            log_event "issue" "cat" "http_fail" \
                "detail" "GitHub HTTP: ''${hgh_code}" "url" "''${HTTP_TARGETS[0]}" "code" "$hgh_code"
        fi
        if [[ ! " $ok_http " =~ " ''${hgo_code:-0} " ]]; then
            log_event "issue" "cat" "http_fail" \
                "detail" "Google HTTP: ''${hgo_code}" "url" "''${HTTP_TARGETS[1]}" "code" "$hgo_code"
        fi

        if [[ "$iface_state" != "up" ]]; then
            log_event "issue" "cat" "iface_down" \
                "detail" "$PRIMARY_IFACE is $iface_state" "carrier" "$carrier"
        fi
        if [[ "$nm_conn" == "limited" || "$nm_conn" == "none" ]]; then
            log_event "issue" "cat" "nm_limited" \
                "detail" "NetworkManager connectivity: $nm_conn" "nm_state" "$nm_state"
        fi

        # one-line status to stdout / journal
        local icon="OK"
        [[ "$dns_def_status" == "fail" || "''${pgw_loss:-100}" != "0" || "$iface_state" != "up" ]] && icon="ISSUE"
        printf "[%s] #%d  dns:%s/%sms  gw:%s%%/%sms  http:%s/%s  nm:%s  ts:%s  veths:%s\n" \
            "$icon" "$CYCLE" \
            "$dns_def_status" "$dns_def_ms" \
            "$pgw_loss" "$pgw_ms" \
            "$hgh_code" "$hgo_code" \
            "$nm_conn" "$ts_state" \
            "$veth_count"
    }

    # ─── main ─────────────────────────────────────────────────────────

    cleanup() {
        log_event "stop" "cycles" "$CYCLE"
        exit 0
    }

    trap cleanup EXIT INT TERM

    echo "networkmon starting (interval: ''${CHECK_INTERVAL}s, log: $LOG_FILE, iface: $PRIMARY_IFACE)"
    log_event "start" "interval" "$CHECK_INTERVAL" "iface" "$PRIMARY_IFACE" "pid" "$$"

    while true; do
        rotate_log
        run_cycle
        sleep "$CHECK_INTERVAL"
    done
  '';
}
