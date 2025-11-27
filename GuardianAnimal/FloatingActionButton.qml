import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Effects
import GuardianAnimal

Item {
    id: root

    signal clicked()

    property color buttonColor: Theme.brandPink
    property string iconSource: "icons/addIcon.png"

    width: 56; height: 56
    z: 50

    // 1. The Circle Background + Drop Shadow
    Rectangle {
        id: bgRect
        anchors.fill: parent
        radius: width / 2
        color: root.buttonColor

        scale: mouseArea.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#60000000"
            shadowBlur: 0.6
            shadowVerticalOffset: 4
        }
    }

    // 2. The White Icon (Using Masking)
    Item {
        anchors.centerIn: parent
        width: 24; height: 24

        // Scale the whole icon container on press
        scale: mouseArea.pressed ? 0.92 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }

        // A. The Raw Image (Hidden, used as the mask source)
        Image {
            id: maskImg
            anchors.fill: parent
            source: root.iconSource
            fillMode: Image.PreserveAspectFit
            visible: false // Crucial: Hide the original black/colored image
            asynchronous: true
        }

        // B. The White Block (Visible, but masked by the image)
        Rectangle {
            anchors.fill: parent
            color: "white" // <--- This forces the icon to be White
            visible: maskImg.status === Image.Ready // Only show when icon loads

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: maskImg
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
