#!/bin/bash

dir="$1"
malicious_dir="$2"

while true; do
    # Collect files in malicious_dir into an array
    mapfile -t files < <(find "$malicious_dir" -maxdepth 1 -type f)

    # If no files, print message and exit
    if [ ${#files[@]} -eq 0 ]; then
        echo "no malicious files to review."
        exit 0
    fi

    # Print numbered list
    echo "Files in quarantine:"
    for i in "${!files[@]}";do
        echo "$((i+1)). $(basename "${files[$i]}")"
    done

    # Ask user to pick one
    read -p "Pick a file by number: " choice
    
    # Validate choice
    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#files[@]} ]; then
        echo "invalid choice"
        continue
    fi

    # Get the selected file path
    selected="${files[$((choice-1))]}"
    filename=$(basename "$selected")

    # show options
    echo "1. restore"
    echo "2.permanently delete"
    echo "3. back to list"
    read -p "Enter 1,2 or 3:" action

    case "$action" in
        1)
            mv "$selected" "$dir/$filename"
            echo "restored"
            # Add to whitelist if not there
            if ! grep -Fxq "$filename" whitelist.txt 2>/dev/null; then
                echo "$filename" >> whitelist.txt
            fi
            ;;
        2)
            rm "$selected"
            echo "permanently deleted"
            ;;
        3)
            ;;
        *)
            echo "invalid action"
    esac
done