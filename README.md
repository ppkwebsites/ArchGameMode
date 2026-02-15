Youtube: https://youtu.be/n8Ks0pHwuA8

# ArchGameMode
Game mode optimization for Arch
Hyprland OSD & GameMode Optimization
Maximize your Linux gaming performance with custom GameMode toggles and On-Screen Display (OSD) feedback for the Hyprland compositor. This project provides the scripts and configuration needed to disable heavy animations and blur with a single keybind, ensuring every bit of GPU power goes to your game.

Features
Dynamic GameMode Toggle: Instantly disable blur, shadows, and animations to reduce system latency.

Custom OSD Notifications: Visual feedback when switching modes so you know exactly when your system is optimized.

Performance Driven: Lightweight scripts designed for minimal overhead.

Easy Config Integration: Works directly with your existing hyprland.conf file.

Prerequisites
Before setting this up, ensure you have the following installed on your system:

Hyprland: The tiling Wayland compositor.

GameMode: Feral Interactive's tool for Linux performance.

Wob or SwayNC: (Optional) For the OSD visual bars or notifications.

Installation & Setup
1. Save the Optimization Script
Create a file named gamemode.sh in your Hyprland scripts folder (usually ~/.config/hypr/scripts/) and paste your script logic there.

2. Make the Script Executable
Open your terminal and run:
chmod +x ~/.config/hypr/scripts/gamemode.sh

3. Update your Hyprland Configuration
Add a keybind to your hyprland.conf to trigger the script. For example, using Super + G:

bind = $mainMod, G, exec, ~/.config/hypr/scripts/gamemode.sh

How It Works
The script uses hyprctl to communicate with the compositor in real-time. When activated, it sends a batch command to set:

animations:enabled to 0

decoration:drop_shadow to 0

decoration:blur:enabled to 0

When toggled off, it restores your beautiful desktop effects for normal productivity.

Video Tutorial
For a detailed walkthrough of the code and a demonstration of the OSD in action, check out the full guide here:
https://youtu.be/n8Ks0pHwuA8

Contributing
Suggestions for further optimization or better OSD styles are always welcome. Feel free to fork this repo, open an issue, or submit a pull request!

License
This project is open-source and available under the MIT License.

Youtube: https://youtu.be/n8Ks0pHwuA8
