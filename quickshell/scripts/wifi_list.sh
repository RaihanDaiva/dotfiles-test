#!/bin/bash
# wifi_list.sh — Output list Wi-Fi yang terdedup & urut sinyal (active first)
# Format setiap baris: active:ssid:signal
# active = "yes" jika sedang terkoneksi, "no" jika tidak

nmcli -t -f active,ssid,signal dev wifi 2>/dev/null \
  | awk -F: '
    /^yes:/ { print; next }
    $2 != "" && !seen[$2]++ { no_arr[NR] = $0 }
    END {
      for (i=1; i<=length(no_arr); i++) print no_arr[i]
    }' \
  | grep -v '::' \
  | head -8
