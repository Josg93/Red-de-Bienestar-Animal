import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor
    signal backClicked()

    onVisibleChanged: { if (visible) backend.setViewMode("happy_tails") }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true; height: 80; color: Theme.backgroundColor
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10
                ToolButton { text: "←"; font.bold: true; font.pixelSize: 24; background: null; onClicked: root.backClicked() }
                Text { text: "Finales Felices 🎉"; font.bold: true; font.pixelSize: 20; color: Theme.textDark; Layout.fillWidth: true }
            }
        }

        // List
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 12
            model: backend

            delegate: Rectangle {
                width: ListView.view ? ListView.view.width - 32 : 300
                height: 100
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

                radius: 12; color: "white"; border.color: "#e5e7eb"

                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 16

                    // Image
                    Rectangle {
                        width: 60; height: 60; radius: 30; color: "#f3f4f6"; clip: true
                        PetImageGallery {
                            anchors.fill: parent
                            imageList: model.images
                        }
                    }

                    // Text Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: model.name; font.bold: true; font.pixelSize: 16; color: Theme.textDark }
                        Text {
                            text: "Adoptado • " + model.type
                            font.pixelSize: 12; color: Theme.textGray
                        }
                    }

                    // Badge
                    Rectangle {
                        width: 24; height: 24; radius: 12; color: "#dcfce7"
                        Text { anchors.centerIn: parent; text: "✓"; font.bold: true; font.pixelSize: 14; color: "#166534" }
                    }
                }
            }

            // Empty State
            Text {
                visible: backend.rowCount() === 0
                anchors.centerIn: parent
                text: "No hay adopciones completadas aún 🐾"
                color: Theme.textGray
                font.pixelSize: 14
            }
        }
    }
}

