import QtQuick
import QtQuick.Layouts
import qs.Widgets
import "." // Imports our local AseState singleton

Rectangle {
    id: root
    
    property var shellScreen
    property string widgetId: ""
    property string section: ""
    
    implicitWidth: rowLayout.implicitWidth + 40
    implicitHeight: 34
    
    color: Qt.rgba(0.04, 0.05, 0.08, 0.8)
    border.color: Qt.rgba(0.0, 1.0, 0.66, 0.2)
    border.width: 1
    radius: 4
    
    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 20
        
        // System Status (Ase // Kagaya)
        RowLayout {
            spacing: 8
            Rectangle {
                width: 6; height: 6; radius: 3
                color: "#00ffaa"
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    NumberAnimation { to: 0.4; duration: 1500 }
                    NumberAnimation { to: 1.0; duration: 1500 }
                }
            }
            NText {
                text: "ASE // KAGAYA"
                color: Qt.rgba(1.0, 1.0, 1.0, 0.8)
                font.family: "monospace"
                font.bold: true
                font.pointSize: 9
            }
        }
        
        // Applet Slots
        RowLayout {
            spacing: 15
            
            // SYS Slot (Abyssal Terminal Trigger)
            Rectangle {
                Layout.preferredWidth: sysText.implicitWidth + 10
                Layout.preferredHeight: sysText.implicitHeight + 10
                color: "transparent" // Forces layout geometry
                
                NText {
                    id: sysText
                    anchors.centerIn: parent
                    text: "SYS"
                    color: AseState.terminalVisible ? "#00ffaa" : Qt.rgba(0.0, 1.0, 0.66, 0.5)
                    font.family: "monospace"
                    font.pointSize: 9
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#00ffaa"
                    visible: AseState.terminalVisible
                }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onEntered: sysText.color = "#00ffaa"
                    onExited: sysText.color = AseState.terminalVisible ? "#00ffaa" : Qt.rgba(0.0, 1.0, 0.66, 0.5)
                    
                    onClicked: {
                        console.log("[ASE CORE] SYS Button Clicked!");
                        console.log("[ASE CORE] Previous State:", AseState.terminalVisible);
                        AseState.terminalVisible = !AseState.terminalVisible;
                        console.log("[ASE CORE] New State:", AseState.terminalVisible);
                    }
                }
            }

            // NET & DB Placeholders (Will be wired later)
            NText {
                text: "NET"
                color: Qt.rgba(0.0, 1.0, 0.66, 0.5)
                font.family: "monospace"; font.pointSize: 9
            }
            NText {
                text: "DB"
                color: Qt.rgba(0.0, 1.0, 0.66, 0.5)
                font.family: "monospace"; font.pointSize: 9
            }
        }
    }
}