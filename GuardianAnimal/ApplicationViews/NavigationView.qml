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

    property string caseId: ""
    property string destination: ""

    // SIMULATED LIVE DATA
    // In C++, this updates every second via QGeoPositionInfoSource
    property int distanceToTarget: 1200 // meters (Starts at 1.2km)

    signal rescueCompleted(string outcome)
    signal cancelNavigation()

    // Timer to simulate driving closer (Just for the demo!)
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            if (root.distanceToTarget > 50) root.distanceToTarget -= 100 // Get 100m closer every second
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // -- TOP INFO CARD --
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 140; color: "#1f2937"
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 5
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "NAVEGANDO A"; color: "#9ca3af"; font.bold: true; font.pixelSize: 10 }
                    Item { Layout.fillWidth: true }
                    Rectangle { width: 60; height: 20; radius: 4; color: "#22c55e"; Text { anchors.centerIn: parent; text: "EN RUTA"; font.bold: true; color: "white"; font.pixelSize: 10 } }
                }
                Text { text: root.destination; color: "white"; font.bold: true; font.pixelSize: 18; elide: Text.ElideRight; Layout.fillWidth: true }
                RowLayout {
                    Layout.topMargin: 10

                    // Dynamic Distance Display
                    Text {
                        text: (root.distanceToTarget / 1000).toFixed(1) + " km"
                        color: root.distanceToTarget < 500 ? "#4ade80" : "white" // Turn Green when close
                        font.bold: true; font.pixelSize: 28
                    }

                    Text { text: "restantes • Tráfico ligero"; color: "#d1d5db"; font.pixelSize: 14; Layout.alignment: Qt.AlignBottom; Layout.bottomMargin: 4 }
                }
            }
        }

        // -- MAP PLACEHOLDER --
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; color: "#e5e7eb"
            Image {
                anchors.centerIn: parent
                width: parent.width
                height: parent.width
                fillMode: Image.PreserveAspectFit
                source: "qrc:/qt/qml/GuardianAnimal/icons/locationsIcon.svg"; opacity: 0.1 }
            ColumnLayout {
                anchors.centerIn: parent; spacing: 10
                Text { text: "📍"; font.pixelSize: 40; Layout.alignment: Qt.AlignHCenter }
                Text { text: "[ MAPA EN TIEMPO REAL ]"; font.bold: true; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }

                // Debug info for us
                Text { text: "Simulación: Acercándose al destino..."; font.pixelSize: 12; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }
            }
        }

        // -- ACTION BUTTONS --
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 140; color: "white"
            Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.top: parent.top }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 10

                // SMART "LLEGUE" BUTTON
                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 50

                    // Visual Feedback: Turns Green only when "Geofence" is valid (< 500m)
                    background: Rectangle {
                        radius: 12
                        color: root.distanceToTarget < 500 ? "#16a34a" : "#374151" // Green if close, Dark Gray if far
                        Behavior on color { ColorAnimation { duration: 300 } }
                    }

                    contentItem: RowLayout {
                        anchors.centerIn: parent; spacing: 8
                        Text { text: "✅"; font.pixelSize: 18 }
                        Text {
                            text: "Llegué / Finalizar Rescate"
                            color: "white"; font.bold: true; font.pixelSize: 16
                        }
                    }

                    onClicked: {
                        // GEOFENCE LOGIC
                        if (root.distanceToTarget > 500) {
                            // Too far? Show warning
                            geofenceWarning.open()
                        } else {
                            // Close? Open outcome directly
                            outcomePopup.open()
                        }
                    }
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

    // -- GEOFENCE WARNING POPUP --
    Popup {
        id: geofenceWarning
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: 220
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle { color: "white"; radius: 16; border.color: "#e5e7eb"; border.width: 1 }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 20; spacing: 15

            Rectangle {
                Layout.alignment: Qt.AlignHCenter; width: 50; height: 50; radius: 25; color: "#fef3c7" // Yellow warning
                Text { anchors.centerIn: parent; text: "⚠️"; font.pixelSize: 24 }
            }

            Text {
                text: "Estás lejos del lugar"; font.bold: true; font.pixelSize: 18; color: Theme.textDark; Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "El GPS indica que estás a " + (root.distanceToTarget/1000).toFixed(1) + "km. ¿Estás seguro de que llegaste?";
                font.pixelSize: 13; color: Theme.textGray; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap; Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true; spacing: 10
                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#f3f4f6"; radius: 8 }
                    contentItem: Text { text: "Cancelar"; color: Theme.textDark; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: geofenceWarning.close()
                }
                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { color: "#f59e0b"; radius: 8 } // Orange override
                    contentItem: Text { text: "Sí, estoy aquí"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: {
                        geofenceWarning.close()
                        outcomePopup.open() // Allow override
                    }
                }
            }
        }
    }

    // -- OUTCOME MODAL --
    OutcomeModal {
        id: outcomePopup
        onOutcomeSelected: (result) => {
            outcomePopup.close()
            root.rescueCompleted(result)
        }
    }
}
