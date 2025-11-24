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

    // Data passed into this view
    property var petData: ({})

    signal backClicked()
    signal contactClicked()

    // Helper for images
    property var imageList: {
        if (petData.imagesJson) {
            try { return JSON.parse(petData.imagesJson) } catch(e) { return [] }
        }
        if (petData.imageSource) return [petData.imageSource]
        return []
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. SCROLLABLE CONTENT
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentCol.height + 100 // Extra space for footer
            clip: true

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 0

                // --- IMAGE HEADER ---
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 300

                    PetImageGallery {
                        anchors.fill: parent
                        imageList: root.imageList
                        fallbackColors: [petData.color1 || "#ccc"]
                    }

                    // Back Button (Overlay)
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "white"
                        anchors.top: parent.top; anchors.left: parent.left
                        anchors.margins: 20
                        Text { anchors.centerIn: parent; text: "←"; font.bold: true; font.pixelSize: 24 }
                        MouseArea { anchors.fill: parent; onClicked: root.backClicked() }
                    }
                }

                // --- DETAILS CARD ---
                Rectangle {
                    Layout.fillWidth: true
                    // Negative top margin to pull it up over the image
                    Layout.topMargin: -30
                    implicitHeight: detailsInner.implicitHeight + 40

                    color: Theme.bgWhite
                    radius: 24

                    // Only round top corners logic (simulated by filling bottom)
                    Rectangle {
                        height: 30; width: parent.width
                        color: Theme.bgWhite
                        anchors.bottom: parent.bottom
                    }

                    ColumnLayout {
                        id: detailsInner
                        anchors.fill: parent
                        anchors.margins: 24
                        spacing: 16

                        // Header Row
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: petData.name || "Sin Nombre"
                                font.bold: true; font.pixelSize: 28; color: Theme.textDark
                                Layout.fillWidth: true
                            }
                            Rectangle {
                                width: 80; height: 28; radius: 14
                                color: "#dcfce7"
                                Text {
                                    anchors.centerIn: parent
                                    text: "DISPONIBLE"
                                    font.bold: true; font.pixelSize: 10; color: "#15803d"
                                }
                            }
                        }

                        // Location
                        RowLayout {
                            spacing: 6
                            Text { text: "📍"; font.pixelSize: 14 }
                            Text {
                                text: (petData.location || "Ubicación desconocida") + " (" + (petData.distance || "?") + ")"
                                color: Theme.textGray; font.pixelSize: 14
                            }
                        }

                        // Chips Row (Sex, Age, Weight)
                        RowLayout {
                            spacing: 10
                            Layout.fillWidth: true

                            component InfoChip: Rectangle {
                                implicitWidth: chipTxt.implicitWidth + 20; height: 36; radius: 10
                                color: "#f3f4f6"
                                property alias text: chipTxt.text
                                Text { id: chipTxt; anchors.centerIn: parent; font.bold: true; color: Theme.textDark; font.pixelSize: 12 }
                            }

                            InfoChip { text: petData.sex || "Sexo?" }
                            InfoChip { text: petData.age || "Edad?" }
                            InfoChip { text: petData.type || "Tipo?" }
                        }

                        // Description
                        Text {
                            text: "Historia"
                            font.bold: true; font.pixelSize: 18; color: Theme.textDark
                            Layout.topMargin: 10
                        }
                        Text {
                            text: petData.description || "No hay descripción disponible para esta mascota. Contacta al refugio para más información."
                            color: Theme.textGray
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                            lineHeight: 1.4
                        }

                        // Owner / Shelter Info
                        Rectangle {
                            Layout.fillWidth: true; height: 80
                            color: "#fff7ed" // Orange tint
                            radius: 12
                            border.color: "#fdba74"

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 12
                                spacing: 12

                                Rectangle {
                                    width: 48; height: 48; radius: 24; color: "white"
                                    Text { anchors.centerIn: parent; text: "🛖"; font.pixelSize: 24 }
                                }

                                ColumnLayout {
                                    spacing: 2
                                    Text { text: "Publicado por"; font.pixelSize: 10; color: "#9a3412" }
                                    Text { text: "Refugio Central"; font.bold: true; font.pixelSize: 16; color: "#9a3412" }
                                }
                            }
                        }
                    }
                }
            }
        }

        // 2. STICKY FOOTER
        Rectangle {
            Layout.fillWidth: true; height: 80
            color: "white"
            // Top Shadow line
            Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.top: parent.top }

            RowLayout {
                anchors.fill: parent; anchors.margins: 16
                spacing: 16

                // Favorite Button
                Button {
                    Layout.preferredWidth: 50; Layout.fillHeight: true
                    background: Rectangle { radius: 12; border.color: "#e5e7eb"; border.width: 2; color: "white" }
                    contentItem: Text { text: "❤️"; font.pixelSize: 20; anchors.centerIn: parent }
                }

                // Main Action
                Button {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    background: Rectangle { radius: 16; color: Theme.brandPink }
                    contentItem: Text {
                        text: "Adoptar / Contactar"
                        color: "white"; font.bold: true; font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.contactClicked()
                }
            }
        }
    }
}
