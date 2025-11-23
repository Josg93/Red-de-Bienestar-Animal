import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Item {
    id: root

    required property var imageList // Array of image URLs

    // Optional: Fallback colors for when no images exist
    property var fallbackColors: ["#0f766e", "#115e59", "#134e4a"]
    property string placeholderIcon: "🐾"

    readonly property bool hasImages: imageList.length > 0
    readonly property bool hasMultipleImages: imageList.length > 1

    Rectangle {
        anchors.fill: parent
        color: "#f3f4f6"
        radius: 0  // Inherits from parent
        clip: true

        // CASE 1: Single Real Image
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

        // CASE 2: Multiple Real Images with SwipeView
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

        // CASE 3: No Images - Show Colored Cards (Your Original Design)
        SwipeView {
            id: colorSwipe
            visible: !root.hasImages && root.fallbackColors.length > 0
            anchors.fill: parent
            clip: true

            Repeater {
                model: root.fallbackColors

                Rectangle {
                    color: modelData

                    // Placeholder icon
                    Text {
                        anchors.centerIn: parent
                        text: root.placeholderIcon
                        font.pixelSize: 48
                        opacity: 0.3
                    }
                }
            }
        }

        // PageIndicator - Shows for multiple images OR color cards
        PageIndicator {
            id: indicator
            visible: (root.hasMultipleImages && imageSwipe.count > 1) ||
                     (!root.hasImages && colorSwipe.count > 1)

            count: root.hasMultipleImages ? imageSwipe.count : colorSwipe.count
            currentIndex: root.hasMultipleImages ? imageSwipe.currentIndex : colorSwipe.currentIndex

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

        // Empty state (no images AND no fallback colors)
        ColumnLayout {
            visible: !root.hasImages && root.fallbackColors.length === 0
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: "📷"
                font.pixelSize: 32
                Layout.alignment: Qt.AlignHCenter
                opacity: 0.4
            }
            Text {
                text: "Sin fotos"
                color: Theme.textGray
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
