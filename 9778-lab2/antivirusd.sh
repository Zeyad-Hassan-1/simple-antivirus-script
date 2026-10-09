#!/bin/bash

dir="$1"
malicious_dir="$2"
interval="$3"

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

# First run: if no previous snapshot exists, create one
if [ ! -f directory-info.last ]; then
    echo "First run: scanning creating initial snapshot."
    scan_directory "$dir" "$malicious_dir"
    ls -l "$dir" > directory-info.last
fi

while true; do
    # Take a new snapshot
    ls -l "$dir" > directory-info.new

    # compare the two snapshots
    if diff -q directory-info.last directory-info.new > /dev/null; then
        :
    else
        # change detected, scan
        scan_directory "$dir" "$malicious_dir"
        cp directory-info.new directory-info.last
    fi

    sleep "$interval"
done
