import QtQuick
import QtQuick.Window
import "." 

// --- CRITICAL FIX: Changed from Item to Window ---
Window {
    id: desktopRoot
    visible: true
    width: Screen.width
    height: Screen.height
    color: "transparent"
    
    // Forces the window to act as a background overlay
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint
    
    property real reticleX: width / 2
    property real reticleY: height / 2
    property real normX: 0
    property real normY: 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        // Tells Wayland to capture left and right clicks
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onPositionChanged: (mouse) => {
            reticle.mouseX = mouse.x
            reticle.mouseY = mouse.y
            desktopRoot.normX = (mouse.x / width) * 2 - 1
            desktopRoot.normY = (mouse.y / height) * 2 - 1
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // Kinetic Left Click
                reticle.firePulse(mouse.x, mouse.y, false)
            } else if (mouse.button === Qt.RightButton) {
                // Right Click -> Nemotron Deep Scan
                AseState.isNemotronScanning = !AseState.isNemotronScanning
                reticle.firePulse(mouse.x, mouse.y, true)
            }
        }
    }

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

    // The Terminal Mount
    AbyssalPanel {
        anchors.centerIn: parent
        z: 100
        
        targetNormX: desktopRoot.normX
        targetNormY: desktopRoot.normY

        // --- CRITICAL FIX: Simplified Visibility Binding ---
        // Removes race conditions where opacity animations fail to trigger
        visible: AseState.terminalVisible
        opacity: AseState.terminalVisible ? 1.0 : 0.0
        scale: AseState.terminalVisible ? 1.0 : 0.95
        
        Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; overshoot: 1.2 } }
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

    // Mount the Architect Reticle
    ArchitectReticle {
        id: reticle
    }

    // --- NEW: Mount the Omni Launcher ---
    OmniLauncher {
        id: omniCommandPalette
    }
}