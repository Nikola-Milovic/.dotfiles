#!/usr/bin/env python3
"""
Show Codex reset credits and rate-limit reset windows.

Inspired by MacSteini/Codex-Usage:
https://github.com/MacSteini/Codex-Usage/blob/main/codex_usage.py
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


API_BASE = "https://chatgpt.com/backend-api"
ORIGINATOR = "Codex Desktop"
USER_AGENT = "codex-resets/1.0"

AUTH_PATH = Path(os.environ.get("CODEX_AUTH_PATH", "~/.codex/auth.json")).expanduser()

RESET_CREDITS_ENDPOINT = "/wham/rate-limit-reset-credits"
USAGE_ENDPOINT = "/wham/usage"

SENSITIVE_KEY_RE = re.compile(
    r"(access[_-]?token|refresh[_-]?token|id[_-]?token|authorization|secret|password|cookie|session|account[_-]?id|email|phone)",
    re.I,
)
EMAIL_RE = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")

COLOR_ENABLED = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None


def die(message: str, exit_code: int = 1) -> None:
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(exit_code)


def color(text: str, code: str) -> str:
    if not COLOR_ENABLED:
        return text
    return f"\033[{code}m{text}\033[0m"


def local_now() -> datetime:
    return datetime.now().astimezone()


def local_now_text() -> str:
    return local_now().strftime("%Y-%m-%d %H:%M:%S %Z %z")


def parse_datetime(value: Any) -> datetime | None:
    if value is None or value == "":
        return None
    if isinstance(value, (int, float)) or (isinstance(value, str) and value.isdigit()):
        timestamp = float(value)
        if timestamp > 10_000_000_000:
            timestamp /= 1000
        try:
            return datetime.fromtimestamp(timestamp, tz=timezone.utc)
        except (OSError, OverflowError, ValueError):
            return None
    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None
    return None


def format_datetime(value: Any) -> dict[str, Any]:
    dt = parse_datetime(value)
    if dt is None:
        return {
            "raw": value,
            "local": str(value) if value else "N/A",
            "utc": "N/A",
            "remaining_seconds": None,
            "remaining": "N/A",
            "days_remaining": None,
        }

    utc_dt = dt.astimezone(timezone.utc)
    local_dt = dt.astimezone()
    remaining_seconds = int((utc_dt - datetime.now(timezone.utc)).total_seconds())
    return {
        "raw": value,
        "local": local_dt.strftime("%Y-%m-%d %H:%M:%S %Z %z"),
        "utc": utc_dt.strftime("%Y-%m-%d %H:%M:%S UTC"),
        "remaining_seconds": remaining_seconds,
        "remaining": format_duration(remaining_seconds),
        "days_remaining": remaining_seconds / 86400,
    }


def format_duration(value: Any) -> str:
    try:
        seconds = int(float(value))
    except (TypeError, ValueError):
        return "N/A"
    if seconds < 0:
        return "expired"

    days, remainder = divmod(seconds, 86400)
    hours, remainder = divmod(remainder, 3600)
    minutes, seconds = divmod(remainder, 60)

    parts: list[str] = []
    if days:
        parts.append(f"{days}d")
    if hours:
        parts.append(f"{hours}h")
    if minutes and len(parts) < 2:
        parts.append(f"{minutes}m")
    if not parts:
        parts.append(f"{seconds}s")
    return "in " + " ".join(parts[:2])


def redact(value: Any, key: str | None = None) -> Any:
    if key and SENSITIVE_KEY_RE.search(key):
        return "[REDACTED]"
    if isinstance(value, dict):
        return {str(k): redact(v, str(k)) for k, v in value.items()}
    if isinstance(value, list):
        return [redact(item, key) for item in value]
    if isinstance(value, str):
        text = EMAIL_RE.sub("[REDACTED_EMAIL]", value)
        if len(text) > 500:
            return text[:497] + "..."
        return text
    return value


def load_auth() -> tuple[str, str]:
    if not AUTH_PATH.exists():
        die(f"Codex auth file not found: {AUTH_PATH}")

    try:
        auth = json.loads(AUTH_PATH.read_text(encoding="utf-8"))
    except json.JSONDecodeError as exc:
        die(f"Could not parse {AUTH_PATH}: {exc}")
    except OSError as exc:
        die(f"Could not read {AUTH_PATH}: {exc}")

    tokens = auth.get("tokens")
    if not isinstance(tokens, dict):
        die(f"Unexpected {AUTH_PATH} format: missing tokens object")

    access_token = tokens.get("access_token")
    account_id = tokens.get("account_id")
    if not access_token or not account_id:
        die(
            "Unexpected Codex auth format: tokens.access_token or "
            "tokens.account_id is missing"
        )

    return str(access_token), str(account_id)


def fetch_json(path: str, access_token: str, account_id: str, timeout: int) -> dict[str, Any]:
    request = urllib.request.Request(
        API_BASE.rstrip("/") + "/" + path.lstrip("/"),
        headers={
            "Authorization": f"Bearer {access_token}",
            "ChatGPT-Account-ID": account_id,
            "originator": ORIGINATOR,
            "User-Agent": USER_AGENT,
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=timeout) as response:
            raw = response.read().decode("utf-8", "replace")
            status = response.status
    except urllib.error.HTTPError as exc:
        body = exc.read().decode("utf-8", "replace")
        return {
            "ok": False,
            "status": exc.code,
            "reason": exc.reason,
            "body_excerpt": redact(body[:1000]),
        }
    except urllib.error.URLError as exc:
        return {"ok": False, "error": f"Network error: {exc}"}
    except TimeoutError:
        return {"ok": False, "error": "Timed out fetching Codex data"}

    try:
        return {"ok": True, "status": status, "data": json.loads(raw)}
    except json.JSONDecodeError as exc:
        return {
            "ok": False,
            "status": status,
            "error": f"Response was not JSON: {exc}",
            "body_excerpt": redact(raw[:1000]),
        }


def normalize_credit(credit: dict[str, Any]) -> dict[str, Any]:
    expires = format_datetime(credit.get("expires_at"))
    granted = format_datetime(credit.get("granted_at"))
    return {
        "reset_type": credit.get("reset_type"),
        "status": credit.get("status"),
        "granted_at": credit.get("granted_at"),
        "granted_at_local": granted["local"],
        "granted_at_utc": granted["utc"],
        "expires_at": credit.get("expires_at"),
        "expires_at_local": expires["local"],
        "expires_at_utc": expires["utc"],
        "time_remaining": expires["remaining"],
        "remaining_seconds": expires["remaining_seconds"],
        "days_remaining": expires["days_remaining"],
        "redeem_started_at": credit.get("redeem_started_at"),
        "redeemed_at": credit.get("redeemed_at"),
    }


def collect_reset_credits(access_token: str, account_id: str, timeout: int) -> dict[str, Any]:
    response = fetch_json(RESET_CREDITS_ENDPOINT, access_token, account_id, timeout)
    if not response.get("ok"):
        return {
            "ok": False,
            "retrieved_at_local": local_now_text(),
            "endpoint": RESET_CREDITS_ENDPOINT,
            "error": response,
        }

    data = response.get("data") if isinstance(response.get("data"), dict) else {}
    credits_raw = data.get("credits") if isinstance(data, dict) else []
    credits = credits_raw if isinstance(credits_raw, list) else []
    normalized = [
        normalize_credit(item) for item in credits if isinstance(item, dict)
    ]
    available = [
        item for item in normalized if str(item.get("status") or "") == "available"
    ]
    next_expiry = min(
        available,
        key=lambda item: (
            item.get("remaining_seconds")
            if isinstance(item.get("remaining_seconds"), int)
            else 10**18
        ),
        default=None,
    )

    return {
        "ok": True,
        "retrieved_at_local": local_now_text(),
        "endpoint": RESET_CREDITS_ENDPOINT,
        "available_count": data.get("available_count"),
        "credits_returned": len(normalized),
        "total_earned_count": data.get("total_earned_count"),
        "next_available_expiry": next_expiry,
        "credits": normalized,
    }


def normalize_window(name: str, window: Any) -> dict[str, Any]:
    if not isinstance(window, dict):
        return {
            "name": name,
            "used_percent": None,
            "window_seconds": None,
            "reset_after_seconds": None,
            "reset_in": "N/A",
            "reset_at": None,
            "reset_at_local": "N/A",
            "reset_at_utc": "N/A",
        }
    reset_at = format_datetime(window.get("reset_at"))
    return {
        "name": name,
        "used_percent": window.get("used_percent"),
        "window_seconds": window.get("limit_window_seconds"),
        "reset_after_seconds": window.get("reset_after_seconds"),
        "reset_in": format_duration(window.get("reset_after_seconds")),
        "reset_at": window.get("reset_at"),
        "reset_at_local": reset_at["local"],
        "reset_at_utc": reset_at["utc"],
    }


def normalize_rate_limit(limit: Any) -> dict[str, Any]:
    limit_data = limit if isinstance(limit, dict) else {}
    return {
        "allowed": limit_data.get("allowed"),
        "limit_reached": limit_data.get("limit_reached"),
        "primary_window": normalize_window(
            "primary", limit_data.get("primary_window")
        ),
        "weekly_window": normalize_window(
            "weekly", limit_data.get("secondary_window")
        ),
    }


def collect_rate_limits(access_token: str, account_id: str, timeout: int) -> dict[str, Any]:
    response = fetch_json(USAGE_ENDPOINT, access_token, account_id, timeout)
    if not response.get("ok"):
        return {
            "ok": False,
            "retrieved_at_local": local_now_text(),
            "endpoint": USAGE_ENDPOINT,
            "error": response,
        }

    data = response.get("data") if isinstance(response.get("data"), dict) else {}
    credits = data.get("credits") if isinstance(data.get("credits"), dict) else {}
    additional_raw = data.get("additional_rate_limits")
    additional = additional_raw if isinstance(additional_raw, list) else []
    return {
        "ok": True,
        "retrieved_at_local": local_now_text(),
        "endpoint": USAGE_ENDPOINT,
        "plan_type": data.get("plan_type"),
        "rate_limit_reached_type": data.get("rate_limit_reached_type"),
        "rate_limit": normalize_rate_limit(data.get("rate_limit")),
        "credits": {
            "balance": credits.get("balance"),
            "has_credits": credits.get("has_credits"),
            "unlimited": credits.get("unlimited"),
            "overage_limit_reached": credits.get("overage_limit_reached"),
        },
        "additional_rate_limits": [
            {
                "name": item.get("limit_name")
                or item.get("metered_feature")
                or f"additional_{index}",
                "metered_feature": item.get("metered_feature"),
                "rate_limit": normalize_rate_limit(item.get("rate_limit")),
            }
            for index, item in enumerate(additional, start=1)
            if isinstance(item, dict)
        ],
    }


def collect_report(timeout: int) -> dict[str, Any]:
    access_token, account_id = load_auth()
    return {
        "ok": True,
        "retrieved_at_local": local_now_text(),
        "auth_file": str(AUTH_PATH),
        "reset_credits": collect_reset_credits(access_token, account_id, timeout),
        "rate_limits": collect_rate_limits(access_token, account_id, timeout),
        "note": "Uses read-only undocumented Codex backend endpoints. Tokens are not printed.",
    }


def warning_lines(report: dict[str, Any], warn_days: int) -> list[str]:
    if warn_days <= 0:
        return []

    reset_data = report.get("reset_credits")
    if not isinstance(reset_data, dict) or not reset_data.get("ok"):
        return ["Could not fetch reset credits."]

    warnings: list[str] = []
    for index, credit in enumerate(reset_data.get("credits", []), start=1):
        if not isinstance(credit, dict):
            continue
        status = str(credit.get("status") or "unknown")
        days = credit.get("days_remaining")
        if status != "available" or not isinstance(days, (int, float)):
            continue
        if days < 0:
            warnings.append(f"Reset #{index} has expired.")
        elif days <= warn_days:
            warnings.append(
                f"Reset #{index} expires {credit.get('time_remaining')} "
                f"at {credit.get('expires_at_local')}."
            )
    return warnings


def format_bool(value: Any) -> str:
    if isinstance(value, bool):
        return "yes" if value else "no"
    if value is None:
        return "N/A"
    return str(value)


def format_value(value: Any) -> str:
    if value is None:
        return "N/A"
    if isinstance(value, float):
        return f"{value:.2f}"
    return str(value)


def table(headers: list[str], rows: list[list[Any]]) -> str:
    clean_rows = [[format_value(cell) for cell in row] for row in rows]
    widths = [
        max(len(str(header)), *(len(row[index]) for row in clean_rows))
        if clean_rows
        else len(str(header))
        for index, header in enumerate(headers)
    ]
    out = ["  " + "  ".join(str(header).ljust(widths[i]) for i, header in enumerate(headers))]
    out.append("  " + "  ".join("-" * width for width in widths))
    for row in clean_rows:
        out.append("  " + "  ".join(row[i].ljust(widths[i]) for i in range(len(widths))))
    return "\n".join(out)


def print_human(report: dict[str, Any], warn_days: int) -> None:
    print(color("Codex resets", "1"))
    print(f"Retrieved: {report.get('retrieved_at_local')}")
    print(f"Auth: {report.get('auth_file')} (token not printed)")
    print()

    resets = report.get("reset_credits")
    if not isinstance(resets, dict) or not resets.get("ok"):
        print(color("Reset credits: unavailable", "31"))
        print(json.dumps(redact(resets), indent=2))
    else:
        next_expiry = resets.get("next_available_expiry")
        if isinstance(next_expiry, dict):
            next_text = (
                f"{next_expiry.get('time_remaining')} "
                f"({next_expiry.get('expires_at_local')})"
            )
        else:
            next_text = "N/A"
        print(color("Reset credit summary", "1"))
        print(
            table(
                ["Metric", "Value"],
                [
                    ["Available resets", resets.get("available_count")],
                    ["Credits returned", resets.get("credits_returned")],
                    ["Total earned count", resets.get("total_earned_count")],
                    ["Next available expiry", next_text],
                    ["Warning window", f"{warn_days}d" if warn_days else "disabled"],
                ],
            )
        )

        warnings = warning_lines(report, warn_days)
        if warnings:
            print()
            print(color("Warnings", "33"))
            for warning in warnings:
                print(f"  - {warning}")

        rows = []
        for index, credit in enumerate(resets.get("credits", []), start=1):
            if not isinstance(credit, dict):
                continue
            status = str(credit.get("status") or "unknown")
            rows.append(
                [
                    index,
                    credit.get("reset_type"),
                    status,
                    credit.get("expires_at_local"),
                    credit.get("time_remaining"),
                    credit.get("granted_at_local"),
                ]
            )
        if rows:
            print()
            print(color("Reset credits", "1"))
            print(
                table(
                    ["#", "Type", "Status", "Expires local", "Remaining", "Granted local"],
                    rows,
                )
            )

    print()
    limits = report.get("rate_limits")
    if not isinstance(limits, dict) or not limits.get("ok"):
        print(color("Rate limits: unavailable", "31"))
        print(json.dumps(redact(limits), indent=2))
        return

    rate = limits.get("rate_limit") if isinstance(limits.get("rate_limit"), dict) else {}
    credits = limits.get("credits") if isinstance(limits.get("credits"), dict) else {}
    print(color("Rate-limit status", "1"))
    print(
        table(
            ["Metric", "Value"],
            [
                ["Plan", limits.get("plan_type")],
                ["Allowed now", format_bool(rate.get("allowed"))],
                ["Limit reached", format_bool(rate.get("limit_reached"))],
                ["Reached type", limits.get("rate_limit_reached_type")],
                ["Credit balance", credits.get("balance")],
                ["Has credits", format_bool(credits.get("has_credits"))],
                ["Unlimited credits", format_bool(credits.get("unlimited"))],
                [
                    "Overage reached",
                    format_bool(credits.get("overage_limit_reached")),
                ],
            ],
        )
    )

    print()
    print(color("Rate-limit windows", "1"))
    print(
        table(
            ["Window", "Used", "Resets in", "Resets at local", "Window length"],
            [
                window_for_print(rate.get("primary_window")),
                window_for_print(rate.get("weekly_window")),
            ],
        )
    )

    additional = limits.get("additional_rate_limits")
    if isinstance(additional, list) and additional:
        rows = []
        for item in additional:
            if not isinstance(item, dict):
                continue
            limit = item.get("rate_limit") if isinstance(item.get("rate_limit"), dict) else {}
            primary = limit.get("primary_window") if isinstance(limit.get("primary_window"), dict) else {}
            weekly = limit.get("weekly_window") if isinstance(limit.get("weekly_window"), dict) else {}
            rows.append(
                [
                    item.get("name"),
                    format_bool(limit.get("limit_reached")),
                    percent(primary.get("used_percent")),
                    primary.get("reset_in"),
                    percent(weekly.get("used_percent")),
                    weekly.get("reset_in"),
                ]
            )
        if rows:
            print()
            print(color("Additional rate limits", "1"))
            print(
                table(
                    [
                        "Name",
                        "Reached",
                        "Primary used",
                        "Primary reset",
                        "Weekly used",
                        "Weekly reset",
                    ],
                    rows,
                )
            )

    print()
    print(
        "Endpoints are undocumented and may change: "
        f"{RESET_CREDITS_ENDPOINT}, {USAGE_ENDPOINT}"
    )


def window_for_print(window: Any) -> list[Any]:
    if not isinstance(window, dict):
        return ["N/A", "N/A", "N/A", "N/A", "N/A"]
    return [
        window.get("name"),
        percent(window.get("used_percent")),
        window.get("reset_in"),
        window.get("reset_at_local"),
        format_duration(window.get("window_seconds")).removeprefix("in "),
    ]


def percent(value: Any) -> str:
    if value is None:
        return "N/A"
    return f"{value}%"


def non_negative_int(value: str) -> int:
    try:
        parsed = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError("must be an integer") from None
    if parsed < 0:
        raise argparse.ArgumentTypeError("must be >= 0")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="codex-resets",
        description="Show Codex reset credits, expirations, and rate-limit windows.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print machine-readable JSON instead of tables.",
    )
    parser.add_argument(
        "--warn-days",
        type=non_negative_int,
        default=7,
        help="Warn when available reset credits expire within this many days. Default: 7.",
    )
    parser.add_argument(
        "--timeout",
        type=non_negative_int,
        default=25,
        help="HTTP timeout in seconds. Default: 25.",
    )
    parser.add_argument(
        "--no-color",
        action="store_true",
        help="Disable ANSI color output.",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    global COLOR_ENABLED

    args = build_parser().parse_args(argv)
    if args.no_color:
        COLOR_ENABLED = False

    report = collect_report(timeout=args.timeout)
    if args.json:
        print(json.dumps(redact(report), indent=2))
    else:
        print_human(report, warn_days=args.warn_days)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
