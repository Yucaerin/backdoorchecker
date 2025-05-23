#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: $0 list.txt"
    exit 1
fi

for s in $(cat "$1"); do
    # Cek HTTP status code
    status=$(curl -s -o /dev/null -w "%{http_code}" -m 5 -A "Mozilla/5.0 (X11; Linux x86_64)" "$s")

    if [[ "$status" == "200" ]]; then
        echo "[✅] SHELL LIVE => $s"
        echo "$s" >> live-shell.txt
    else
        echo "[❌] SHELL TIDAK LIVE => $s"
    fi
done
