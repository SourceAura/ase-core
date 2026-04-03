import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: terminalRoot
    width: 800
    height: 500
    
    // These will be fed by the Reticle tracking
    property real targetNormX: 0
    property real targetNormY: 0
    
    // The Glass Shell
    Rectangle {
        id: glassBackground
        anchors.fill: parent
        color: Qt.rgba(0.04, 0.05, 0.08, 0.7) // Dark ethereal base
        border.color: Qt.rgba(0.0, 1.0, 0.66, 0.3) // #00ffaa
        border.width: 1
        radius: 8
        
        // Internal glow
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0.0, 1.0, 0.66, 0.2)
            shadowBlur: 20
        }

        // Terminal Header
        Rectangle {
            id: header
            width: parent.width
            height: 30
            color: Qt.rgba(0.0, 1.0, 0.66, 0.1)
            radius: 8
            
            // Square off bottom corners so only top is rounded
            Rectangle {
                width: parent.width
                height: 4
                anchors.bottom: parent.bottom
                color: "transparent"
            }
            
            Text {
                anchors.left: parent.left
                anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                text: "ABYSSAL SHELL // 01"
                color: Qt.rgba(0.0, 1.0, 0.66, 0.8)
                font.family: "monospace"
                font.pixelSize: 12
                font.bold: true
            }
        }

        // Output Area (Mocked for now)
        ScrollView {
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
            
            TextArea {
                text: "> INITIALIZING KAGAYA OS...\n> NEURAL LINK: STABLE\n> AWAITING DIRECTIVE..."
                color: Qt.rgba(1.0, 1.0, 1.0, 0.7)
                font.family: "monospace"
                font.pixelSize: 13
                readOnly: true
                background: null // transparent
            }
        }
    }

    // Phase 2, Step 5: Liquid Parallax Physics
    transform: [
        Rotation {
            origin.x: terminalRoot.width / 2
            origin.y: terminalRoot.height / 2
            axis { x: 1; y: 0; z: 0 } // Tilt Up/Down
            // Negative Y so looking up tilts the top away
            angle: -terminalRoot.targetNormY * 8 
            
            Behavior on angle {
                SpringAnimation { spring: 2.0; damping: 0.3 }
            }
        },
        Rotation {
            origin.x: terminalRoot.width / 2
            origin.y: terminalRoot.height / 2
            axis { x: 0; y: 1; z: 0 } // Tilt Left/Right
            angle: terminalRoot.targetNormX * 8
            
            Behavior on angle {
                SpringAnimation { spring: 2.0; damping: 0.3 }
            }
        }
    ]
}