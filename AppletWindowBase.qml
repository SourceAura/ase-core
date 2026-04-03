import QtQuick
import QtQuick.Window
import QtQuick.Effects
import "."

Window {
    id: appletRoot
    
    // Default starting size (niri will take over and tile it into a column)
    width: 800
    height: 600
    
    // We do NOT use FramelessWindowHint or StaysOnTopHint here. 
    // We let niri manage the borders, tiling, and focus natively.
    visible: false 
    color: "#05070a" // Deep background
    
    // Thematic Border matching AseState
    property color glowColor: AseState.hazardLevel === "rose" ? "#f43f5e" :
                              AseState.hazardLevel === "amber" ? "#fbbf24" : "#00ffaa"
                              
    // Inner styling container
    Rectangle {
        anchors.fill: parent
        anchors.margins: 2 // Gives breathing room inside the niri tile
        color: Qt.rgba(0.04, 0.05, 0.08, 0.9)
        border.color: Qt.rgba(appletRoot.glowColor.r, appletRoot.glowColor.g, appletRoot.glowColor.b, 0.3)
        border.width: 1
        radius: 8
        
        // Header Strip
        Rectangle {
            id: appletHeader
            width: parent.width; height: 30
            color: Qt.rgba(appletRoot.glowColor.r, appletRoot.glowColor.g, appletRoot.glowColor.b, 0.1)
            
            Text {
                anchors.left: parent.left; anchors.leftMargin: 15
                anchors.verticalCenter: parent.verticalCenter
                text: appletRoot.title
                color: Qt.rgba(1.0, 1.0, 1.0, 0.8)
                font.family: "monospace"
                font.pixelSize: 12
                font.bold: true
            }
        }
        
        // Content Area (Where Nezuko or Obanai will live)
        Item {
            id: contentContainer
            anchors.top: appletHeader.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 15
        }
    }
    
    // Expose the content container so child applets can inject their UI
    default property alias appletContent: contentContainer.data
}