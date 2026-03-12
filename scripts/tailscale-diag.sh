#!/usr/bin/env bash
set -u
set -o pipefail

ts="$(date +%Y%m%d-%H%M%S)"
host="$(hostname -s 2>/dev/null || hostname)"
default_out="/tmp/tailscale-diag-${host}-${ts}.log"
out_file="${1:-$default_out}"

mkdir -p "$(dirname "$out_file")"
exec > >(tee "$out_file") 2>&1

section() {
  printf '\n===== %s =====\n' "$1"
}

run() {
  printf '\n$ %s\n' "$1"
  bash -lc "$1"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '[exit=%s]\n' "$rc"
  fi
}

section "Meta"
run "date -Is"
run "whoami"
run "uname -a"
run "nixos-version || true"

section "Network Basics"
run "ip -brief addr"
run "ip route show"
run "ip rule show"
run "sysctl net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter net.ipv4.conf.tailscale0.rp_filter || true"

section "Tailscale Basics"
run "command -v tailscale"
run "tailscale version"
run "tailscale ip -4"
run "tailscale ip -6 || true"
run "tailscale status"
run "tailscale netcheck"
run "tailscale debug prefs"

section "Systemd State"
run "systemctl --no-pager --full status tailscaled.service"
run "systemctl --no-pager --full status firewall.service"
run "journalctl -u tailscaled --no-pager -n 120"
run "journalctl -u firewall --no-pager -n 120"

section "Socket / Port Visibility"
run "ss -lunp | grep -E '41641|tailscale' || true"
run "ss -ltnp | grep -E '22|tailscale|ssh' || true"

section "Done"
printf 'Saved diagnostic log to: %s\n' "$out_file"
printf 'Now run the root script too: sudo ./scripts/tailscale-diag-root.sh\n'
