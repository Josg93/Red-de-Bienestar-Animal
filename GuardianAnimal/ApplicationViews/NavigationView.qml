import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtLocation
import QtPositioning
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    property string caseId: ""
    property string destination: ""
    property var targetCoordinate: null
    property real distanceToTarget: 999999
    property var userLocation: QtPositioning.coordinate(8.605, -71.150)

    signal rescueCompleted(string outcome)
    signal cancelNavigation()

    onUserLocationChanged: updateDistance()
    onTargetCoordinateChanged: updateDistance()

    function updateDistance() {
        if (userLocation && userLocation.isValid && targetCoordinate && targetCoordinate.isValid) {
            distanceToTarget = userLocation.distanceTo(targetCoordinate)
        }
    }

    // --- ROUTE LOGIC ---
    Connections {
        target: backend
        function onRouteReady(path, distance, duration) {
            //console.log("QML: Route received with " + path.length + " points")

            // 1. Draw the line
            routeLine.path = path


            if (path.length > 0) {
                var start = path[0]
                var end = path[path.length - 1]
                var centerLat = (start.latitude + end.latitude) / 2
                var centerLon = (start.longitude + end.longitude) / 2

                rescueMap.center = QtPositioning.coordinate(centerLat, centerLon)
                rescueMap.zoomLevel = 14
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            if (backend.userLocation.isValid) {
                root.userLocation = backend.userLocation
                rescueMap.center = backend.userLocation
            }

            if (caseId !== "") {
                backend.requestRouteToAnimal(caseId)
            }
            updateDistance()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // TOP INFO
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "#1f2937"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 5

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "NAVEGANDO A"; color: "#9ca3af"; font.bold: true; font.pixelSize: 10 }
                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 60
                        height: 20
                        radius: 4
                        color: root.distanceToTarget < 500 ? "#22c55e" : "#f59e0b"
                        Text {
                            anchors.centerIn: parent
                            text: root.distanceToTarget < 500 ? "CERCA" : "EN RUTA"
                            font.bold: true
                            color: "white"
                            font.pixelSize: 10
                        }
                    }
                }

                Text {
                    text: root.destination
                    color: "white"
                    font.bold: true
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.topMargin: 10
                    Text {
                        text: (root.distanceToTarget / 1000).toFixed(1) + " km"
                        color: root.distanceToTarget < 500 ? "#4ade80" : "white"
                        font.bold: true
                        font.pixelSize: 28
                    }

                    Text {
                        text: "restantes"
                        color: "#d1d5db"
                        font.pixelSize: 14
                        Layout.alignment: Qt.AlignBottom
                        Layout.bottomMargin: 4
                    }
                }
            }
        }

        // THE MAP
        Map {
            id: rescueMap
            Layout.fillWidth: true
            Layout.fillHeight: true

            plugin: Plugin {
                name: "osm"
            }

            center: root.userLocation
            zoomLevel: 15
            copyrightsVisible: false

            // 1. The Route Line
            MapPolyline {
                id: routeLine
                line.width: 6
                line.color: "red"
                z: 10
                path: []
            }

            // 2. Destination Pin
            MapQuickItem {
                visible: root.targetCoordinate !== null
                coordinate: root.targetCoordinate ? root.targetCoordinate : rescueMap.center
                anchorPoint.x: sourceItem.width / 2
                anchorPoint.y: sourceItem.height
                z: 20 // Draw on top of line
                sourceItem: Column {
                    spacing: -5
                    Text { text: "📍"; font.pixelSize: 16 }
                }
            }

            MapQuickItem {
                coordinate: root.userLocation
                anchorPoint.x: sourceItem.width / 2
                anchorPoint.y: sourceItem.height / 2
                z: 20
                sourceItem: Rectangle {
                    width: 24; height: 24; radius: 12
                    color: "#2563eb"; border.color: "white"; border.width: 3
                }
            }
        }

        // BOTTOM ACTIONS
        Rectangle {

            Layout.fillWidth: true
            Layout.preferredHeight: 140
            color: "white"

            Rectangle {
                width: parent.width
                height: 1
                color: "#e5e7eb"
                anchors.top: parent.top
            }

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 20; spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50

                    background: Rectangle {
                        radius: 12
                        color: root.distanceToTarget < 500 ? "#16a34a" : "#374151"
                    }

                    contentItem: Text {
                        text: root.distanceToTarget < 500 ? "Llegué / Finalizar" : "Llegué al Lugar"
                        color: "white"; font.bold: true
                        font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        if (root.distanceToTarget > 500) geofenceWarning.open()
                        else outcomePopup.open()
                    }
                }

                Button {
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    background: Rectangle { radius: 12; color: "transparent" }
                    contentItem: Text { text: "Cancelar Navegación"; color: Theme.textGray; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: root.cancelNavigation()
                }
            }
        }
    }

    Popup {
        id: geofenceWarning
        parent: Overlay.overlay; anchors.centerIn: parent; width: Math.min(parent.width * 0.85, 400); height: 220; modal: true; focus: true
        background: Rectangle { color: "white"; radius: 16; border.color: "#e5e7eb"; border.width: 1 }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "⚠️ Estás lejos"
                font.bold: true
                font.pixelSize: 18
                color: Theme.textDark
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "GPS: " + (root.distanceToTarget/1000).toFixed(1) + "km de distancia. ¿Confirmar?"
                font.pixelSize: 13
                color: Theme.textGray
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle { color: "#f3f4f6"; radius: 8 }

                    contentItem: Text { text: "Cancelar"; color: Theme.textDark; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: geofenceWarning.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    background: Rectangle {
                        color: "#f59e0b"
                        radius: 8
                    }
                    contentItem: Text { text: "Sí, estoy aquí"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: { geofenceWarning.close(); outcomePopup.open() }
                }
            }
        }
    }

    OutcomeModal {
        id: outcomePopup
        onOutcomeSelected: (result) => {
            outcomePopup.close()
            root.rescueCompleted(result)
        }
    }
}
