import QtQuick

Item {
    id: reticleRoot
    anchors.fill: parent
    z: 9999

    property real mouseX: width / 2
    property real mouseY: height / 2

    // Kinetic Pulses (Replaces React state array)
    ListModel { id: pulseModel }

    function firePulse(px, py, isRightClick) {
        pulseModel.append({ "px": px, "py": py, "isRightClick": isRightClick })
        pulseCleanup.start()
    }

    Timer {
        id: pulseCleanup
        interval: 600
        onTriggered: { if (pulseModel.count > 0) pulseModel.remove(0, 1) }
    }

    // 1. The Outer Ghost Ring (Lags behind via loose spring)
    Item {
        width: 60; height: 60
        x: reticleRoot.mouseX - width / 2
        y: reticleRoot.mouseY - height / 2

        Behavior on x { SpringAnimation { spring: 150; damping: 15; mass: 1.0 } }
        Behavior on y { SpringAnimation { spring: 150; damping: 15; mass: 1.0 } }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: AseState.hazardLevel === "rose" ? Qt.rgba(0.95, 0.25, 0.36, 0.2) : Qt.rgba(0.0, 1.0, 0.66, 0.2)
            border.width: 1
            opacity: 0.5
            
            RotationAnimation on rotation {
                loops: Animation.Infinite
                from: 0; to: 360; duration: 10000
            }
        }
    }

    // 2. The Inner Core (Fast, snappy tracking)
    Item {
        width: 30; height: 30
        x: reticleRoot.mouseX - width / 2
        y: reticleRoot.mouseY - height / 2

        Behavior on x { SpringAnimation { spring: 400; damping: 25; mass: 0.1 } }
        Behavior on y { SpringAnimation { spring: 400; damping: 25; mass: 0.1 } }

        // The Scanner State
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            // Glows pink/rose when scanning, cyan when normal
            border.color: AseState.isNemotronScanning ? "#f43f5e" : "#00ffaa"
            border.width: 1.5

            RotationAnimation on rotation {
                loops: Animation.Infinite
                from: 360; to: 0; duration: AseState.isNemotronScanning ? 2000 : 8000
            }
        }

        // Center Focus Dot
        Rectangle {
            anchors.centerIn: parent
            width: 4; height: 4
            radius: 2
            color: AseState.isNemotronScanning ? "#f43f5e" : "#00ffaa"
        }
    }

    // 3. The Kinetic Click Ripples
    Repeater {
        model: pulseModel
        delegate: Rectangle {
            x: model.px - width/2
            y: model.py - height/2
            width: 0; height: 0; radius: width/2
            color: "transparent"
            border.color: model.isRightClick ? "#f43f5e" : "#00ffaa"
            border.width: 2
            
            NumberAnimation on width { to: 100; duration: 500; easing.type: Easing.OutQuad }
            NumberAnimation on height { to: 100; duration: 500; easing.type: Easing.OutQuad }
            NumberAnimation on opacity { to: 0; duration: 500; easing.type: Easing.OutQuad }
        }
    }
}