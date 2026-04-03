/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * AUTHOR: SourceAura (Architect)
 * COMPONENT: OmniLauncher Command Palette
 * LORE: The Macro Sigil Engine. A direct, high-priority neural link to 
 * the Ase backend. Allows the Architect to cast commands, query 
 * intelligence, and execute strikes instantly from any workspace.
 * ===================================================================== */

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import "."

Window {
    id: omniRoot
    width: 750
    height: 64
    
    // Critical for Wayland to identify it for Niri rules
    title: "ase-omnilauncher" 
    
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.ToolTip

    visible: opacity > 0
    opacity: AseState.omniVisible ? 1.0 : 0.0
    scale: AseState.omniVisible ? 1.0 : 0.95
    
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack; overshoot: 1.05 } }

    onOpacityChanged: {
        if (opacity === 1.0) sigilInput.forceActiveFocus()
        if (opacity === 0.0) sigilInput.text = ""
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.04, 0.05, 0.08, 0.9)
        border.color: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.6)
        border.width: 1.5
        radius: 12
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.15)
            shadowBlur: 40
        }

        // Input Field
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
            
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "Cast Sigil..."
                color: Qt.rgba(1, 1, 1, 0.2)
                font.family: "monospace"
                font.pixelSize: 22
                font.italic: true
                visible: !sigilInput.text && !sigilInput.activeFocus
            }
            
            Keys.onEscapePressed: AseState.omniVisible = false
            
            onAccepted: {
                // Test Commands
                if (text === "/strike") AseState.hazardLevel = "rose"
                else if (text === "/forge") AseState.hazardLevel = "amber"
                else if (text === "/clear") AseState.hazardLevel = "cyan"
                else AseState.kasugaiMessage = text.toUpperCase()
                
                AseState.omniVisible = false
            }
        }
    }
}