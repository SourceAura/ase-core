pragma Singleton
import QtQuick
import QtWebSockets // Required for native QML WebSockets

QtObject {
    id: stateRoot
    
    // Existing States
    property bool terminalVisible: false
    property string activeApplet: "none"
    property string hazardLevel: "cyan"
    property bool isNemotronScanning: false
    property bool omniVisible: false
    
    // --- NEW: Live Intelligence Data ---
    property string lastLogMessage: "NEURAL LINK ESTABLISHED"
    property var activeThreats: []

    // --- The WebSocket Pipeline ---
    property WebSocket neuralSocket: WebSocket {
        url: "ws://localhost:8000/ws" // Update to your Python backend WS port
        active: true
        
        onStatusChanged: {
            if (status === WebSocket.Error) {
                console.log("[ASE NETWORK] Error: " + errorString)
                stateRoot.hazardLevel = "amber"
            } else if (status === WebSocket.Open) {
                console.log("[ASE NETWORK] Neural Link Active")
                stateRoot.hazardLevel = "cyan"
            } else if (status === WebSocket.Closed) {
                console.log("[ASE NETWORK] Link Severed")
            }
        }
        
        onTextMessageReceived: (message) => {
            try {
                let payload = JSON.parse(message);
                
                // Route the data to the QML state based on your backend structure
                if (payload.type === "HAZARD_UPDATE") {
                    stateRoot.hazardLevel = payload.level;
                } else if (payload.type === "LOG_EVENT") {
                    stateRoot.lastLogMessage = payload.message;
                } else if (payload.type === "THREAT_DETECTED") {
                    // Flash the reticle and update the array
                    stateRoot.isNemotronScanning = true;
                    stateRoot.activeThreats.push(payload.data);
                }
            } catch (e) {
                console.log("[ASE NETWORK] Payload Parse Error:", e);
            }
        }
    }
    
    // Helper function for QML UI to send commands back to Python
    function sendCommand(directive) {
        if (neuralSocket.status === WebSocket.Open) {
            neuralSocket.sendTextMessage(JSON.stringify({
                type: "DIRECTIVE",
                command: directive
            }));
        }
    }
}