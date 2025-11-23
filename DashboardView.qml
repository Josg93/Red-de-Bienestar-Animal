import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Flickable {
    id: root
    contentHeight: contentColumn.height + 40
    clip: true

    // Signal to tell ApplicationScreen to switch tabs
    // 1 = Adoptions, 2 = Rescue Cases, 3 = Lost & Found
    signal requestView(int index)

    ColumnLayout {
        id: contentColumn
        width: parent.width
        spacing: 24
        anchors.top: parent.top
        anchors.margins: 16

        Item { width: 1; height: 10 }

        // 1. FINISH CUSTOM DIALOG
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            height: textId.implicitHeight + 30
            Layout.leftMargin: 16; Layout.rightMargin: 16
            color: Theme.textDark
            radius: 16

            // Decorative gradient overlay
            Rectangle {
                anchors.fill: parent
                radius: 16
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#30000000" }
                }
            }

            ColumnLayout {
                id: textId
                anchors.fill: parent
                anchors.margins: 20
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Patitas Suaves 🐾"
                        font.bold: true
                        font.pixelSize: 25
                        color: "white"
                    }
                    Item { Layout.fillWidth: true }

                    /*
                    Rectangle {
                        width: 60; height: 22; radius: 4
                        color: "#22c55e" // Green "ONLINE" badge
                        Text { anchors.centerIn: parent; text: "ONLINE"; font.bold: true; font.pixelSize: 10; color: "white" }
                    }*/
                }

                Text {
                    text: "Gestionando el bienestar animal de tu comunidad en tiempo real."
                    color: "#d1d5db"
                    font.pixelSize: 16
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                }

                Text {

                    text: "✓ Coordinación en tiempo real\n✓ Rutas optimizadas\n✓ Gestión de casos"
                    color: "white"
                    font.pixelSize: 14
                    lineHeight: 1.5

                }

                Item { Layout.fillHeight: true } // Spacer
            }
        }

        Item { Layout.fillHeight: true } // Spacer

        // 2. "Acciones Rápidas" Section Title
        Text {
            text: "ACCIONES RÁPIDAS"
            font.bold: true
            font.pixelSize: 20
            color: Theme.textGray
            Layout.leftMargin: 16
            font.letterSpacing: 0.5
        }

        // 3. GRID OF CARDS from the prototype i did before
        GridLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            Repeater {
                model: [
                    // NEED TO FIX INDEXES
                    {"name": "Emergencias", "icon": "icons/notificationIcon.svg", "bgColor": "#fee2e2", "iconColor": "#dc2626", "targetIndex": 2},
                    {"name": "Adopciones",  "icon": "icons/homeIcon.svg",         "bgColor": "#fce7f3", "iconColor": "#db2777", "targetIndex": 1},
                    {"name": "Perdidos",    "icon": "icons/lostIcon.svg",         "bgColor": "#e0e7ff", "iconColor": "#4f46e5", "targetIndex": 3},
                    {"name": "Reportar",    "icon": "icons/reportIcon.svg",       "bgColor": "#dcfce7", "iconColor": "#16a34a", "targetIndex": 2}
                ]

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: Theme.bgWhite
                    radius: 16
                    border.color: mouseArea.pressed ? Theme.brandPink : "#f3f4f6"
                    border.width: 2
                    layer.enabled: true

                    // Helper for icon path I NEED TO DELETE THIS AFTER ALL ICONS ARE IMPORTED
                    property bool isImagePath: modelData.icon.toString().indexOf("/") >= 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        // Colored Circle Background
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 48
                            height: 48
                            radius: 24
                            color: modelData.bgColor

                            // The Icon
                            ToolButton {
                                anchors.centerIn: parent
                                visible: parent.parent.parent.isImagePath
                                display: AbstractButton.IconOnly
                                background: null
                                enabled: false // Pass clicks to main MouseArea

                                icon.source: visible ? modelData.icon : ""
                                icon.color: modelData.iconColor
                                icon.width: 24
                                icon.height: 24
                            }
                        }

                        // Text Label
                        Text {
                            text: modelData.name
                            font.bold: true
                            font.pixelSize: 13
                            color: Theme.textDark
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Animation on press
                    ScaleAnimator {
                        target: parent; from: 1.0; to: 0.95; running: mouseArea.pressed; duration: 100
                    }
                    ScaleAnimator {
                        target: parent; from: 0.95; to: 1.0; running: !mouseArea.pressed; duration: 100
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        onClicked: {
                            console.log("Navigating to index: " + modelData.targetIndex)
                            root.requestView(modelData.targetIndex)
                        }
                    }
                }
            }
        }
    }
}
