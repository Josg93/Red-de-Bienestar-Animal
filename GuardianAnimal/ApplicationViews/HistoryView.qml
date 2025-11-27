import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Controls
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    signal backClicked()

    onVisibleChanged: {
        if (visible) {
            backend.setViewMode("history")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; height: 80; color: Theme.backgroundColor

            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10


                Text {
                    text: "Historial de Casos"; font.bold: true; font.pixelSize: 20; color: Theme.textDark
                    Layout.fillWidth: true
                }
            }
        }

        // THE LIST
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true; spacing: 12
            model: backend

            delegate: Rectangle {
                width: parent.width - 32; height: 100
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                radius: 12; color: "white"; border.color: "#e5e7eb"; border.width: 1

                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 16

                    // Status Icon / Thumbnail
                    Rectangle {
                        width: 60; height: 60; radius: 30; color: "#f3f4f6"; clip: true

                        // If image exists, show it. If not, show icon.
                        Image {
                            visible: model.imageSource !== ""
                            anchors.fill: parent
                            source: model.imageSource
                            fillMode: Image.PreserveAspectCrop
                        }

                        Text {
                            visible: model.imageSource === ""
                            anchors.centerIn: parent; text: "📁"; font.pixelSize: 24
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true
                            // NEW: Show TYPE as Title
                            Text { text: model.type; font.bold: true; font.pixelSize: 16; color: Theme.textDark }

                            Item { Layout.fillWidth: true }

                            Text { text: model.status === "adopted" ? "ADOPTADO" : "RESUELTO"; font.bold: true; font.pixelSize: 10; color: Theme.textGray }
                        }

                        // NEW: Show NAME + Desc
                        Text {
                            text: (model.name === "Desconocido" ? "" : model.name + " • ") + model.description
                            font.pixelSize: 12; color: Theme.textGray
                            elide: Text.ElideRight; Layout.fillWidth: true; maximumLineCount: 2
                        }
                    }

                    // Outcome Badge
                    Rectangle {
                        width: 24; height: 24; radius: 12
                        color: "#dcfce7" // Green tint
                        Text { anchors.centerIn: parent; text: "✓"; font.bold: true; color: "#166534" }
                    }
                }
            }

            // Empty State (Visual Polish)
            Text {
                visible: backend.rowCount() === 0
                anchors.centerIn: parent
                text: "No hay casos en el historial."
                color: Theme.textGray
            }
        }
    }
}
