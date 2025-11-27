pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls
import ApplicationViews
import Popups
import Start

Rectangle {
    id: root

    property int currentIndex: 0

    implicitHeight: 70
    color: Theme.darkBackgroundColor

    Rectangle {
        width: parent.width; height: 1; color: "#eee"
        anchors.top: parent.top
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: [
                {"name": "Inicio", "icon": "icons/homeIcon.svg"},
                {"name": "Adopciones", "icon":"icons/pawIcon"},
                {"name": "Casos", "icon": "icons/casesIcon.svg"},
                {"name": "Perdidos", "icon": "icons/lostIcon.svg"},
            ]

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                required property var modelData
                required property int index

                property bool selected: root.currentIndex === index

                // Helper property to check if the icon string is a file path or an emoji
                property bool isImagePath: modelData.icon.toString().indexOf("/") >= 0 ||
                                           modelData.icon.toString().indexOf(".svg") >= 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    ToolButton {
                        visible: parent.parent.isImagePath

                        display: AbstractButton.IconOnly
                        background: null // Remove button background

                        icon.source: parent.parent.isImagePath ? parent.parent.modelData.icon : ""
                        icon.color: parent.parent.selected ? Theme.brandPink : Theme.iconNormal
                        icon.width: 38
                        icon.height: 38
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 42
                        Layout.alignment: Qt.AlignHCenter

                        hoverEnabled: false
                        enabled: false
                    }

                    Text {
                        visible: !parent.parent.isImagePath
                        text: parent.parent.modelData.icon

                        font.pixelSize: 45
                        Layout.alignment: Qt.AlignHCenter
                        color: parent.parent.selected ? Theme.brandPink : Theme.iconNormal
                    }

                    Text {
                        text: parent.parent.modelData.name
                        font.pixelSize: 12
                        color: parent.parent.selected ? Theme.brandPink : Theme.iconNormal
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.currentIndex = parent.index
                }
            }
        }
    }
}

