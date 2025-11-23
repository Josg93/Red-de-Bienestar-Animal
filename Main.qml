pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Window
import QtLocation
import QtPositioning
import mapmanager



Window {
    id: root
    //I HAVE TO CREATE THE LOADER WHEN OPENING THE APP ASWELL AS THE SIGNIN-Up
    //IGNORE THIS FROM TEMPLATE i used before
    // We change these from 'required property SatelliteModel' to 'property var'
    // This allows the app to run even if we haven't fixed the C++ backend yet.
    property var satellitesModel
    property var sortFilterModel

    width: 420 // Standard mobile width
    height: 800
    visible: true
    title: qsTr("Patitas Felices")

    // Keep the location permission logic
    LocationPermission {
        id: permission
        accuracy: LocationPermission.Precise
        availability: LocationPermission.WhenInUse
    }

    Component {
        id: applicationComponent
        ApplicationScreen {
            // We don't pass the models here right now,
            // so the UI will run in "Prototype Mode"
        }
    }

    Loader {
        anchors.fill: parent
        active: permission.status === Qt.PermissionStatus.Granted
        sourceComponent: applicationComponent
    }
}









