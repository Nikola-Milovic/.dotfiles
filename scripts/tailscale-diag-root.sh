#!/usr/bin/env bash
set -u
set -o pipefail

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Run this script as root: sudo ./scripts/tailscale-diag-root.sh"
  exit 1
fi

ts="$(date +%Y%m%d-%H%M%S)"
host="$(hostname -s 2>/dev/null || hostname)"
default_out="/tmp/tailscale-diag-root-${host}-${ts}.log"
out_file="${1:-$default_out}"

mkdir -p "$(dirname "$out_file")"
exec > >(tee "$out_file") 2>&1

section() {
  printf '\n===== %s =====\n' "$1"
}

run() {
  printf '\n# %s\n' "$1"
  bash -lc "$1"
  rc=$?
  if [ "$rc" -ne 0 ]; then
    printf '[exit=%s]\n' "$rc"
  fi
}

section "Meta"
run "date -Is"
run "id"

section "Firewall Rules (nftables/iptables)"
run "command -v nft || true"
run "nft list ruleset || true"
run "command -v iptables || true"
run "iptables -S || true"
run "iptables -t nat -S || true"
run "ip6tables -S || true"
run "ip6tables -t nat -S || true"

section "Kernel + Netfilter"
run "lsmod | grep -E 'wireguard|nf_|ip_tables|nft_' || true"
run "sysctl net.ipv4.conf.all.rp_filter net.ipv4.conf.default.rp_filter net.ipv4.conf.tailscale0.rp_filter || true"

section "Detailed Tailscaled + Firewall Logs"
run "journalctl -u tailscaled --no-pager -n 300"
run "journalctl -u firewall --no-pager -n 300"

section "Systemd Unit Definitions"
run "systemctl cat tailscaled.service"
run "systemctl cat firewall.service"

section "Done"
printf 'Saved root diagnostic log to: %s\n' "$out_file"
