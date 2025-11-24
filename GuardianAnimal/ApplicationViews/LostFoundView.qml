import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    property string currentTab: "lost" // "lost" or "found"

    property string currentUserId: UserSession.userId

    // DATA MODELS
    ListModel {
        id: lostModel

        //NEED TO DELETE THIS CASES
        // Case 1: Created by (user_123). I can close this.
        ListElement {
            name: "Coco"; type: "Gato"; breed: "Persa"; location: "La Humboldt"; distance: "1.2 km"
            status: "lost"; date: "Hace 2 horas";
            ownerId: "user123"; contact: "0414-555-5555"
            imagesJson: "[]"; imageSource: ""; color1: "#fecaca"
        }
        // Case 2: Created by STRANGER (user_999). I can only contact them.
        ListElement {
            name: "Rocky"; type: "Perro"; breed: "Labrador"; location: "Av. Las Américas"; distance: "5.0 km"
            status: "lost"; date: "Ayer";
            ownerId: "user_999"; contact: "0424-123-4567"
            imagesJson: "[]"; imageSource: ""; color1: "#fecaca"
        }
    }

    ListModel {
        id: foundModel
        ListElement {
            name: "Sin Collar"; type: "Perro"; breed: "Husky"; location: "Av. Universidad"; distance: "0.5 km"
            status: "found"; date: "Hoy, 8:00 AM";
            ownerId: "user_999"; contact: "0416-987-6543"
            imagesJson: "[]"; imageSource: ""; color1: "#d1fae5"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; height: 130; color: Theme.backgroundColor; z: 10
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10

                Text { text: "Perdidos y Encontrados"; font.pixelSize: Theme.largeFontSize + 2; font.bold: true; color: Theme.textDark }

                // Search & Filter
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.bgWhite; radius: 10; border.color: "#e5e7eb"; border.width: 1
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                            Text { text: "🔍"; font.pixelSize: 14 }
                            TextField {
                                id: searchInput; Layout.fillWidth: true; placeholderText: "Buscar ID, raza, lugar..."; font.pixelSize: 14
                                background: null; color: Theme.textDark
                            }
                            Text { text: "✕"; color: Theme.textGray; visible: searchInput.text !== ""; MouseArea { anchors.fill: parent; onClicked: searchInput.text="" } }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 40; Layout.preferredHeight: 40; radius: 10; color: Theme.darkBackgroundColor; border.color: Theme.separatorColor
                        Text { anchors.centerIn: parent; text: "Filtro" }
                        MouseArea { anchors.fill: parent; onClicked: filterModal.open() }
                    }
                }

                // Tabs
                Rectangle {
                    Layout.fillWidth: true; height: 36; radius: 10; color: "#e5e7eb"
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 3; spacing: 4
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8
                            color: root.currentTab === "lost" ? Theme.bgWhite : "transparent"
                            Text { anchors.centerIn: parent; text: "PERDIDOS"; font.bold: true; font.pixelSize: 11; color: root.currentTab === "lost" ? "#dc2626" : Theme.textGray }
                            MouseArea { anchors.fill: parent; onClicked: root.currentTab = "lost" }
                        }
                        Rectangle {
                            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8
                            color: root.currentTab === "found" ? Theme.bgWhite : "transparent"
                            Text { anchors.centerIn: parent; text: "ENCONTRADOS"; font.bold: true; font.pixelSize: 11; color: root.currentTab === "found" ? "#059669" : Theme.textGray }
                            MouseArea { anchors.fill: parent; onClicked: root.currentTab = "found" }
                        }
                    }

                }
            }
        }

        Item { height:20 } //spacer

        // LIST VIEW
        ListView {
            id: listView
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 15
            model: root.currentTab === "lost" ? lostModel : foundModel

            delegate: Rectangle {
                id: cardDelegate
                width: listView.width - 32;
                height: 130
                anchors.horizontalCenter: parent.horizontalCenter
                radius: 12; color: Theme.bgWhite; border.color: "#e5e7eb"; border.width: 1

                // Search Logic
                visible: searchInput.text === "" || model.name.toLowerCase().includes(searchInput.text.toLowerCase())
                opacity: visible ? 1.0 : 0.0

                // Status Strip
                Rectangle { width: 4; height: parent.height; anchors.left: parent.left; radius: 2; color: model.status === "lost" ? "#dc2626" : "#059669" }

                RowLayout {
                    anchors.fill: parent; anchors.margins: 10; anchors.leftMargin: 16; spacing: 12
                    visible: cardDelegate.visible

                    // GALLERY
                    Rectangle {
                        Layout.preferredWidth: 100; Layout.fillHeight: true; radius: 8; clip: true
                        PetImageGallery {
                            anchors.fill: parent
                            imageList: {
                                if (model.imagesJson && model.imagesJson !== "") {
                                    try { return JSON.parse(model.imagesJson) } catch(e) {}
                                }
                                if (model.imageSource && model.imageSource !== "") return [model.imageSource]
                                return []
                            }
                            placeholderIcon: model.status === "lost" ? "🔍" : "🏠"
                            fallbackColors: model.status === "lost" ? ["#fee2e2", "#fecaca"] : ["#d1fae5", "#a7f3d0"]
                        }
                    }

                    // INFO & ACTIONS
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 4

                        // Top Row: Badge + "Mine" indicator
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle {
                                width: badgeText.width + 12; height: 20; radius: 4; color: model.status === "lost" ? "#fee2e2" : "#d1fae5"
                                Text { id: badgeText; anchors.centerIn: parent; font.pixelSize: 9; font.bold: true; text: model.status === "lost" ? "PERDIDO" : "ENCONTRADO"; color: model.status === "lost" ? "#dc2626" : "#059669" }
                            }
                            // "Mine" Indicator
                            Rectangle {
                                visible: model.ownerId === currentUserId
                                width: 36; height: 20; radius: 4; color: Theme.textDark
                                Text { anchors.centerIn: parent; text: "MIO"; font.pixelSize: 9; font.bold: true; color: "white" }
                            }
                        }

                        Text { text: model.name; font.bold: true; font.pixelSize: 16; color: Theme.textDark }
                        Text { text: model.breed + " • " + model.date; font.pixelSize: 11; color: Theme.textGray }
                        Item { Layout.fillHeight: true }

                        // --- SMART ACTION BUTTONS ---
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "📍 " + model.distance; font.pixelSize: 11; font.bold: true; color: "#4f46e5" }
                            Item { Layout.fillWidth: true }

                            // BUTTON A: I am the Owner -> "Close Case"
                            Button {
                                visible: model.ownerId === root.currentUserId
                                Layout.preferredHeight: 30
                                background: Rectangle { radius: 15; color: "#dcfce7" } // Green tint
                                contentItem: Text {
                                    text: model.status === "lost" ? "✅ Ya lo encontré" : "✅ Entregado"
                                    font.pixelSize: 11; font.bold: true; color: "#15803d"
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    // Logic: Remove from active list (Simulating "Moving to History")
                                    if (root.currentTab === "lost") lostModel.remove(index)
                                    else foundModel.remove(index)
                                    console.log("Case resolved!")
                                }
                            }

                            // BUTTON B: I am Stranger -> "Contact Owner"
                            Button {
                                visible: model.ownerId !== root.currentUserId
                                Layout.preferredHeight: 30
                                background: Rectangle { radius: 15; color: "#dbeafe" } // Blue tint
                                contentItem: Text {
                                    text: model.status === "lost" ? "👁️ Lo vi / Contactar" : "🤔 Es mío"
                                    font.pixelSize: 11; font.bold: true; color: "#1e40af"
                                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                }
                                onClicked: {
                                    console.log("Calling " + model.contact)
                                    // In real app: Qt.openUrlExternally("tel:" + model.contact)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // REPORT BUTTON POPUP
    Button {
        width: 56; height: 56; anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.margins: 20; z: 50
        background: Rectangle { radius: 28; color: root.currentTab === "lost" ? "#dc2626" : "#059669" }
        contentItem: Text { text: "+"; font.pixelSize: 30; color: "white"; anchors.centerIn: parent; anchors.verticalCenterOffset: -2 }
        onClicked: reportPopup.open()
    }

    // REPORT POPUP
    ReportLostFoundPopup {
        id: reportPopup
        onReportAdded: (status, name, type, breed, date, location, contact, images) => {
            var jsonImages = JSON.stringify(images)
            var mainImage = images.length > 0 ? images[0].toString() : ""

            var newReport = {
                "name": name === "" ? "Desconocido" : name,
                "type": type, "breed": breed, "location": location, "date": date,
                "distance": "0.1 km", "status": status, "contact": contact,

                // ASSIGN OWNERSHIP AUTOMATICALLY
                "ownerId": root.currentUserId,

                "imagesJson": jsonImages, "imageSource": mainImage,
                "color1": status === "lost" ? "#fecaca" : "#d1fae5"
            }

            if (status === "lost") lostModel.insert(0, newReport)
            else foundModel.insert(0, newReport)

            root.currentTab = status
        }
    }

    AdoptionFilter { id: filterModal }
}
