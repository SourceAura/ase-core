pragma Singleton
import QtQuick

QtObject {
    id: stateRoot
    
    property bool terminalVisible: false
    
    // Tracer: This fires automatically whenever terminalVisible changes
    onTerminalVisibleChanged: {
        console.log("[ASE STATE] terminalVisible broadcasted globally as:", terminalVisible)
    }
}