import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtPositioning
import ApplicationViews
import Popups
import Start

Rectangle {
    id: root

    // --- UI STATES ---
    property bool navigationActive: false
    property bool reportActive: false
    property bool detailActive: false
    property bool historyActive: false
    property bool happyTailsActive: false
    property bool reunitedActive: false

    color: Theme.backgroundColor

    // --- GLOBAL GPS TRACKER ---
    PositionSource {
        id: globalPosition
        active: true // Turn on GPS
        updateInterval: 10000
        preferredPositioningMethods: PositionSource.AllPositioningMethods

        onPositionChanged: {
            var coord = position.coordinate
            if (coord.isValid) {
                console.log("📍 GPS Update:", coord.latitude, coord.longitude)
                backend.updateUserPosition(coord.latitude, coord.longitude)
            }
        }
    }

    // HEADER
    Header {
        id: applicationHeader
        width: parent.width
        anchors.top: parent.top
        z: 10

        // Show back button if NOT on a main tab OR if in a special mode
        showBackButton: navigationTab.currentIndex > 0 ||
                        root.navigationActive ||
                        root.reportActive ||
                        root.detailActive ||
                        root.historyActive ||
                        root.happyTailsActive ||
                        root.reunitedActive

        onBackClicked: {
            // 1. Return from deep states
            if (root.navigationActive || root.reportActive || root.detailActive || root.happyTailsActive || root.reunitedActive) {
                root.navigationActive = false
                root.reportActive = false
                root.detailActive = false
                root.happyTailsActive = false
                root.reunitedActive = false
                root.detailActive = false

            }

            else if (root.historyActive) {
                root.historyActive = false
            }

            else {
                navigationTab.currentIndex = 0
            }
        }

        onProfileClicked: profilePopup.open()
    }

    // CONTENT STACK
    StackLayout {
        id: viewsLayout
        anchors.top: applicationHeader.bottom
        anchors.bottom: navigationTab.top
        anchors.left: parent.left
        anchors.right: parent.right

        // Stack Index Logic
        currentIndex: root.navigationActive ? 4 :
                      (root.reportActive ? 5 :
                      (root.detailActive ? 6 :
                      (root.historyActive ? 7 :
                      (root.happyTailsActive ? 8 :
                      (root.reunitedActive ? 9 : navigationTab.currentIndex))))) // <--- ADDED INDEX 9

        // Backend Mode Switching based on Tab
        onCurrentIndexChanged: {
            if (!root.navigationActive && !root.reportActive && !root.detailActive &&
                !root.historyActive && !root.happyTailsActive && !root.reunitedActive) {

                switch(currentIndex) {
                    case 1: // Adoptions
                        backend.setViewMode("adoption")
                        break
                    case 2: // Rescue Cases
                        backend.setViewMode("emergency")
                        break
                    case 3: // Lost & Found
                        // LostFoundView handles its own internal mode ("lost" or "found")
                        // passing "lost" as default safe bet
                        backend.setViewMode("lost")
                        break
                }
            }
        }

        // 0: Dashboard
        DashboardView {
            onRequestView: (index) => navigationTab.currentIndex = index
        }

        // 1: Adoptions
        AdoptionView {
            isAdminMode: root.globalAdminMode
            onOpenPetProfile: (petData) => {
                petDetailView.petData = petData
                root.detailActive = true
            }
            onOpenHappyTails: root.happyTailsActive = true
        }

        // 2: Rescue Cases
        RescueListView {
            onStartRescue: (caseId, dest) => {
                var animalDetails = backend.getAnimalDetails(caseId)
                if (animalDetails && animalDetails.coordinate) {
                    navView.caseId = caseId
                    navView.destination = dest
                    navView.targetCoordinate = animalDetails.coordinate
                    root.navigationActive = true
                }
            }
            onOpenReportForm: () => root.reportActive = true
        }

        // 3: Lost & Found
        LostFoundView {

            onOpenLostFoundDetail: (petData) => {
                petDetailView.petData = petData
                root.detailActive = true
            }

            onOpenReunitedView: {
                root.reunitedActive = true
            }
        }

        // 4: NAVIGATION
        NavigationView {
            id: navView
            onRescueCompleted: (outcome) => {
                backend.resolveCase(navView.caseId, outcome)
                root.navigationActive = false
                navigationTab.currentIndex = 2
            }
            onCancelNavigation: root.navigationActive = false
        }

        // 5: REPORT FORM
        ReportView {
            onCaseReported: (type, severity, loc, desc, img, gps) => {
                var safeGps = QtPositioning.coordinate()
                if (gps) { safeGps.latitude = gps.lat; safeGps.longitude = gps.lon }
                backend.addReport(type, severity, loc, desc, img, safeGps)
                root.reportActive = false
                navigationTab.currentIndex = 2
            }
            onCancelReport: root.reportActive = false
        }

        // 6: PET DETAIL VIEW
        PetDetailView {
            id: petDetailView
            isAdminMode: root.globalAdminMode
            onBackClicked: root.detailActive = false
           // onContactClicked: console.log("Contacting owner/shelter...")
        }

        // 7: HISTORY VIEW
        HistoryView {
            onBackClicked: root.historyActive = false
        }

        // 8: HAPPY TAILS VIEW
        HappyTailsView {
            onBackClicked: root.happyTailsActive = false
        }

        // 9: REUNITED VIEW
        ReunitedView {
            onBackClicked: root.reunitedActive = false
        }
    }

    // FOOTER
    ViewSwitch {
        id: navigationTab
        anchors.bottom: parent.bottom
        width: parent.width

        // Hide footer when deep navigation is active
        enabled: !root.navigationActive && !root.reportActive
        opacity: (root.navigationActive || root.reportActive) ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        onCurrentIndexChanged: {
            root.historyActive = false
            root.detailActive = false
            root.happyTailsActive = false
            root.reunitedActive = false
        }
    }

    // GLOBAL PROPERTIES
    property bool globalAdminMode: false

    ProfilePopup {
        id: profilePopup
        isShelterMode: root.globalAdminMode
        onRoleToggled: (isShelter) => root.globalAdminMode = isShelter
        onLogoutRequested: {
            profilePopup.close()
            root.globalAdminMode = false
            navigationTab.currentIndex = 0
        }
        onHistoryClicked: root.historyActive = true
    }
}
