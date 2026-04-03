import QtQuick
import QtQuick.Window

Item {
    id: desktopRoot
    anchors.fill: parent
    
    property real reticleX: width / 2
    property real reticleY: height / 2
    property real normX: 0
    property real normY: 0

    // Architect Focus Tracking
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        
        onPositionChanged: (mouse) => {
            desktopRoot.reticleX = mouse.x
            desktopRoot.reticleY = mouse.y
            
            // Normalize coordinates (-1 to 1) for the parallax terminal
            desktopRoot.normX = (mouse.x / width) * 2 - 1
            desktopRoot.normY = (mouse.y / height) * 2 - 1
        }
    }

    // Etheric Fluid Base
    Rectangle {
        anchors.fill: parent
        z: -1
        color: "#05070a"
        gradient: RadialGradient {
            centerX: desktopRoot.reticleX; centerY: desktopRoot.reticleY
            focalX: desktopRoot.reticleX; focalY: desktopRoot.reticleY
            centerRadius: Math.max(desktopRoot.width, desktopRoot.height) * 0.8
            GradientStop { position: 0.0; color: Qt.rgba(0.0, 1.0, 0.66, 0.06) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

   // Phase 2 Mount: The Abyssal Terminal
    AbyssalTerminal {
        anchors.centerIn: parent
        z: 100
        
        targetNormX: desktopRoot.normX
        targetNormY: desktopRoot.normY

        // Tracer: Log when the terminal receives the signal
        onOpacityChanged: console.log("[ASE TERMINAL] Opacity updating to:", opacity)

        // Keep it simple for debugging: Just toggle opacity
        opacity: AseState.terminalVisible ? 1.0 : 0.0
        scale: AseState.terminalVisible ? 1.0 : 0.95
        
        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }
        Behavior on scale {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; overshoot: 1.2 }
        }
    }

    // Architect Reticle
    Item {
        x: desktopRoot.reticleX - width/2
        y: desktopRoot.reticleY - height/2
        width: 30; height: 30
        z: 9999
        
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(0.0, 1.0, 0.66, 0.6)
            border.width: 1
        }
        
        Rectangle {
            anchors.centerIn: parent
            width: 2; height: 2
            radius: 1
            color: "#00ffaa"
        }
    }
}