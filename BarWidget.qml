import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "." 

Rectangle {
    id: root
    
    // Expanding to fit the web dashboard scale
    implicitWidth: Math.min(1000, Screen.width * 0.9)
    implicitHeight: 40
    
    // Thematic Resonance Mapping
    property color glowColor: AseState.hazardLevel === "rose" ? "#f43f5e" :
                              AseState.hazardLevel === "amber" ? "#fbbf24" : "#00ffaa"
    
    color: Qt.rgba(0.04, 0.05, 0.08, 0.8)
    border.color: Qt.rgba(glowColor.r, glowColor.g, glowColor.b, 0.3)
    border.width: 1
    radius: 8

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 20

        // 1. Status Indicator & Branding
        RowLayout {
            spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: root.glowColor
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.3; duration: 1500 }
                    NumberAnimation { to: 1.0; duration: 1500 }
                }
            }
            Text {
                text: "ASE // KAGAYA"
                color: Qt.rgba(1.0, 1.0, 1.0, 0.8)
                font.family: "monospace"
                font.bold: true
                font.pixelSize: 12
            }
        }
        
        // 2. Web Applet Dock
        RowLayout {
            spacing: 15
            Repeater {
                model: ["Grimoire", "Dojo", "Wisteria", "Nezuko", "Obanai"]
                delegate: Rectangle {
                    Layout.preferredWidth: appletText.implicitWidth + 16
                    Layout.preferredHeight: 24
                    color: AseState.activeApplet === modelData ? Qt.rgba(root.glowColor.r, root.glowColor.g, root.glowColor.b, 0.1) : "transparent"
                    radius: 4
                    
                    Text {
                        id: appletText
                        anchors.centerIn: parent
                        text: modelData
                        color: AseState.activeApplet === modelData ? root.glowColor : Qt.rgba(1.0, 1.0, 1.0, 0.5)
                        font.family: "monospace"
                        font.pixelSize: 11
                    }
                    
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: root.glowColor
                        visible: AseState.activeApplet === modelData
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: appletText.color = root.glowColor
                        onExited: appletText.color = AseState.activeApplet === modelData ? root.glowColor : Qt.rgba(1.0, 1.0, 1.0, 0.5)
                        onClicked: {
                            AseState.activeApplet = (AseState.activeApplet === modelData) ? "none" : modelData
                        }
                    }
                }
            }
        }

        Item { Layout.fillWidth: true } // Spacer

        // 3. Macro Sigil Engine Input
        Rectangle {
            Layout.preferredWidth: 250
            Layout.preferredHeight: 24
            color: "transparent"
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.1)
            radius: 4
            
            TextInput {
                id: commandInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                color: root.glowColor
                font.family: "monospace"
                font.pixelSize: 12
                selectionColor: root.glowColor
                selectByMouse: true
                
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: "Enter Sigil ( / )..."
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.2)
                    font.family: "monospace"; font.pixelSize: 12
                    visible: !commandInput.text && !commandInput.activeFocus
                }
                
                // Demo Command Engine Routing
                onAccepted: {
                    console.log("[MACRO ENGINE] Executing:", text)
                    
                    if (text.startsWith("/strike")) AseState.hazardLevel = "rose"
                    else if (text.startsWith("/forge")) AseState.hazardLevel = "amber"
                    else if (text.startsWith("/clear")) {
                        AseState.hazardLevel = "cyan"
                        AseState.isNemotronScanning = false
                    }
                    
                    text = "" // Purge buffer
                }
            }
        }
    }
}