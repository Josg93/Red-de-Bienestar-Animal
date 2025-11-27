import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Effects
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    property string currentTab: "lost"
    property string currentUserId: UserSession.userId

    signal openLostFoundDetail(var petData)
    signal openReunitedView()

    onVisibleChanged: if (visible) backend.setViewMode(currentTab)

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true
            height: 120
            color: Theme.backgroundColor
            z: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Text {
                    text: "Perdidos y Encontrados"
                    font.pixelSize: 22
                    font.bold: true
                    color: Theme.textDark
                }

                // Search + Filter
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: Theme.bgWhite
                        radius: 10
                        border.color: "#e5e7eb"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10

                            Image { source: "qrc:/qt/qml/GuardianAnimal/icons/lostIcon.svg"}

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Buscar..."
                                font.pixelSize: 14
                                background: null
                                color: Theme.textDark
                                onTextChanged: backend.setSearchQuery(text)
                            }

                            Text {
                                text: "✕"
                                color: Theme.textGray
                                visible: searchInput.text !== ""
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        searchInput.text = ""
                                        backend.setSearchQuery("")
                                    }
                                }
                            }
                        }
                    }

                    // Reuse AdoptionFilter
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 10
                        color: Theme.darkBackgroundColor
                        border.color: Theme.separatorColor
                        Text {
                            anchors.centerIn: parent
                            text: "FILTRAR"
                            font.pixelSize: 11

                        }
                        MouseArea { anchors.fill: parent; onClicked: filterModal.open() }
                    }
                }

                // Tabs
                Rectangle {
                    Layout.fillWidth: true
                    height: 36
                    radius: 10
                    color: "#e5e7eb"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 3
                        spacing: 4

                        // LOST TAB
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.currentTab === "lost" ? Theme.bgWhite : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "PERDIDOS"
                                font.bold: true
                                font.pixelSize: 11
                                color: root.currentTab === "lost" ? "#dc2626" : Theme.textGray
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (root.currentTab !== "lost") {
                                        root.currentTab = "lost"
                                        backend.setViewMode("lost")
                                    }
                                }
                            }
                        }

                        // FOUND TAB
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.currentTab === "found" ? Theme.bgWhite : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "VISTOS / ENCONTRADOS"
                                font.bold: true
                                font.pixelSize: 11
                                color: root.currentTab === "found" ? "#2563eb" : Theme.textGray
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (root.currentTab !== "found") {
                                        root.currentTab = "found"
                                        backend.setViewMode("found")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // GRID VIEW
        GridView {
            id: gridView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 16
            Layout.rightMargin: 16
            Layout.topMargin: 10
            clip: true

            cellWidth: width / 2
            cellHeight: 290

            model: backend

            delegate: Rectangle {
                id: cardDelegate
                width: gridView.cellWidth - 10
                height: gridView.cellHeight - 10
                radius: 14
                color: Theme.bgWhite
                border.color: "#e5e7eb"
                border.width: 1
                clip: true

                property bool isMine: (model.ownerId === backend.currentUserId)

                // CARD CLICK → DETAIL
                MouseArea {
                    anchors.fill: parent
                    propagateComposedEvents: true
                    z: -1
                    onClicked: {
                        root.openLostFoundDetail({
                            id: model.id,
                            name: model.name,
                            type: model.type,
                            age: model.age || "Fecha: " + Qt.formatDateTime(model.timestamp, "dd/MM"),
                            location: model.location,
                            description: model.description,
                            images: model.images,
                            imageSource: model.imageSource,
                            status: model.status,
                            contactPhone: model.contactPhone
                        })
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // IMAGE
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        clip: true

                        PetImageGallery {
                            anchors.fill: parent
                            imageList: model.images
                            placeholderIcon: model.status === "lost" ? "🐕?" : "👀"
                        }

                        // STATUS BADGE
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 8
                            height: 24
                            width: statusText.implicitWidth + 16
                            radius: 12
                            color: model.status === "lost" ? "#fee2e2" : "#dbeafe"

                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: model.status === "lost" ? "PERDIDO" : "VISTO"
                                font.bold: true
                                font.pixelSize: 10
                                color: model.status === "lost" ? "#dc2626" : "#1e40af"
                            }
                        }

                        // MINE BADGE
                        Rectangle {
                            visible: cardDelegate.isMine
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 8
                            height: 20
                            width: 40
                            radius: 4
                            color: "black"
                            Text {
                                anchors.centerIn: parent
                                text: "YO"
                                color: "white"
                                font.bold: true
                                font.pixelSize: 10
                            }
                        }
                    }

                    // TEXT CONTENT
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.margins: 10
                        spacing: 4

                        Text {
                            text: model.name
                            font.bold: true
                            font.pixelSize: 16
                            color: Theme.textDark
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: (model.breed ? model.breed : "Sin raza") +
                                  " • " + Qt.formatDateTime(model.timestamp, "dd MMM")
                            font.pixelSize: 11
                            color: Theme.textGray
                        }

                        Text {
                            text: "📍 " + model.location
                            font.pixelSize: 11
                            color: Theme.textGray
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Item { Layout.fillHeight: true }

                        // ACTION BUTTON
                        Button {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36

                            background: Rectangle {
                                radius: 8
                                color: cardDelegate.isMine
                                       ? "#dcfce7"
                                       : (model.status === "lost" ? "#fee2e2" : "#dbeafe")
                                border.color: cardDelegate.isMine ? "#16a34a" : "transparent"
                                border.width: cardDelegate.isMine ? 1 : 0
                            }

                            contentItem: RowLayout {
                                anchors.centerIn: parent // Center the whole row (icon + text)
                                spacing: 6 // Space between icon and text

                                // 1. Icon (Only visible if NOT yours)
                                Image {
                                    visible: !cardDelegate.isMine
                                    source: "qrc:/qt/qml/GuardianAnimal/icons/phoneIcon.svg" // Using an existing general contact icon
                                    width: 14; height: 14 // Small size for inline icon

                                    // Tint the SVG to match the text color dynamically
                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        colorization: 1.0
                                        colorizationColor: model.status === "lost" ? "#dc2626" : "#1e40af"
                                    }
                                }

                                // 2. Text Label
                                Text {
                                    // Text remains clean (no emoji)
                                    text: cardDelegate.isMine ? "✓ Ya en casa" : "Contactar"

                                    color: cardDelegate.isMine
                                           ? "#16a34a"
                                           : (model.status === "lost" ? "#dc2626" : "#1e40af")

                                    font.bold: true
                                    font.pixelSize: 12
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            onClicked: {
                                if (cardDelegate.isMine) {
                                    backend.resolveCase(model.id, "Reunido en Casa")
                                } else if (model.contactPhone) {
                                    Qt.openUrlExternally("tel:" + model.contactPhone)
                                }
                            }
                        }


                    }
                }
            }
        }

        // FOOTER → Reunited history
        Rectangle {
            Layout.fillWidth: true
            height: 50
            color: "white"
            Rectangle {
                width: parent.width
                height: 1
                color: "#e5e7eb"
                anchors.top: parent.top
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: "🏠 Ver casos reunidos"; font.bold: true; color: Theme.brandPink }
                Text { text: "→"; font.bold: true; color: Theme.brandPink }
            }

            MouseArea { anchors.fill: parent; onClicked: root.openReunitedView() }
        }
    }

    // FAB (Dynamic Color)
        FloatingActionButton {
            anchors.bottom: parent.bottom; anchors.right: parent.right
            anchors.margins: 20
            anchors.bottomMargin: 70 // Keep it lifted above the footer

            // Change color based on the active tab
            buttonColor: root.currentTab === "lost" ? "#dc2626" : "#2563eb"

            onClicked: {
                reportPopup.reportType = root.currentTab
                reportPopup.open()
            }
        }

    // POPUP
    ReportLostFoundPopup {
        id: reportPopup

        onReportAdded: function(status, name, type, breed, date, location, contact, images) {
            var cleanType = type.replace(/[^\w\s]/gi, "").trim()
            backend.addLostFound(
                        status,
                        name || "Desconocido",
                        cleanType,
                        breed,
                        date,
                        location,
                        contact,
                        images)
            root.currentTab = status
            backend.setViewMode(status)
        }
    }

    // FILTER
    AdoptionFilter {
        id: filterModal
        onFiltersApplied: {
            var km = (filterModal.currentRadius === "Todo")
                     ? 500
                     : parseInt(filterModal.currentRadius)
            backend.setSearchRadius(km)
            backend.setSpeciesFilter(filterModal.currentSpecies)
            backend.setFilterByRadius(filterModal.currentRadius !== "Todo")
        }
    }
}
