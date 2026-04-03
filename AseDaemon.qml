/* =====================================================================
 * PROJECT: Ase Core // Kagaya OS
 * AUTHOR: SourceAura (Architect)
 * COMPONENT: Background Daemon & HUD Overlay
 * LORE: The omnipresent etheric field. This layer establishes the 
 * cybernetic framing (Corner Brackets) and ensures the OmniLauncher
 * is primed and ready for invocation.
 * ===================================================================== */

import QtQuick
import QtQuick.Window
import "."

Item {
    id: daemonRoot
    
    // 1. Mount the Command Palette into memory
    // OmniLauncher {
    //     id: launcher
    // }

    // 2. The HUD Overlay (Click-through screen aesthetics)
    Window {
        id: hudOverlay
        title: "ase-hud-overlay"
        width: Screen.width
        height: Screen.height
        visible: AseState.hudActive
        color: "transparent"
        
        // Critical Wayland flags for an overlay
        flags: Qt.FramelessWindowHint | Qt.WindowTransparentForInput | Qt.WindowStaysOnBottomHint

        // HUD Corner Brackets (Matches React 'HUDCornerBrackets.tsx')
        Item {
            anchors.fill: parent
            anchors.margins: 20
            
            property int stroke: 2
            property int len: 40
            property color bracketColor: Qt.rgba(AseState.themeGlow.r, AseState.themeGlow.g, AseState.themeGlow.b, 0.3)

            // Top Left
            Rectangle { x: 0; y: 0; width: parent.len; height: parent.stroke; color: parent.bracketColor }
            Rectangle { x: 0; y: 0; width: parent.stroke; height: parent.len; color: parent.bracketColor }
            
            // Top Right
            Rectangle { anchors.right: parent.right; y: 0; width: parent.len; height: parent.stroke; color: parent.bracketColor }
            Rectangle { anchors.right: parent.right; y: 0; width: parent.stroke; height: parent.len; color: parent.bracketColor }
            
            // Bottom Left
            Rectangle { x: 0; anchors.bottom: parent.bottom; width: parent.len; height: parent.stroke; color: parent.bracketColor }
            Rectangle { x: 0; anchors.bottom: parent.bottom; width: parent.stroke; height: parent.len; color: parent.bracketColor }
            
            // Bottom Right
            Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: parent.len; height: parent.stroke; color: parent.bracketColor }
            Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: parent.stroke; height: parent.len; color: parent.bracketColor }
        }

        // Static Center Reticle (Since Wayland blocks global cursor sniffing)
        Item {
            anchors.centerIn: parent
            width: 400; height: 400
            opacity: 0.05
            
            Rectangle {
                anchors.centerIn: parent
                width: 300; height: 300
                radius: 150
                color: "transparent"
                border.color: AseState.themeGlow
                border.width: 1
                
                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0; to: 360; duration: 30000
                }
                
                // Crosshairs
                Rectangle { anchors.centerIn: parent; width: parent.width + 40; height: 1; color: AseState.themeGlow }
                Rectangle { anchors.centerIn: parent; width: 1; height: parent.height + 40; color: AseState.themeGlow }
            }
        }
    }
}