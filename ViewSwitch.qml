pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Controls


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
                //{"name": "Perfil", "icon": "icons/profileIcon.svg"},

            ]

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                required property var modelData
                required property int index

                property bool selected: root.currentIndex === index

                // Helper property to check if the icon string is a file path or an emoji
                property bool isImagePath: modelData.icon.toString().indexOf("/") >= 0 || modelData.icon.toString().indexOf(".svg") >= 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    ToolButton {
                        visible: parent.parent.isImagePath

                        display: AbstractButton.IconOnly
                        background: null // Remove button background

                        icon.source: parent.parent.isImagePath ? parent.parent.modelData.icon : ""
                        icon.color: parent.parent.selected ? Theme.brandPink : Theme.iconNormal

                        // Force exact size to match your text icons
                        icon.width: 38
                        icon.height: 38
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 42
                        Layout.alignment: Qt.AlignHCenter

                        // Disable internal mouse interaction so the parent MouseArea works
                        hoverEnabled: false
                        enabled: false
                        // Note: If 'enabled: false' makes it too light/grey,
                        // remove 'enabled: false' and rely on the MouseArea (below) being on top.
                    }
                    // 2. TEXT COMPONENT (Shows only if it is NOT a path)
                    Text {
                        visible: !parent.parent.isImagePath // Only show if it is an emoji I HAVE TO DELETE THIS
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
