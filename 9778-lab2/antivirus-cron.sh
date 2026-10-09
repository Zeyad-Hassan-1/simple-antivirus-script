#!/bin/bash
cd "$(dirname "$0")"

dir="$1"
malicious_dir="$2"

sleep 23

scan_directory(){
    local src="$1"
    local quarantine="$2"

    # make sure quarantine directory exists
    mkdir -p "$quarantine"

    # Find all filesdirectly in src
    while IFS= read -r file; do
        local filename=$(basename "$file")
        #skip whitelisted
        if [ -f whitelist.txt ] && grep -Fxq "$filename" whitelist.txt; then
            continue
        fi
        local malicious=0

        # 1: Check extension
        case "$file" in
            (*.exe|*.bat|*.vbs|*.scr|*.ps1)
            malicious=1
            ;;
        esac

        # 2: Check content (case insensitive)
        if [ "$malicious" -eq 0 ]; then
            if grep -i -q -E 'virus|trojan|malware|worm|ransomware' "$file"; then
                malicious=1
            fi
        fi

        # If malicious, quarantine it
        if [ "$malicious" -eq 1 ]; then
            echo "$filename is malicious and it is DELETED"
            cp "$file" "$quarantine/$filename"
            rm "$file"
        fi
    done < <(find "$src" -maxdepth 1 -type f)

}


scan_directory "$dir" "$malicious_dir"
