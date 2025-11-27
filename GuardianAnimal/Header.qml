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

    property bool showBackButton: false
    property int notificationCount: 2

    signal profileClicked()
    signal backClicked()
    signal notificationClicked()

    implicitHeight: 70

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // 1. Dashboard Icon
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

        // 2. TITLE
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

        // 3. PROFILE SIMULATION
        RowLayout {
            spacing: 8
            Layout.alignment: Qt.AlignRight

            // B. Profile Button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 20
                color: "#f3f4f6"

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qt/qml/GuardianAnimal/icons/profileIcon"
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
