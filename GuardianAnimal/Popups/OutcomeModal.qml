import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import GuardianAnimal

Popup {
    id: root

    // Signals the result back to the Navigation View
    // result: "success", "gone", "duplicate"
    signal outcomeSelected(string result)

    parent: Overlay.overlay
    x: 0
    y: parent.height - height
    width: parent.width
    height: 400 // Bottom sheet style

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // Slide Up Animation
    enter: Transition { NumberAnimation { property: "y"; from: parent.height; to: parent.height - 400; duration: 300; easing.type: Easing.OutCubic } }
    exit: Transition { NumberAnimation { property: "y"; from: parent.height - 400; to: parent.height; duration: 300; easing.type: Easing.InCubic } }

    background: Rectangle {
        color: Theme.bgWhite
        radius: 20
        Rectangle { width: parent.width; height: 20; color: Theme.bgWhite; anchors.bottom: parent.bottom }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 15

        // Handle bar (Visual cue for sliding)
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 40; height: 4; radius: 2; color: "#e5e7eb"
        }

        Text {
            text: "Cerrar Caso"; font.bold: true; font.pixelSize: 20; color: Theme.textDark
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "¿Cuál fue el resultado de la operación?"; font.pixelSize: 14; color: Theme.textGray
            Layout.alignment: Qt.AlignHCenter
        }

        Item { height: 10; Layout.fillWidth: true } // Spacer

        // --- BUTTON 1: SUCCESS ---
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            background: Rectangle { color: "#ecfdf5"; radius: 12; border.color: "#6ee7b7"; border.width: 1 }
            contentItem: RowLayout {
                anchors.centerIn: parent
                spacing: 15
                Rectangle { width: 40; height: 40; radius: 20; color: "#d1fae5"; Text { anchors.centerIn: parent; text: "🐾"; font.pixelSize: 20 } }
                ColumnLayout {
                    spacing: 0
                    Text { text: "Rescate Exitoso"; font.bold: true; font.pixelSize: 16; color: "#065f46" }
                    Text { text: "Animal asegurado o llevado a vet."; font.pixelSize: 12; color: "#047857" }
                }
                Item { Layout.fillWidth: true } // Push content left
            }
            onClicked: root.outcomeSelected("success")
        }

        // --- BUTTON 2: GONE ---
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            background: Rectangle { color: "#fff7ed"; radius: 12; border.color: "#fdba74"; border.width: 1 }
            contentItem: RowLayout {
                anchors.centerIn: parent
                spacing: 15
                Rectangle { width: 40; height: 40; radius: 20; color: "#ffedd5"; Text { anchors.centerIn: parent; text: "💨"; font.pixelSize: 20 } }
                ColumnLayout {
                    spacing: 0
                    Text { text: "Ya no estaba"; font.bold: true; font.pixelSize: 16; color: "#9a3412" }
                    Text { text: "El animal se movió del sitio."; font.pixelSize: 12; color: "#c2410c" }
                }
                Item { Layout.fillWidth: true }
            }
            onClicked: root.outcomeSelected("gone")
        }

        // --- BUTTON 3: FALSE ALARM ---
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            background: Rectangle { color: "#f3f4f6"; radius: 12; border.color: "#d1d5db"; border.width: 1 }
            contentItem: RowLayout {
                anchors.centerIn: parent
                spacing: 15
                Rectangle { width: 40; height: 40; radius: 20; color: "#e5e7eb"; Text { anchors.centerIn: parent; text: "📄"; font.pixelSize: 20 } }
                ColumnLayout {
                    spacing: 0
                    Text { text: "Falsa Alarma / Duplicado"; font.bold: true; font.pixelSize: 16; color: "#374151" }
                    Text { text: "Error en el reporte."; font.pixelSize: 12; color: "#4b5563" }
                }
                Item { Layout.fillWidth: true }
            }
            onClicked: root.outcomeSelected("duplicate")
        }

        Item { Layout.fillHeight: true }

        // CANCEL
        Button {
            Layout.fillWidth: true
            background: null
            contentItem: Text { text: "Cancelar"; color: Theme.textGray; font.bold: true; horizontalAlignment: Text.AlignHCenter }
            onClicked: root.close()
        }
    }
}
