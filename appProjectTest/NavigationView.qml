import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root
    color: Theme.backgroundColor

    // Data passed from the Rescue List
    property string caseId: ""
    property string destination: ""

    signal rescueCompleted()
    signal cancelNavigation()

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // -- TOP INFO CARD --
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "#1f2937" // Dark Slate (Night Mode Map style)

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "NAVEGANDO A"; color: "#9ca3af"; font.bold: true; font.pixelSize: 10 }
                    Item { Layout.fillWidth: true }
                    Rectangle { width: 60; height: 20; radius: 4; color: "#22c55e"; Text { anchors.centerIn: parent; text: "EN RUTA"; font.bold: true; color: "white"; font.pixelSize: 10 } }
                }

                Text {
                    text: root.destination
                    color: "white"; font.bold: true; font.pixelSize: 18
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.topMargin: 10
                    Text { text: "5 min"; color: "#4ade80"; font.bold: true; font.pixelSize: 28 }
                    Text { text: "(1.2 km) • Tráfico ligero"; color: "#d1d5db"; font.pixelSize: 14; Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 4 }
                }
            }
        }

        // -- MAP PLACEHOLDER --
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#e5e7eb"

            // Simulated Map Background pattern
            Image {
                anchors.centerIn: parent
                width: parent.width; height: parent.width // Square aspect
                fillMode: Image.PreserveAspectFit
                source: "icons/locationsIcon.svg" // Placeholder: Use a map image here if you have one
                opacity: 0.1
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                Text { text: "📍"; font.pixelSize: 40; Layout.alignment: Qt.AlignHCenter }
                Text { text: "[ GOOGLE MAPS API ]"; font.bold: true; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }
                Text { text: "Calculando ruta óptima (A*)..."; font.pixelSize: 12; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }
            }
        }

        // -- ACTION BUTTONS --
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "white"

            // Shadow
            Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.top: parent.top }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20
                spacing: 10

                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 50
                    background: Rectangle { radius: 12; color: "#16a34a" } // Green
                    contentItem: RowLayout {
                        anchors.centerIn: parent; spacing: 8
                        Text { text: "✅"; font.pixelSize: 18 }
                        Text { text: "Llegué / Finalizar Rescate"; color: "white"; font.bold: true; font.pixelSize: 16 }
                    }
                    onClicked: root.rescueCompleted()
                }

                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { radius: 12; color: "transparent" }
                    contentItem: Text { text: "Cancelar Navegación"; color: Theme.textGray; font.bold: true; horizontalAlignment: Text.AlignHCenter }
                    onClicked: root.cancelNavigation()
                }
            }
        }
    }
}
