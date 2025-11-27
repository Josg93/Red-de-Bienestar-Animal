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
    // Signal to start navigation
    signal openReportForm()
    property int searchRadius: 10 // Default 10km
    signal startRescue(string caseId, string dest, var coordinate)

    // FAB (Report Emergency)
    FloatingActionButton {
        anchors.bottom: parent.bottom; anchors.right: parent.right
        anchors.margins: 20

        buttonColor: "#dc2626" // Red for Emergency
        iconSource: "qrc:/qt/qml/GuardianAnimal/icons/reportIcon.svg"

        onClicked: root.openReportForm()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; height: 110; color: Theme.backgroundColor; z: 10
            ColumnLayout {

                anchors.fill: parent
                anchors.margins: 16
                spacing: 10
                RowLayout {
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Casos de Emergencia"; font.pixelSize: 20; font.bold: true; color: Theme.textDark }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 10

                    Text { text: "Radio:";font.bold: true; font.pixelSize: 12; color: Theme.textGray }

                    Repeater {
                        model: [2, 5, 10]

                        Rectangle {
                            width: 50
                            height: 28
                            radius: 14
                            color: (root.searchRadius === modelData && backend.filterByRadius) ? Theme.brandPink: "#e5e7eb"
                            Text {
                                anchors.centerIn: parent
                                text: modelData + "km"
                                font.bold: true; font.pixelSize: 11
                                // Update text color logic too for readability
                                color: (root.searchRadius === modelData && backend.filterByRadius)
                                       ? "white"
                                       : Theme.textGray
                            }
                            MouseArea {
                                anchors.fill: parent;
                                onClicked: {
                                    root.searchRadius = modelData
                                    backend.searchRadius = modelData
                                    backend.filterByRadius = true // Activate Radius Mode
                                }
                            }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    Rectangle {
                        width: 50
                        height: 28
                        radius: 14
                        color: !backend.filterByRadius ? Theme.brandPink : "#e5e7eb"

                        Text {
                            anchors.centerIn: parent; text: "Todo"; font.bold: true; font.pixelSize: 11
                            color: !backend.filterByRadius ? "white" : Theme.textGray
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                backend.filterByRadius = false // Deactivate Radius Mode
                            }
                        }
                    }
                }
            }
        }

        // LIST VIEW
        ListView {
            id: listView
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 15

            model: backend // This connects to RescueModel.cpp

            delegate: Rectangle {

                width: listView.width - 32
                anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
                height: 150
                radius: 12; color: Theme.bgWhite; border.color: "#e5e7eb"; border.width: 1

                // Priority Color Logic
                property color priorityColor: model.severity === "HIGH" ? "#ef4444" : (model.severity === "MEDIUM" ? "#f97316" : "#22c55e")
                property color priorityBg: model.severity === "HIGH" ? "#fef2f2" : (model.severity === "MEDIUM" ? "#fff7ed" : "#ecfdf5")

                // Left Border
                Rectangle { width: 6; height: parent.height; anchors.left: parent.left; radius: 3; color: priorityColor }
                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 14; anchors.leftMargin: 20; spacing: 6
                    // Header Row (Badge + ID)
                    RowLayout {
                        Layout.fillWidth: true
                        Rectangle {
                            width: badgeTxt.width + 12; height: 20; radius: 4; color: priorityBg
                            Text { id: badgeTxt; anchors.centerIn: parent; text: model.severity === "HIGH" ? "CRÍTICO" : (model.severity === "MEDIUM" ? "URGENTE" : "ALERTA"); font.bold: true; font.pixelSize: 9; color: priorityColor }
                        }

                        Item { Layout.fillWidth: true }

                        // Use model.id from C++

                        Text { text: "#" + (model.id ? model.id.substring(0,4) : "???"); font.bold: true; font.pixelSize: 11; color: "#9ca3af" }
                    }

                    // Title & Desc
                    Text {
                        text: model.type
                        font.bold: true; font.pixelSize: 18; color: Theme.textDark
                    }

                    // NEW: Show NAME + Description as subtitle
                    Text {
                        text: (model.name === "Desconocido" ? "" : model.name + " • ") + model.description
                        font.pixelSize: 12; color: Theme.textGray;
                        elide: Text.ElideRight; Layout.fillWidth: true
                    }

                    // Location & Distance
                    Text { text: "📍 " + model.location + " (" + model.distance + ")"; font.bold: true; font.pixelSize: 11; color: "#4f46e5" }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.fillWidth: true; Layout.preferredHeight: 40
                        background: Rectangle { radius: 8; color: "#1f2937" }
                        contentItem: RowLayout {
                            anchors.centerIn: parent; spacing: 6
                            Text { text: "Aceptar Caso"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        }
                        onClicked:{
                            root.startRescue(model.id, model.location, model.coordinate)
                        }
                    }
                }
            }
        }
    }
}
