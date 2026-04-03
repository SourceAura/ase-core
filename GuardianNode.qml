/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * COMPONENT: Guardian Node — Cyberdeck Edition
 * ===================================================================== */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.Commons
import qs.Widgets
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null
    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // --- NOCTALIA SIZING ---
    readonly property string screenName: screen?.name ?? ""
    readonly property string barPosition: Settings.getBarPositionForScreen(screenName)
    readonly property bool isBarVertical: barPosition === "left" || barPosition === "right"
    readonly property real capsuleHeight: Style.getCapsuleHeightForScreen(screenName)
    readonly property real barFontSize: Style.getBarFontSizeForScreen(screenName)

    readonly property real contentWidth: row.implicitWidth + (Style.marginM * 2)
    readonly property real contentHeight: capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // --- STATE ---
    property string daemonState: "checking"
    property bool panelOpen: false

    // Uptime / latency tracking
    property int uptimeSeconds: 0
    property int lastLatencyMs: -1
    property var healthLog: []          // array of { time: string, status: string, ms: int }
    property var pollStart: 0

    readonly property color glowColor:   daemonState === "alive"    ? "#00ffaa"
                                       : daemonState === "dead"     ? "#f43f5e"
                                                                    : "#fbbf24"
    readonly property color dimColor:    daemonState === "alive"    ? "#004433"
                                       : daemonState === "dead"     ? "#3a0010"
                                                                    : "#3a2e00"
    readonly property string stateLabel: daemonState === "alive"    ? "NOMINAL"
                                       : daemonState === "dead"     ? "CRITICAL"
                                                                    : "SCANNING"

    // Uptime counter — only ticks when alive
    Timer {
        interval: 1000
        running: daemonState === "alive"
        repeat: true
        onTriggered: root.uptimeSeconds++
    }

    // Reset uptime when daemon dies
    onDaemonStateChanged: {
        if (daemonState === "dead") root.uptimeSeconds = 0
    }

    // Health poll
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.pollStart = Date.now()
            var req = new XMLHttpRequest()
            req.onreadystatechange = function() {
                if (req.readyState !== XMLHttpRequest.DONE) return
                var latency = Date.now() - root.pollStart
                var ok = req.status === 200
                root.daemonState = ok ? "alive" : "dead"
                root.lastLatencyMs = ok ? latency : -1

                // Append to log, keep last 6 entries
                var entry = {
                    time: Qt.formatTime(new Date(), "hh:mm:ss"),
                    status: ok ? "OK" : "FAIL",
                    ms: ok ? latency : -1
                }
                var log = root.healthLog.slice()
                log.unshift(entry)
                if (log.length > 6) log = log.slice(0, 6)
                root.healthLog = log
            }
            req.open("GET", "http://127.0.0.1:8000/health", true)
            req.onerror = function() {
                root.daemonState = "dead"
                root.lastLatencyMs = -1
                var entry = { time: Qt.formatTime(new Date(), "hh:mm:ss"), status: "ERR", ms: -1 }
                var log = root.healthLog.slice()
                log.unshift(entry)
                if (log.length > 6) log = log.slice(0, 6)
                root.healthLog = log
            }
            req.send()
        }
    }

    // Cursor blink
    property bool cursorVisible: true
    Timer {
        interval: 530
        running: true
        repeat: true
        onTriggered: root.cursorVisible = !root.cursorVisible
    }

    function formatUptime(secs) {
        if (secs < 60) return secs + "s"
        if (secs < 3600) return Math.floor(secs / 60) + "m " + (secs % 60) + "s"
        return Math.floor(secs / 3600) + "h " + Math.floor((secs % 3600) / 60) + "m"
    }

    // --- BAR WIDGET ---
    Rectangle {
        id: capsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: (mouseArea.containsMouse || root.panelOpen) ? root.dimColor : "transparent"
        radius: Style.radiusM
        border.color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, root.panelOpen ? 0.6 : 0.25)
        border.width: 1

        Behavior on color       { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 5

            NText {
                text: "["
                color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.5)
                font.family: "monospace"
                font.weight: Font.Bold
                pointSize: root.barFontSize
            }

            Rectangle {
                width: 6; height: 6; radius: 3
                color: root.glowColor
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.glowColor
                    shadowBlur: 12
                }
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.2; duration: 900; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                }
            }

            NText {
                text: "ASE"
                color: root.glowColor
                font.family: "monospace"
                font.weight: Font.Bold
                font.letterSpacing: 2
                pointSize: root.barFontSize
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: root.glowColor
                    shadowBlur: 8
                }
            }

            NText {
                text: ":"
                color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.4)
                font.family: "monospace"
                pointSize: root.barFontSize
            }

            NText {
                text: root.stateLabel + (root.cursorVisible ? "█" : " ")
                color: root.glowColor
                font.family: "monospace"
                font.weight: Font.Medium
                font.letterSpacing: 1
                pointSize: root.barFontSize * 0.85
                Behavior on color { ColorAnimation { duration: 300 } }
            }

            NText {
                text: "]"
                color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.5)
                font.family: "monospace"
                font.weight: Font.Bold
                pointSize: root.barFontSize
            }
        }

        // Scanline
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            clip: true
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.12)
                NumberAnimation on y {
                    loops: Animation.Infinite
                    from: 0; to: capsule.height
                    duration: 2200
                    easing.type: Easing.Linear
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.panelOpen = !root.panelOpen
        onEntered: {
            if (!root.panelOpen) {
                let s = root.daemonState === "alive"   ? "ASE Core: Online"
                      : root.daemonState === "dead"    ? "ASE Core: CRITICAL FAILURE"
                                                       : "ASE Core: Scanning..."
                TooltipService.show(root, s, BarService.getTooltipDirection())
            }
        }
        onExited: TooltipService.hide()
    }

    // --- DROPDOWN PANEL ---
    PanelWindow {
        id: dropdownPanel
        visible: root.panelOpen
        screen: root.screen

        anchors {
            top: barPosition === "top"
            bottom: barPosition === "bottom" || barPosition === ""
        }

        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        width: screen?.width ?? 1920
        height: screen?.height ?? 1080

        color: "transparent"

        // Click-outside dismiss — covers the whole screen
        MouseArea {
            anchors.fill: parent
            onClicked: root.panelOpen = false
        }

        Rectangle {
            id: panelBg
            // Float the card — don't fill the full-screen overlay window
            width: 240
            height: panelColumn.implicitHeight + (Style.marginM * 2)
            // Align to bar edge; barPosition drives top vs bottom
            x: Style.marginM
            y: barPosition === "top" ? Style.marginS : (parent.height - height - Style.marginS)
            color: "#0d1117"
            radius: Style.radiusM
            border.color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.35)
            border.width: 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.25)
                shadowBlur: 20
            }

            ColumnLayout {
                id: panelColumn
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Style.marginM
                }
                spacing: Style.marginS

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    NText {
                        text: "// ASE GUARDIAN"
                        color: root.glowColor
                        font.family: "monospace"
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        pointSize: root.barFontSize * 0.9
                        Layout.fillWidth: true
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: root.glowColor
                            shadowBlur: 6
                        }
                    }
                    // Close button
                    NText {
                        text: "✕"
                        color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.5)
                        font.family: "monospace"
                        pointSize: root.barFontSize * 0.85
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.panelOpen = false
                        }
                    }
                }

                // Divider
                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.2) }

                // Stats grid
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: Style.marginS
                    rowSpacing: 3

                    NText { text: "STATUS"; color: "#4a5568"; font.family: "monospace"; pointSize: root.barFontSize * 0.75; font.letterSpacing: 1 }
                    NText {
                        text: root.stateLabel
                        color: root.glowColor
                        font.family: "monospace"
                        font.weight: Font.Bold
                        pointSize: root.barFontSize * 0.75
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }

                    NText { text: "UPTIME"; color: "#4a5568"; font.family: "monospace"; pointSize: root.barFontSize * 0.75; font.letterSpacing: 1 }
                    NText {
                        text: daemonState === "alive" ? root.formatUptime(root.uptimeSeconds) : "—"
                        color: "#e2e8f0"
                        font.family: "monospace"
                        pointSize: root.barFontSize * 0.75
                    }

                    NText { text: "LATENCY"; color: "#4a5568"; font.family: "monospace"; pointSize: root.barFontSize * 0.75; font.letterSpacing: 1 }
                    NText {
                        text: root.lastLatencyMs >= 0 ? root.lastLatencyMs + " ms" : "—"
                        color: root.lastLatencyMs >= 0 && root.lastLatencyMs < 100 ? "#00ffaa"
                             : root.lastLatencyMs >= 100 ? "#fbbf24" : "#4a5568"
                        font.family: "monospace"
                        pointSize: root.barFontSize * 0.75
                    }
                }

                // Divider
                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.2) }

                // Health log
                NText {
                    text: "HEALTH LOG"
                    color: "#4a5568"
                    font.family: "monospace"
                    font.letterSpacing: 1
                    pointSize: root.barFontSize * 0.75
                }

                Repeater {
                    model: root.healthLog
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Style.marginS
                        NText {
                            text: modelData.time
                            color: "#4a5568"
                            font.family: "monospace"
                            pointSize: root.barFontSize * 0.72
                        }
                        NText {
                            text: modelData.status
                            color: modelData.status === "OK" ? "#00ffaa" : "#f43f5e"
                            font.family: "monospace"
                            font.weight: Font.Bold
                            pointSize: root.barFontSize * 0.72
                        }
                        NText {
                            text: modelData.ms >= 0 ? modelData.ms + "ms" : ""
                            color: "#718096"
                            font.family: "monospace"
                            pointSize: root.barFontSize * 0.72
                            Layout.fillWidth: true
                        }
                    }
                }

                // Divider
                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.2) }

                // Restart button
                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: Style.radiusM
                    color: restartHover.containsMouse
                           ? Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.15)
                           : "transparent"
                    border.color: Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.4)
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    NText {
                        anchors.centerIn: parent
                        text: "⟳  RESTART DAEMON"
                        color: root.glowColor
                        font.family: "monospace"
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                        pointSize: root.barFontSize * 0.78
                    }

                    MouseArea {
                        id: restartHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.daemonState = "checking"
                            root.uptimeSeconds = 0
                            Quickshell.execDetached(["systemctl", "--user", "restart", "ase-daemon"])
                        }
                    }
                }

                // bottom padding
                Item { height: 2 }
            }
        }
    }
}
