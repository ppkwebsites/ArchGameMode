import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    // Colors dependency removed

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/scripts/game-mode.sh"
    readonly property string stateFile: "/tmp/hypr_gamemode_active"

    property bool isGameMode: false
    property bool feralInstalled: false
    property string cpuUsage: "0%"
    property string ramUsage: "0%"

    Component.onCompleted: {
        checkFeral.running = true;
        stateChecker.running = true;
        updateStats();
    }

    // --- Processes ---
    Process {
        id: checkFeral
        command: ["sh", "-c", "command -v gamemoded >/dev/null && echo 'yes' || echo 'no'"]
        stdout: SplitParser {
            onRead: function(line) { feralInstalled = (line.trim() === "yes") }
        }
    }

    Process {
        id: stateChecker
        command: ["test", "-f", stateFile]
        onExited: function(exitCode) {
            if (!toggleProc.running) {
                isGameMode = (exitCode === 0);
            }
        }
    }

    PanelWindow {
        id: window
        anchors.top: true
        anchors.right: true
        exclusiveZone: 0
        implicitHeight: 220
        implicitWidth: 360
        color: "transparent"

        // FIX: Removed WBlur.enabled to stop the "Non-existent attached object" error.
        // To get blur on Hyprland/Wayland, it's usually handled via window rules
        // or the Mask property in Quickshell, but for pure QML stability:

        // Blinking Border
        Rectangle {
            id: glowEffect
            anchors.fill: body
            anchors.margins: -6
            radius: body.radius + 2
            color: "transparent"
            border.width: 4
            border.color: "#89b4fa" // Blue accent
            visible: isGameMode
            opacity: isGameMode ? 0.8 : 0.0

            SequentialAnimation on opacity {
                running: isGameMode
                loops: Animation.Infinite
                NumberAnimation { to: 0.2; duration: 800; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 0.8; duration: 800; easing.type: Easing.InOutQuad }
            }
        }

        Rectangle {
            id: body
            x: window.implicitWidth
            y: 10
            width: parent.width - 20
            height: parent.height - 20
            radius: 10

            Behavior on x {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            // Black with 60% transparency
            color: Qt.rgba(0, 0, 0, 0.6)

            border.width: 2
            border.color: isGameMode ? "#89b4fa" : "#313244"

            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                Text {
                    text: isGameMode ? "SYSTEM: GAME MODE" : "SYSTEM: NORMAL"
                    color: isGameMode ? "#89b4fa" : "#cdd6f4"
                    font.pixelSize: 22
                    font.bold: true
                }

                Row {
                    spacing: 30
                    Column {
                        Text { text: "CPU Usage"; color: "#a6adc8"; font.pixelSize: 14 }
                        Text { text: cpuUsage; color: isGameMode ? "#89b4fa" : "#f38ba8"; font.pixelSize: 24; font.bold: true }
                    }
                    Column {
                        Text { text: "RAM Usage"; color: "#a6adc8"; font.pixelSize: 14 }
                        Text { text: ramUsage; color: "#fab387"; font.pixelSize: 24; font.bold: true }
                    }
                }

                Column {
                    visible: !feralInstalled
                    spacing: 4
                    width: parent.width - 40
                    Text { text: "⚠️ Feral GameMode not found"; color: "#f38ba8"; font.pixelSize: 13; font.bold: true }
                    Text {
                        text: "Run: yay -S gamemode lib32-gamemode"
                        color: "#a6adc8"
                        font.pixelSize: 11
                        font.family: "Monospace"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }

                Row {
                    spacing: 15
                    anchors.horizontalCenter: parent.horizontalCenter

                    Rectangle {
                        width: 120; height: 45; radius: 8
                        color: isGameMode ? "#313244" : "#89b4fa"
                        Text { anchors.centerIn: parent; text: "ACTIVATE"; color: "white"; font.bold: true }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                isGameMode = true
                                toggleProc.command = ["sh", scriptPath, "on"]
                                toggleProc.running = false
                                toggleProc.running = true
                            }
                        }
                    }

                    Rectangle {
                        width: 120; height: 45; radius: 8
                        color: !isGameMode ? "#313244" : "#f38ba8"
                        Text { anchors.centerIn: parent; text: "DEACTIVATE"; color: "white"; font.bold: true }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                isGameMode = false
                                toggleProc.command = ["sh", scriptPath, "off"]
                                toggleProc.running = false
                                toggleProc.running = true
                            }
                        }
                    }
                }
            }
        }

        Timer {
            interval: 80
            running: true
            repeat: false
            onTriggered: {
                body.x = 10
            }
        }
    }

    Process { id: toggleProc }

    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: updateStats()
    }

    function updateStats() {
        cpuProc.running = false; cpuProc.running = true;
        ramProc.running = false; ramProc.running = true;

        if (!toggleProc.running) {
            stateChecker.running = false;
            stateChecker.running = true;
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep '%Cpu(s)' | awk '{print $2 + $4}'"]
        stdout: SplitParser {
            onRead: function(line) {
                let val = parseFloat(line.trim());
                if (!isNaN(val)) cpuUsage = val.toFixed(1) + "%";
            }
        }
    }

    Process {
        id: ramProc
        command: ["sh", "-c", "free -m | awk '/Mem:/ {printf \"%.0f%%\", $3/$2*100}'"]
        stdout: SplitParser {
            onRead: function(line) { ramUsage = line.trim(); }
        }
    }
}
