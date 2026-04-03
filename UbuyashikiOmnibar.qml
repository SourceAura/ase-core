/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * AUTHOR: SourceAura (Architect)
 * COMPONENT: Ubuyashiki Omnibar
 * LORE: The omnipresent command strip. It serves as the bridge between 
 * the Architect and the Autonomous Security Engine. It monitors 
 * Kasugai dispatches and provides quick-access to the Hashira applets.
 * ===================================================================== */

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "."

Rectangle {
    id: omnibarRoot
    // The root is entirely transparent, taking full screen width if docked
    color: "transparent"
    implicitWidth: Screen.width
    implicitHeight: 46

    // The Sleek Center Pill
    Rectangle {
        id: glassPill
        width: Math.min(900, parent.width * 0.8)
        height: 36
        anchors.centerIn: parent
        radius: 18
        
        color: Qt.rgba(0.03, 0.04, 0.06, 0.85) // Deep Abyssal Glass
        border.color: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.3)
        border.width: 1
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.8)
            shadowBlur: 20
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            spacing: 20

            // 1. Kagaya Branding & Status
            RowLayout {
                spacing: 10
                
                // The Glowing Status LED
                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: AseState.themeGlow
                    
                    // Native QML Glow implementation
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: AseState.themeGlow
                        shadowBlur: 10
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 0
                    }
                    
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 2000; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
                    }
                }
                
                Text {
                    text: "ASE // KAGAYA"
                    color: "white"
                    font.family: "monospace"
                    font.pixelSize: 12
                    font.letterSpacing: 2
                    font.bold: true
                    
                    // Click to toggle OmniLauncher manually
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: AseState.omniVisible = !AseState.omniVisible
                    }
                }
            }

            // 2. Hashira Applet Dock
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 25
                
                Repeater {
                    model: ["GRIMOIRE", "DOJO", "WISTERIA"]
                    delegate: Text {
                        text: modelData
                        color: AseState.activeApplet === modelData ? AseState.themeGlow : Qt.rgba(1, 1, 1, 0.4)
                        font.family: "monospace"
                        font.pixelSize: 11
                        font.letterSpacing: 1
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: parent.color = AseState.themeGlow
                            onExited: parent.color = AseState.activeApplet === modelData ? AseState.themeGlow : Qt.rgba(1, 1, 1, 0.4)
                            onClicked: AseState.activeApplet = (AseState.activeApplet === modelData) ? "none" : modelData
                        }
                    }
                }
            }

            // 3. Kasugai Dispatch (Right Aligned)
            Item { Layout.fillWidth: true } // Spacer
            
            Text {
                text: "> " + AseState.kasugaiMessage
                color: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.7)
                font.family: "monospace"
                font.pixelSize: 10
            }
        }
    }
}