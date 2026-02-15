#!/bin/bash
MODE=$1

# Check if Feral GameMode is installed
if ! command -v gamemoded &> /dev/null; then
    echo "NOT_INSTALLED"
    # Even if not installed, we still run your existing Hyprland toggles
fi

if [ "$MODE" == "on" ]; then
    touch "/tmp/hypr_gamemode_active"
    pkill -STOP brave
    pkill -STOP discord
    hyprctl keyword decoration:blur:enabled 0
    hyprctl keyword animations:enabled 0

    # Start Feral GameMode if available
    if command -v gamemoded &> /dev/null; then
        gamemoded -r
    fi

elif [ "$MODE" == "off" ]; then
    rm -f "/tmp/hypr_gamemode_active"
    pkill -CONT brave
    pkill -CONT discord
    hyprctl keyword decoration:blur:enabled 1
    hyprctl keyword animations:enabled 1

    # Stop Feral GameMode if available
    if command -v gamemoded &> /dev/null; then
        pkill -SIGINT gamemoded
    fi
fi
