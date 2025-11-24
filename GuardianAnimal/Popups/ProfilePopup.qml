import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import GuardianAnimal

Popup {
    id: root

    // Signals to talk to the main app
    signal logoutRequested()
    signal roleToggled(bool isShelter)

    // State passed in
    property bool isShelterMode: false
    property string userName: "Juan Pérez"

    // Position: Top Right, below the header
    parent: Overlay.overlay
    x: parent.width - width - 16
    y: 70 // Adjust based on header height
    width: 260
    height: contentCol.implicitHeight + 32

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Enter Animation (Fade + Scale)
    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
            NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200 }
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }

    background: Rectangle {
        color: Theme.bgWhite
        radius: 12
        border.color: Theme.separatorColor
        border.width: 1

        // Shadow
        layer.enabled: true
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // 1. USER INFO HEADER
        RowLayout {
            spacing: 12

            // Avatar
            Rectangle {
                width: 48; height: 48; radius: 24
                color: "#f3f4f6"
                Text { anchors.centerIn: parent; text: "👤"; font.pixelSize: 24 }
            }

            // Name & Role
            ColumnLayout {
                spacing: 2
                Text {
                    text: root.userName
                    font.bold: true; font.pixelSize: 16; color: Theme.textDark
                }
                Text {
                    text: root.isShelterMode ? "Administrador (Refugio)" : "Ciudadano"
                    font.pixelSize: 12
                    color: root.isShelterMode ? Theme.brandPink : Theme.textGray
                    font.bold: root.isShelterMode
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.separatorColor }

        // 2. ROLE SWITCHER (Simulation)
        // This replaces the small toggle inside AdoptionView
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ColumnLayout {
                spacing: 2
                Text { text: "Modo Refugio"; font.bold: true; color: Theme.textDark }
                Text { text: "Gestionar casos y adopciones"; font.pixelSize: 10; color: Theme.textGray }
            }

            Item { Layout.fillWidth: true }

            Switch {
                checked: root.isShelterMode
                onCheckedChanged: {
                    // Only emit if changed by user interaction (avoid loops)
                    if (checked !== root.isShelterMode) root.roleToggled(checked)
                }
                // Simple styling for the switch
                indicator: Rectangle {
                    implicitWidth: 40; implicitHeight: 20; radius: 10
                    color: parent.checked ? Theme.brandPink : "#e5e7eb"
                    border.color: parent.checked ? Theme.brandPink : "#cccccc"
                    Rectangle {
                        x: parent.checked ? 20 : 0
                        width: 20; height: 20; radius: 10; color: "white"
                        border.color: "#cccccc"
                        Behavior on x { NumberAnimation { duration: 200 } }
                    }
                }
            }
        }

        // 3. MENU ACTIONS
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            Button {
                Layout.fillWidth: true; background: null
                contentItem: RowLayout {
                    Text { text: "📋"; font.pixelSize: 14 }
                    Text { text: "Mis Reportes"; color: Theme.textDark }
                    Item { Layout.fillWidth: true }
                    Text { text: "3"; color: Theme.textGray; font.bold: true }
                }
            }

            Button {
                Layout.fillWidth: true; background: null
                contentItem: RowLayout {
                    Text { text: "⚙️"; font.pixelSize: 14 }
                    Text { text: "Configuración"; color: Theme.textDark }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.separatorColor }

        // 4. SIGN OUT
        Button {
            Layout.fillWidth: true
            background: Rectangle { color: parent.pressed ? "#fee2e2" : "transparent"; radius: 8 }
            contentItem: Text {
                text: "Cerrar Sesión"
                color: "#dc2626" // Red
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }
            onClicked: root.logoutRequested()
        }
    }
}
