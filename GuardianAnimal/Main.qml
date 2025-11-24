// Main.qml
pragma ComponentBehavior: Bound
import QtCore
import QtQuick
import QtQuick.Window
//import SatelliteInformation
import ApplicationViews
import Popups
import Start

Window {
    id: root

    // Backend Models (passed from C++)
    property var satellitesModel
    property var sortFilterModel

    width: 420
    height: 800
    visible: true
    title: qsTr("Guardian Animal")

    // --- PERMISSION LOGIC ---
    LocationPermission {
        id: permission
        accuracy: LocationPermission.Precise
        availability: LocationPermission.WhenInUse
    }

    // --- APP STATES ---
    // 0: Splash, 1: Permissions, 2: Login, 3: App
    property int appState: 0

    // --- MAIN LOADER ---
    Loader {
        id: mainLoader
        anchors.fill: parent

        // Logic to decide what file to load
        sourceComponent: {
            if (appState === 0) return splashComponent
            if (appState === 1) return permissionComponent
            if (appState === 2) return loginComponent
            return applicationComponent
        }
    }

    // --- 1. SPLASH COMPONENT ---
    Component {
        id: splashComponent
        SplashScreen {
            onSplashFinished: {
                // Check permissions after splash
                if (permission.status === Qt.PermissionStatus.Granted) {
                    root.appState = 2 // Skip to Login
                } else {
                    root.appState = 1 // Go to Permissions
                }
            }
        }
    }

    // --- 2. PERMISSION COMPONENT ---
    Component {
        id: permissionComponent
        PermissionsScreen {
            requestDenied: permission.status === Qt.PermissionStatus.Denied
            onRequestPermission: permission.request()

            // Watch for status change
            Connections {
                target: permission
                function onStatusChanged() {
                    if (permission.status === Qt.PermissionStatus.Granted) {
                        root.appState = 2 // Go to Login
                    }
                }
            }
        }
    }

    // --- 3. LOGIN COMPONENT ---
    Component {
        id: loginComponent
        LoginScreen {
            onLoginSuccess: (username) => {
                console.log("User logged in: " + username)
                root.appState = 3 // Go to Main App
            }
        }
    }

    // --- 4. MAIN APPLICATION COMPONENT ---
    Component {
        id: applicationComponent
        ApplicationScreen {
            // Pass models here when C++ is ready
            // satellitesModel: root.satellitesModel
        }
    }
}
