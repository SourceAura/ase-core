import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Item {
    id: root
    
    // Noctalia API Ports
    property var screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: 0
    property int sectionWidgetsCount: 0
    property var pluginApi

    implicitWidth: 30
    implicitHeight: 30

    // States: "checking", "alive", "dead"
    property string daemonState: "checking"
    
    property color themeGlow: daemonState === "alive" ? "#00ffaa" : 
                              daemonState === "dead"  ? "#f43f5e" : "#fbbf24"

    // The Neural Ping (Checks every 3 seconds)
    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var req = new XMLHttpRequest();
            req.onreadystatechange = function() {
                if (req.readyState === XMLHttpRequest.DONE) {
                    if (req.status === 200) {
                        daemonState = "alive";
                    } else {
                        daemonState = "dead";
                    }
                }
            }
            // Pings your FastAPI health router
            req.open("GET", "http://127.0.0.1:8000/api/v1/health", true);
            req.onerror = function() { daemonState = "dead"; }
            req.send();
        }
    }

    // The Visual Node
    Rectangle {
        width: 10
        height: 10
        radius: 5
        anchors.centerIn: parent
        color: themeGlow
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: themeGlow
            shadowBlur: 12
        }

        // Breathing Animation
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.4; duration: 1500; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 1500; easing.type: Easing.InOutSine }
        }
        
        // Tooltip showing exact state
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
        }
    }
}