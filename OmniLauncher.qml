import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Effects
import "."

Window {
    id: omniRoot
    width: 700
    height: 64
    
    // Position it elegantly in the upper-third of the screen
    x: (Screen.width - width) / 2
    y: (Screen.height * 0.25) - (height / 2)
    
    color: "transparent"
    
    // Force it to float above all other OS windows
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    // Animation Binding
    visible: opacity > 0
    opacity: AseState.omniVisible ? 1.0 : 0.0
    scale: AseState.omniVisible ? 1.0 : 0.95
    
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack; overshoot: 1.1 } }

    // Auto-focus the input box when summoned
    onOpacityChanged: {
        if (opacity === 1.0) omniInput.forceActiveFocus()
        if (opacity === 0.0) omniInput.text = "" // Purge on close
    }

    // Thematic Resonance (Matches the Omnibar)
    property color glowColor: AseState.hazardLevel === "rose" ? "#f43f5e" :
                              AseState.hazardLevel === "amber" ? "#fbbf24" : "#00ffaa"

    // The Glass Shell
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0.04, 0.05, 0.08, 0.85) // Dark Ethereal Glass
        border.color: Qt.rgba(glowColor.r, glowColor.g, glowColor.b, 0.4)
        border.width: 1
        radius: 12
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(glowColor.r, glowColor.g, glowColor.b, 0.2)
            shadowBlur: 30
        }

        // The AI Input Field
        TextInput {
            id: omniInput
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 24
            verticalAlignment: TextInput.AlignVCenter
            
            color: glowColor
            font.family: "monospace"
            font.pixelSize: 20
            font.bold: true
            selectionColor: glowColor
            
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "Awaiting Directive..."
                color: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                font.family: "monospace"
                font.pixelSize: 20
                font.italic: true
                visible: !omniInput.text && !omniInput.activeFocus
            }
            
            // Execute Command & Auto-Dismiss
            onAccepted: {

                AseState.sendCommand(text)
                AseState.omniVisible = false
                text = ""
                
                console.log("[OMNI ENGINE] Executing:", text)
                
                // Example local routing (Connect this to your actual Ase API later)
                if (text.startsWith("/strike")) AseState.hazardLevel = "rose"
                else if (text.startsWith("/clear")) AseState.hazardLevel = "cyan"
                
                AseState.omniVisible = false // Dismiss after command
            }

            // Press Escape to dismiss
            Keys.onEscapePressed: {
                AseState.omniVisible = false
            }
        }
    }
}