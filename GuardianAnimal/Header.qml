import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start

Rectangle {
    id: root
    color: Theme.darkBackgroundColor
    border.color: "#f0f0f0"
    border.width: 1

    // -- PROPERTIES --
    property bool showBackButton: false
    property int notificationCount: 2

    // -- SIGNALS --
    signal profileClicked()
    signal backClicked()
    signal notificationClicked()

    implicitHeight: 70

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // 1. LEFT AREA (Back Button OR Dashboard Icon)
        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            // CASE A: Back Button
            ToolButton {
                visible: root.showBackButton
                anchors.centerIn: parent
                display: AbstractButton.TextOnly
                background: null

                contentItem: Text {
                    text: "←"
                    font.pixelSize: 24
                    font.bold: true
                    color: Theme.textMainColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: root.backClicked()
            }

            // CASE B: Dashboard Icon
            Rectangle {
                visible: !root.showBackButton
                width: 36; height: 36; radius: 18
                color: "#fce7f3" // Light Pink
                anchors.centerIn: parent
                Text {
                    anchors.centerIn: parent
                    text: "🐾"
                    font.pixelSize: 18
                }
            }
        }

        // 2. CENTER AREA (Title)
        Text {
            text: "Patitas Felices"
            font.family: "Helvetica"
            color: Theme.textMainColor
            font.pixelSize: Theme.largeFontSize + 4
            font.weight: Font.Bold
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        // 3. RIGHT AREA (Notifications + Profile)
        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignRight

            // A. Notification Bell
            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                ToolButton {
                    anchors.fill: parent
                    display: AbstractButton.IconOnly
                    background: null

                    icon.source: "icons/notificationIcon.svg"
                    icon.color: Theme.textSecondaryColor
                    icon.width: 32
                    icon.height: 32

                    onClicked: {
                        root.notificationCount = 0
                        root.notificationClicked()
                    }
                }

                // Red Badge
                Rectangle {
                    visible: root.notificationCount > 0
                    width: 16; height: 16; radius: 8
                    color: "#ef4444"
                    anchors.top: parent.top; anchors.right: parent.right
                    Text {
                        anchors.centerIn: parent
                        text: root.notificationCount
                        color: "white"; font.pixelSize: 10; font.bold: true
                    }
                }
            }

            // B. Profile Button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: "#f3f4f6"

                // Icon or Emoji (need to fix after frontend is done and add real icons
                Text {
                    anchors.centerIn: parent
                    text: "👤"
                    font.pixelSize: 20
                }

                // Click Area
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.profileClicked()
                }
            }
        }
    }
}
