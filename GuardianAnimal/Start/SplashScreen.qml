import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.brandPink

    signal splashFinished()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        // Big Logo
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 120; height: 120; radius: 60
            color: "white"

            Text {
                anchors.centerIn: parent
                text: "🐾"
                font.pixelSize: 60
            }
        }

        Text {
            text: "Patitas Felices"
            font.family: "Helvetica"
            font.bold: true
            font.pixelSize: 28
            color: "white"
            Layout.alignment: Qt.AlignHCenter
        }

        BusyIndicator {
            Layout.alignment: Qt.AlignHCenter
            running: true
            palette.dark: "white" // Make spinner white
        }
    }

    // Timer to auto-close splash after 3 seconds
    Timer {
        interval: 3000; running: true; repeat: false
        onTriggered: root.splashFinished()
    }
}
