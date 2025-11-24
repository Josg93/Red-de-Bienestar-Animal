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
    signal startRescue(string caseId, string dest)

    // State for filter
    property int searchRadius: 10 // Default 10km

    // ... inside RescueListView ...

        // Add this signal to the top of RescueListView
        signal openReportForm()

        // Add this FAB at the bottom
        Button {
            width: 56; height: 56
            anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.margins: 20
            z: 50
            background: Rectangle { radius: 28; color: "#dc2626" } // Red for emergency
            contentItem: Text { text: "📢"; font.pixelSize: 24; anchors.centerIn: parent; anchors.verticalCenterOffset: -2 }

            onClicked: root.openReportForm()
        }

    // -- MOCK DATA (Sorted by Priority High->Low) --
    ListModel {
        id: rescueModel
        ListElement {
            caseId: "901"; title: "Perro Atropellado"; location: "Av. Las Américas";
            distanceVal: 1.2; priority: "HIGH"; description: "Herido grave, no se mueve.";
            imageSource: ""
        }
        ListElement {
            caseId: "902"; title: "Caja con Cachorros"; location: "Parque Los Poetas";
            distanceVal: 3.5; priority: "MEDIUM"; description: "Abandonados bajo la lluvia.";
            imageSource: ""
        }
        ListElement {
            caseId: "903"; title: "Caballo en Vía"; location: "La Hechicera";
            distanceVal: 8.0; priority: "LOW"; description: "Riesgo de atropello.";
            imageSource: ""
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; height: 110; color: Theme.backgroundColor; z: 10
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10

                // Title
                RowLayout {
                    Text { text: "🚑"; font.pixelSize: 24 }
                    ColumnLayout {
                        spacing: 0
                        Text { text: "Casos de Emergencia"; font.pixelSize: 20; font.bold: true; color: Theme.textDark }
                        //Text { text: "Cola de Prioridad (Max-Heap)"; font.pixelSize: 10; font.bold: true; color: Theme.textGray }
                    }
                }

                // RADIUS FILTER
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Text { text: "Radio:"; font.bold: true; font.pixelSize: 12; color: Theme.textGray }

                    // Simple Chip Repeater
                    Repeater {
                        model: [5, 10, 25]
                        Rectangle {
                            width: 50; height: 28; radius: 14
                            color: root.searchRadius === modelData ? Theme.brandPink : "#e5e7eb"
                            Text { anchors.centerIn: parent; text: modelData + "km"; font.bold: true; font.pixelSize: 11; color: root.searchRadius === modelData ? "white" : Theme.textGray }
                            MouseArea { anchors.fill: parent; onClicked: root.searchRadius = modelData }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }
                }
            }
        }

        // LIST VIEW
        ListView {
            id: listView
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 15
            model: rescueModel

            delegate: Rectangle {
                // Hide if outside radius
                visible: model.distanceVal <= root.searchRadius
                height: visible ? 150 : 0; opacity: visible ? 1.0 : 0.0
                Behavior on height { NumberAnimation { duration: 200 } }

                width: listView.width - 32
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 12; color: Theme.bgWhite; border.color: "#e5e7eb"; border.width: 1

                // Priority Color Logic
                property color priorityColor: model.priority === "HIGH" ? "#ef4444" : (model.priority === "MEDIUM" ? "#f97316" : "#22c55e")
                property color priorityBg: model.priority === "HIGH" ? "#fef2f2" : (model.priority === "MEDIUM" ? "#fff7ed" : "#ecfdf5")

                // Left Border
                Rectangle { width: 6; height: parent.height; anchors.left: parent.left; radius: 3; color: priorityColor }

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 14; anchors.leftMargin: 20; spacing: 6

                    // Header Row (Badge + ID)
                    RowLayout {
                        Layout.fillWidth: true
                        Rectangle {
                            width: badgeTxt.width + 12; height: 20; radius: 4; color: priorityBg
                            Text { id: badgeTxt; anchors.centerIn: parent; text: model.priority === "HIGH" ? "CRÍTICO" : (model.priority === "MEDIUM" ? "URGENTE" : "ALERTA"); font.bold: true; font.pixelSize: 9; color: priorityColor }
                        }
                        Item { Layout.fillWidth: true }
                        Text { text: "#" + model.caseId; font.bold: true; font.pixelSize: 11; color: "#9ca3af" }
                    }

                    Text { text: model.title; font.bold: true; font.pixelSize: 18; color: Theme.textDark }
                    Text { text: model.description; font.pixelSize: 12; color: Theme.textGray; elide: Text.ElideRight; Layout.fillWidth: true }

                    Text { text: "📍 " + model.location + " (" + model.distanceVal + " km)"; font.bold: true; font.pixelSize: 11; color: "#4f46e5" }

                    Item { Layout.fillHeight: true }

                    Button {
                        Layout.fillWidth: true; Layout.preferredHeight: 40
                        background: Rectangle { radius: 8; color: "#1f2937" }
                        contentItem: RowLayout {
                            anchors.centerIn: parent; spacing: 6
                            //Text { text: "🚀"; font.pixelSize: 14 }
                            Text { text: "Aceptar Caso"; color: "white"; font.bold: true; font.pixelSize: 14 }
                        }
                        onClicked: root.startRescue(model.caseId, model.location)
                    }
                }
            }
        }
    }
}
