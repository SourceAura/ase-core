/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * AUTHOR: SourceAura (Architect)
 * COMPONENT: Central Nervous System (Singleton)
 * LORE: The 'Kagaya' core acts as the orchestrator for the Hashira applets.
 * It maintains the global threat resonance (Hazard Level) and manages
 * the telepathic links (WebSockets) to the Python backend.
 * ===================================================================== */

pragma Singleton
import QtQuick

QtObject {
    id: root
    
    // UI Visibility States
    property bool omniVisible: false
    property bool hudActive: true
    
    // Intelligence States
    property string activeApplet: "none"
    property string hazardLevel: "cyan" // "cyan" (Safe), "amber" (Forge), "rose" (Strike)
    property bool isNemotronScanning: false
    
    // System Metrics
    property string kasugaiMessage: "AWAITING DIRECTIVE"
    property real cpuLoad: 12.4
    property real memLoad: 34.2
    
    // Dynamic Thematic Resonance
    property color themeGlow: hazardLevel === "rose" ? "#f43f5e" :
                              hazardLevel === "amber" ? "#fbbf24" : "#00ffaa"
}