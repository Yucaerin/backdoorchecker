#!/bin/bash

# Usage: ./checker.sh list.txt [threads]

LIST="$1"
THREADS="${2:-10}"
OUTPUT="live-shell.txt"

if [ -z "$LIST" ] || [ ! -f "$LIST" ]; then
    echo "Usage: $0 list.txt [threads]"
    echo "Example: $0 shells.txt 20"
    exit 1
fi

> "$OUTPUT" 2>/dev/null

check_shell() {
    local url="$1"
    local status
    local response
    local size
    
    # Normalize URL
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"
    
    [ -z "$url" ] && return
    
    [[ "$url" =~ ^https?:// ]] || url="http://$url"
    
    response=$(curl -sL --max-redirs 5 --connect-timeout 10 --max-time 15 \
        -A "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0" \
        -w "\nHTTP_CODE:%{http_code}\nSIZE:%{size_download}\n" \
        "$url" 2>/dev/null)
    
    status=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    size=$(echo "$response" | grep "SIZE:" | cut -d: -f2)
    body=$(echo "$response" | sed -n '1,/HTTP_CODE:/p' | head -n -1)
    
    case "$status" in
        200|201|202|204)
            if echo "$body" | grep -qiE "(shell|upload|backdoor|cmd|exec|system|passthru|eval|uname|hacked|root|admin|wso|b374k|china|shellbot|file manager)"; then
                echo -e "\e[32m[✅ SHELL CONFIRMED] $url (Status: $status | Size: ${size}b)\e[0m"
                echo "$url" >> "$OUTPUT"
            else
                echo -e "\e[33m[⚠️  LIVE] $url (Status: $status | Size: ${size}b) - Need manual check\e[0m"
            fi
            ;;
        301|302|307|308)
            echo -e "\e[36m[↪️  REDIRECT] $url (Status: $status)\e[0m"
            ;;
        403)
            if echo "$body" | grep -qiE "(forbidden|403|cloudflare|akamai|incapsula)"; then
                echo -e "\e[35m[🛡️  BLOCKED/WAF] $url (Status: 403)\e[0m"
            else
                echo -e "\e[33m[⚠️  POSSIBLE] $url (Status: 403) - Might be protected shell\e[0m"
            fi
            ;;
        401)
            echo -e "\e[33m[🔒 AUTH REQUIRED] $url (Status: 401) - Possible protected shell\e[0m"
            ;;
        000)
            echo -e "\e[31m[❌ TIMEOUT/REFUSED] $url\e[0m"
            ;;
        *)
            echo -e "\e[31m[❌ DEAD] $url (Status: ${status:-Unknown})\e[0m"
            ;;
    esac
}

export -f check_shell
export OUTPUT

echo "[*] Scanning $(wc -l < "$LIST") URLs with $THREADS threads..."
echo "[*] Results saved to: $OUTPUT"
echo ""

cat "$LIST" | xargs -P "$THREADS" -I {} bash -c 'check_shell "$@"' _ {}

echo ""
echo "[*] Done! Found $(wc -l < "$OUTPUT" 2>/dev/null || echo 0) live shells."
