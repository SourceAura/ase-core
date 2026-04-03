/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * AUTHOR: SourceAura (Architect)
 * COMPONENT: OmniLauncher Command Palette
 * LORE: The Macro Sigil Engine.
 * ===================================================================== */

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import "."

Window {
    id: omniRoot
    
    // Explicitly lock geometry so Niri cannot squash the window to 0x0
    width: 750
    height: 64
    minimumWidth: 750
    minimumHeight: 64
    maximumWidth: 750
    maximumHeight: 64
    
    title: "ase-omnilauncher" 
    color: "transparent"
    
    // THE FIX: Removed Qt.Dialog to prevent compositor crashes.
    // Standard XDG-Toplevel floating flags.
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    visible: opacity > 0
    opacity: AseState.omniVisible ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    onOpacityChanged: {
        if (opacity === 1.0) {
            omniRoot.requestActivate()
            sigilInput.forceActiveFocus()
        }
        if (opacity === 0.0) {
            sigilInput.text = ""
        }
    }

    Item {
        anchors.fill: parent
        scale: AseState.omniVisible ? 1.0 : 0.95
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0.04, 0.05, 0.08, 0.95) // Darkened slightly for contrast
            border.color: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.8)
            border.width: 1.5
            radius: 12
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.2)
                shadowBlur: 30
            }

            TextInput {
                id: sigilInput
                anchors.fill: parent
                anchors.leftMargin: 24
                anchors.rightMargin: 24
                verticalAlignment: TextInput.AlignVCenter
                
                color: AseState.themeGlow
                font.family: "monospace"
                font.pixelSize: 22
                selectionColor: AseState.themeGlow
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.IBeamCursor
                    onClicked: sigilInput.forceActiveFocus()
                }
                
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Cast Sigil..."
                    color: Qt.rgba(1, 1, 1, 0.4) // High contrast placeholder
                    font.family: "monospace"
                    font.pixelSize: 22
                    font.italic: true
                    visible: !sigilInput.text && !sigilInput.activeFocus
                }
                
                Keys.onEscapePressed: AseState.omniVisible = false
                
                onAccepted: {
                    if (text === "/strike") AseState.hazardLevel = "rose"
                    else if (text === "/forge") AseState.hazardLevel = "amber"
                    else if (text === "/clear") AseState.hazardLevel = "cyan"
                    else AseState.kasugaiMessage = text.toUpperCase()
                    
                    AseState.omniVisible = false
                }
            }
        }
    }
}