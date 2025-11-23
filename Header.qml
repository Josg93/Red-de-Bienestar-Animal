// Header.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Rectangle {
    id: root
    color: Theme.darkBackgroundColor
    border.color: "#f0f0f0"
    border.width: 1

    implicitHeight: column.implicitHeight + 20

    ColumnLayout {
        id: column
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Title and notification
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Patitas Felices"
                font.family: "Helvetica"
                color: Theme.textMainColor
                font.pixelSize: Theme.largeFontSize + 2
                font.weight: Font.Bold
                Layout.fillWidth: true
            }

            Repeater {
                model: 1

                ToolButton {

                    display: AbstractButton.IconOnly
                    background: null

                    icon.source: "icons/notificationIcon.svg"
                    icon.color: Theme.textSecondaryColor
                    icon.width: 40
                    icon.height: 40
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40

                    enabled: false
                    hoverEnabled: true

                }
            }
        }


    }
}
