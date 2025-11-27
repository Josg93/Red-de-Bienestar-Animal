import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Popup {
    id: root

    signal historyClicked()
    signal logoutRequested()
    signal roleToggled(bool isShelter)

    property bool isShelterMode: false
    property string userName: UserSession.userId

    // Position: Top Right
    parent: Overlay.overlay
    x: parent.width - width - 16
    y: 70
    width: 260
    height: contentCol.implicitHeight + 32

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Theme.bgWhite; radius: 12
        border.color: Theme.separatorColor
        border.width: 1
        layer.enabled: true
    }

    ColumnLayout {
        id: contentCol
        anchors.fill: parent; anchors.margins: 16; spacing: 16

        // 1. USER INFO
        RowLayout {
            spacing: 12
            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: "#f3f4f6"
                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qt/qml/GuardianAnimal/icons/profileIcon.svg"
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    text: root.userName
                    font.bold: true
                    font.pixelSize: 16
                    color: Theme.textDark
                }
                Text {
                    text: root.isShelterMode ? "Administrador" : "Ciudadano"
                    font.pixelSize: 12
                    color: root.isShelterMode ? Theme.brandPink : Theme.textGray
                    font.bold: root.isShelterMode
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.separatorColor }

        // 2. ROLE SWITCHER
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            ColumnLayout {
                spacing: 2
                Text { text: "Modo Refugio"; font.bold: true; color: Theme.textDark }
                Text { text: "Gestionar casos"; font.pixelSize: 10; color: Theme.textGray }
            }

            Item { Layout.fillWidth: true }

            Switch {
                checked: root.isShelterMode
                onCheckedChanged: {
                    if (checked !== root.isShelterMode) root.roleToggled(checked)
                }

                indicator: Rectangle {
                    implicitWidth: 40
                    implicitHeight: 20
                    radius: 10
                    color: parent.checked ? Theme.brandPink : "#e5e7eb"

                    Rectangle {
                        x: parent.checked ? 20 : 0
                        width: 20
                        height: 20
                        radius: 10
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 200 } } }
                }
            }
        }

        // 3. MENU ACTIONS
        ColumnLayout {
            spacing: 5; Layout.fillWidth: true

            // --- THE HISTORY BUTTON ---
            Button {
                Layout.fillWidth: true; background: null
                contentItem: RowLayout {
                    Text { text: "📋"; font.pixelSize: 14 }
                    Text { text: "Historial Global"; color: Theme.textDark }
                }
                onClicked: {
                    root.historyClicked() // Emit Signal
                    root.close()
                }
            }
        }
    }
}
