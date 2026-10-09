# Lab 2: Simple Antivirus Daemon

## 1. Overview

This project contains a simple antivirus daemon and a restore tool.

Folder hierarchy:

    studentID-lab2/
    ├── Makefile
    ├── README.md
    ├── antivirusd.sh
    ├── restore.sh
    ├── dir/
    └── malicious_dir/

- `antivirusd.sh` – monitors `dir`, quarantines malicious files into `malicious_dir`.
- `restore.sh` – lets the user restore or permanently delete files from `malicious_dir`.
- `Makefile` – runs the tools and creates `malicious_dir` if needed.
- `dir/` – monitored directory (files only).
- `malicious_dir/` – quarantine directory.

## 2. Prerequisites

Bash and standard GNU utilities are preinstalled on Ubuntu. If `make` is missing, install it with:

    sudo apt update
    sudo apt install make

## 3. How to Run

1. Make scripts executable:

       chmod +x antivirusd.sh restore.sh

2. Start the antivirus daemon:

       make

   Stop with Ctrl+C.

3. Review quarantined files:

       make restore

   For each file, choose:
   - 1 to restore it to `dir`
   - 2 to permanently delete it
   - 3 to leave it as-is and go back to the list

## 4. Where the Malicious Rules Are Defined

Both lists are in `antivirusd.sh` inside the `scan_directory` function.

- Flagged extensions (`.exe`, `.bat`, `.vbs`, `.scr`, `.ps1`) are in the `case` statement.
- Flagged keywords (`virus`, `trojan`, `malware`, `worm`, `ransomware`) are in the `grep -E` pattern.

## Bonus 1: Cron Job

### Prerequisites

- `antivirus-cron.sh` must exist and be executable.
- The `dir` and `malicious_dir` folders must exist.
- Make it executable:

      chmod +x antivirus-cron.sh

### Setup

1. Open your crontab:

       crontab -e

2. Add this line (replace paths with your actual paths):

       * * * * * /path/to/antivirus-cron.sh /path/to/dir /path/to/malicious_dir

3. Save and exit.

4. Verify with:

       crontab -l

The script sleeps 23 seconds at the start, so the scan runs at second 23 of every minute.

### Cron expression for the 3rd Friday of the month at 12:31 am

    31 0 * * 5

This runs every Friday at 00:31. To restrict it to the 3rd Friday only, the script can check the day of the month (it must be between 15 and 21).

## Bonus 2: Whitelist

When a file is restored through `restore.sh` (option 1), its filename is added to `whitelist.txt` in the project folder.  
`antivirusd.sh` (and `antivirus-cron.sh`) check this file during each scan and skip any file whose name is in the whitelist.  
This persists across daemon restarts because `whitelist.txt` is stored on disk.