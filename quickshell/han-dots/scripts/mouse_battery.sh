#!/usr/bin/env bash

# Read the AJAZZ mouse battery from its vendor-specific HID interface.
# Determine the Python binary (favoring global-python conda env which has `hid` installed)
PY_BIN=""
if [ -x "/home/han/miniconda3/envs/global-python/bin/python3" ]; then
    PY_BIN="/home/han/miniconda3/envs/global-python/bin/python3"
elif [ -x "$HOME/miniconda3/envs/global-python/bin/python3" ]; then
    PY_BIN="$HOME/miniconda3/envs/global-python/bin/python3"
elif [ -x "$HOME/.conda/envs/global-python/bin/python3" ]; then
    PY_BIN="$HOME/.conda/envs/global-python/bin/python3"
elif command -v python3 >/dev/null 2>&1; then
    PY_BIN="$(command -v python3)"
else
    printf 'N/A\n'
    exit 0
fi

result=$("$PY_BIN" - 2>/dev/null <<'PY'
import hid

SUPPORTED_VIDS = {0xA8A5, 0xA8A4}
VENDOR_USAGE_PAGE = 0xFF01

device = None
try:
    candidates = [
        item for item in hid.enumerate()
        if item.get("vendor_id") in SUPPORTED_VIDS
    ]
    if not candidates:
        raise RuntimeError("AJAZZ device not found")

    vendor_interfaces = [
        item for item in candidates
        if item.get("interface_number") == 2
        or item.get("usage_page") == VENDOR_USAGE_PAGE
    ]
    selected = (vendor_interfaces or candidates)[-1]
    device = hid.Device(path=selected["path"])

    # Report ID + 64-byte vendor command from the captured protocol.
    command = bytearray(65)
    command[1:6] = [0x55, 0x30, 0xA5, 0x2E, 0x2E]
    device.write(bytes(command))
    response = device.read(64, timeout=150)

    if (
        len(response) >= 5
        and response[0] == 0xAA
        and response[1] == 0x30
        and response[2] == 0xA5
        and 0 <= response[3] <= 100
    ):
        print(response[3])
    else:
        print("N/A")
except Exception:
    print("N/A")
finally:
    if device is not None:
        try:
            device.close()
        except Exception:
            pass
PY
)

if [[ "$result" =~ ^([0-9]|[1-9][0-9]|100)$ ]]; then
    printf '%s%%\n' "$result"
else
    printf 'N/A\n'
fi
