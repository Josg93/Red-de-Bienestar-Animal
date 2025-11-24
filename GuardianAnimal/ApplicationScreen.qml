import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start

Rectangle {
    id: root

    property var satellitesModel: null
    property var sortFilterModel: null

    // --- UI STATES ---
    property bool navigationActive: false
    property bool reportActive: false
    property bool detailActive: false // STATE FOR PROFILE

    color: Theme.backgroundColor

    // HEADER
    Header {
        id: applicationHeader
        width: parent.width
        anchors.top: parent.top
        z: 10

        // Show back button if we are not on Dashboard OR if we are in a special mode
        showBackButton: navigationTab.currentIndex > 0 || root.navigationActive || root.reportActive || root.detailActive

        onBackClicked: {
            // Logic to return "Home" from deep states
            if (root.navigationActive || root.reportActive || root.detailActive) {
                root.navigationActive = false
                root.reportActive = false
                root.detailActive = false
                // Stay on the current tab index
            } else {
                navigationTab.currentIndex = 0
            }
        }

        // Profile Popup logic
        onProfileClicked: profilePopup.open()
    }

    // CONTENT STACK
    StackLayout {
        id: viewsLayout
        anchors.top: applicationHeader.bottom
        anchors.bottom: navigationTab.top
        anchors.left: parent.left
        anchors.right: parent.right

        // PRIORITY LOGIC FOR INDEX:
        // 1. Navigation (Map)
        // 2. Report Form
        // 3. Pet Detail View (New)
        // 4. Footer Tab
        currentIndex: root.navigationActive ? 4 :
                      (root.reportActive ? 5 :
                      (root.detailActive ? 6 : navigationTab.currentIndex))

        // 0: Dashboard
        DashboardView {
            onRequestView: (index) => navigationTab.currentIndex = index
        }

        // 1: Adoptions
        AdoptionView {
            // Pass global admin state
            isAdminMode: root.globalAdminMode

            // HANDLE OPENING PROFILE
            onOpenPetProfile: (petData) => {
                // 1. Pass data to the detail view
                // We clone the data object to ensure it persists
                var data = {
                    name: petData.name,
                    age: petData.age,
                    type: petData.type,
                    location: petData.location,
                    distance: petData.distance,
                    imagesJson: petData.imagesJson,
                    imageSource: petData.imageSource,
                    color1: petData.color1,
                    description: "Rescatado en la zona de " + petData.location
                }
                petDetailView.petData = data

                // 2. Switch to Detail Mode
                root.detailActive = true
            }
        }

        // 2: Rescue Cases
        RescueListView {
            onStartRescue: (caseId, dest) => {
                navView.caseId = caseId
                navView.destination = dest
                root.navigationActive = true
            }
            onOpenReportForm: () => root.reportActive = true
        }

        // 3: Lost & Found
        LostFoundView { }

        // 4: NAVIGATION
        NavigationView {
            id: navView
            onRescueCompleted: { root.navigationActive = false }
            onCancelNavigation: { root.navigationActive = false }
        }

        // 5: REPORT FORM
        ReportView {
            onCaseReported: (type, severity, loc, desc, img) => {
                console.log("Reported")
                root.reportActive = false
                navigationTab.currentIndex = 2
            }
            onCancelReport: root.reportActive = false
        }

        // 6: PET DETAIL VIEW
        PetDetailView {
            id: petDetailView
            onBackClicked: {
                // Close detail mode, returning to Adoptions list
                root.detailActive = false
            }
            onContactClicked: {
                console.log("Contacting owner...")
                // Logic for WhatsApp/Phone goes here
            }
        }
    }

    // FOOTER
    ViewSwitch {
        id: navigationTab
        anchors.bottom: parent.bottom
        width: parent.width

        // Disable/Hide footer if any special mode is active
        enabled: !root.navigationActive && !root.reportActive && !root.detailActive
        opacity: (root.navigationActive || root.reportActive || root.detailActive) ? 0.0 : 1.0

        Behavior on opacity { NumberAnimation { duration: 200 } }
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
    }
}
