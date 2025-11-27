import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Item {
    id: root

    required property var imageList

    property string placeholderIcon: "🐾"

    readonly property bool hasImages: imageList && typeof imageList.length === 'number' && imageList.length > 0
    readonly property bool hasMultipleImages: imageList && typeof imageList.length === 'number' && imageList.length > 1

    Rectangle {
        anchors.fill: parent
        color: "#f3f4f6"
        clip: true

        // CASE 1: Single Image
        Image {
            id: singleImage
            visible: root.hasImages && !root.hasMultipleImages
            anchors.fill: parent
            source: root.hasImages ? imageList[0] : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true

            BusyIndicator {
                anchors.centerIn: parent
                running: singleImage.status === Image.Loading
                visible: running
                width: 40
                height: 40
            }
        }

        // CASE 2: Multiple Images
        SwipeView {
            id: imageSwipe
            visible: root.hasMultipleImages
            anchors.fill: parent
            clip: true

            Repeater {
                model: root.imageList

                Image {
                    source: modelData
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
        }

        // CASE 3: No Images - Single Placeholder
        ColumnLayout {
            visible: !root.hasImages
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: root.placeholderIcon
                font.pixelSize: 48
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.3
            }
            Text {
                text: "Sin fotos"
                color: Theme.textGray
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // PageIndicator - Only for multiple images
        PageIndicator {
            id: indicator
            visible: root.hasMultipleImages && imageSwipe.count > 1

            count: imageSwipe.count
            currentIndex: imageSwipe.currentIndex

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 10

            delegate: Rectangle {
                implicitWidth: 7
                implicitHeight: 7
                radius: 3.5
                color: "#ffffff"
                opacity: index === indicator.currentIndex ? 0.95 : 0.45

                Behavior on opacity {
                    OpacityAnimator { duration: 200 }
                }
            }
        }
    }
}

