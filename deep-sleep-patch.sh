#!/bin/bash
# Script for Linux Deep Sleep (S3) Patch
# Author: Zebrathor
# Copyright (C) 2026 Zebrathor
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Error, run this script with sudo"
    exit 1
fi

if [[ ! -f /sys/power/mem_sleep ]]; then
    echo "Error, /sys/power/mem_sleep not found on this system"
    exit 1
fi

CONF_FILE="/etc/tmpfiles.d/mem-sleep.conf"

apply() {
    if ! grep -qw "deep" /sys/power/mem_sleep; then
        echo "Error, your laptop does not support 'deep' sleep | Available modes: $(cat /sys/power/mem_sleep 2>/dev/null || echo 'N/A')"
        return 1
    fi

    echo "==> Configuring deep sleep mode via systemd-tmpfiles..."
    echo "w /sys/power/mem_sleep - - - - deep" > "$CONF_FILE"
    systemd-tmpfiles --create "$CONF_FILE"

    echo "==> Checking current status:"
    cat /sys/power/mem_sleep
}

revert() {
    echo "==> Reverting configuration..."

    # 1. Remove persistence file for future boots
    if [[ -f "$CONF_FILE" ]]; then
        rm -f "$CONF_FILE"
        echo "==> File $CONF_FILE removed."
    else
        echo "==> File $CONF_FILE did not exist."
    fi

    if grep -qw "s2idle" /sys/power/mem_sleep; then
        echo "s2idle" > /sys/power/mem_sleep
        echo "==> Sleep mode restored to 's2idle'"
    fi

    echo "==> Checking current status:"
    cat /sys/power/mem_sleep
}

while true; do
    clear
    echo "**************************************************"
    echo "              Suspend Mode Manager"
    echo "**************************************************"
    echo "Current status : $(cat /sys/power/mem_sleep)"
    if [[ -f "$CONF_FILE" ]]; then
        echo "Patch status   : INSTALLED ($CONF_FILE)"
    else
        echo "Patch status   : NOT INSTALLED"
    fi
    echo "--------------------------------------------------"
    echo "1) Apply patch, enable 'deep' sleep mode"
    echo "2) Revert patch, restore 's2idle' and remove conf"
    echo "3) Exit"
    echo "--------------------------------------------------"
    read -rp "Select an option [1-3]: " option
    echo ""

    case $option in
        1)
            apply
            read -rp $'\nPress Enter to continue...'
            ;;
        2)
            revert
            read -rp $'\nPress Enter to continue...'
            ;;
        3)
            echo "Bye..."
            exit 0
            ;;
        *)
            echo "Invalid option, try again"
            sleep 1
            ;;
    esac
done
