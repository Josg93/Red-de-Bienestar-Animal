import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root

    property var satellitesModel: null
    property var sortFilterModel: null

    // State to control if we are in "Map Mode" or "Normal App Mode"
    property bool navigationActive: false

    color: Theme.backgroundColor

    Header {
        id: applicationHeader
        width: parent.width
        anchors.top: parent.top
        z: 10
    }

    StackLayout {
        id: viewsLayout
        anchors.top: applicationHeader.bottom
        anchors.bottom: navigationTab.top
        anchors.left: parent.left
        anchors.right: parent.right

        currentIndex: root.navigationActive ? 4 : navigationTab.currentIndex

        // Index 0: Dashboard
        DashboardView {
            onRequestView: (index) => {
                root.navigationActive = false // Ensure we aren't in nav mode
                navigationTab.currentIndex = index
            }
        }

        // Index 1: Adoptions
        AdoptionView { }

        // Index 2: Rescue Cases
        RescueListView {
            onStartRescue: (caseId, dest) => {
                // 1. Pass data to navigation view
                navView.caseId = caseId
                navView.destination = dest

                // 2. Switch to Navigation Mode (This triggers the currentIndex change)
                root.navigationActive = true
            }
        }

        // Index 3: Lost & Found
        LostFoundView { }

        // Index 4: NAVIGATION VIEW -> this shouldnt be shown in the view switch
        NavigationView {
            id: navView
            onRescueCompleted: {
                console.log("Rescate completado!")
                root.navigationActive = false
                navigationTab.currentIndex = 2
            }
            onCancelNavigation: {
                root.navigationActive = false
                navigationTab.currentIndex = 2
            }
        }
    }

    //FOOTER
    ViewSwitch {
        id: navigationTab
        anchors.bottom: parent.bottom
        width: parent.width

        // Disable footer interaction while navigating (Optional, but good UX)
        enabled: !root.navigationActive
        opacity: root.navigationActive ? 0.5 : 1.0
    }
}
