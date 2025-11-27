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
    property bool isAdminMode: false

    signal openPetProfile(var petData)
    signal openHappyTails()

    onVisibleChanged: { if (visible) backend.setViewMode("adoption") }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; height: 110; color: Theme.backgroundColor; z: 10
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10
                RowLayout {
                    Image { source: "qrc:/qt/qml/GuardianAnimal/icons/icons/dog.svg"; sourceSize: Qt.size(24, 24); Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
                    Text { text: "Adopta un Amigo"; font.pixelSize: Theme.largeFontSize + 2; font.bold: true; color: Theme.textDark }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 10
                    Rectangle {
                        Layout.fillWidth: true; Layout.preferredHeight: 40; color: Theme.bgWhite; radius: 10; border.color: "#e5e7eb"; border.width: 1
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10; spacing: 8
                            Text { text: "🔍"; font.pixelSize: 14 }
                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Buscar por nombre..."
                                font.pixelSize: 14
                                background: null
                                color: Theme.textDark

                                onTextChanged: backend.setSearchQuery(text)
                            }

                            Text { text: "✕"; color: Theme.textGray; visible: searchInput.text !== ""; MouseArea { anchors.fill: parent; onClicked: searchInput.text = "" } }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 40; Layout.preferredHeight: 40; radius: 10; color: Theme.darkBackgroundColor; border.color: Theme.separatorColor
                        Image { anchors.centerIn: parent; source: "qrc:/qt/qml/GuardianAnimal/icons/filterIcon3.svg" }
                        MouseArea { anchors.fill: parent; onClicked: filterModal.open() }
                    }
                }
            }
        }

        // GRID
        GridView {
            id: adoptionGrid
            Layout.fillWidth: true; Layout.fillHeight: true; Layout.leftMargin: 16; Layout.rightMargin: 16; clip: true
            cellWidth: width / 2; cellHeight: 300
            model: backend

            delegate: Rectangle {
                id: cardDelegate
                width: adoptionGrid.cellWidth - 10; height: adoptionGrid.cellHeight - 10
                radius: 14; color: Theme.bgWhite; border.color: "#e5e7eb"; border.width: 1; clip: true
                layer.enabled: true

                property bool isMyPost: root.isAdminMode && (model.ownerId === backend.currentUserId)

                visible: true
                opacity: 1.0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                ColumnLayout {
                    anchors.fill: parent; spacing: 0; visible: cardDelegate.visible

                    // Gallery
                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 160; clip: true
                        PetImageGallery {
                            anchors.fill: parent
                            imageList: model.images
                        }
                        Rectangle {
                            anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 10
                            height: 24; width: 70; radius: 12; color: "#dcfce7"; z: 10
                            Text { anchors.centerIn: parent; text: "DISPONIBLE"; font.pixelSize: 9; font.bold: true; color: "#15803d" }
                        }
                    }

                    // Info
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.margins: 10; spacing: 4
                        Text { text: model.name; font.bold: true; font.pixelSize: 16; color: Theme.textDark; Layout.fillWidth: true }
                        Text { text: model.type + " • " + model.age; font.pixelSize: 11; color: Theme.textGray }
                        Text {
                                text: model.description
                                font.pixelSize: 11
                                color: Theme.textGray
                                elide: Text.ElideRight
                                maximumLineCount: 2
                                Layout.fillWidth: true
                            }
                        Text { text: "📍 " + model.location + " (" + model.distance + ")"; font.pixelSize: 10; color: Theme.textGray; elide: Text.ElideRight; Layout.fillWidth: true }
                        Item { Layout.fillHeight: true }

                        Button {
                            Layout.fillWidth: true; Layout.preferredHeight: 36

                            background: Rectangle {
                                radius: 8
                                color: cardDelegate.isMyPost ? "#1f2937" : Theme.brandPink
                            }

                            contentItem: Text {
                                text: cardDelegate.isMyPost ? "⋮ Opciones" : "Contactar"
                                color: "white"; font.bold: true; font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (cardDelegate.isMyPost) {
                                    adminMenu.popup()
                                } else {

                                    var details = backend.getAnimalDetails(model.id)

                                    if (!details || !details.id) {
                                        details = {
                                            id: model.id,
                                            name: model.name,
                                            type: model.type,
                                            age: model.age,
                                            location: model.location,
                                            distance: model.distance,
                                            description: model.description,
                                            images: model.images,
                                            imageSource: model.imageSource
                                        }
                                    }

                                    root.openPetProfile(details)
                                }
                            }

                            Menu {
                                id: adminMenu
                                width: 200

                                MenuItem {
                                    text: "✎ Editar"
                                    onTriggered: {
                                        addPetPopup.openForEdit({
                                            id: model.id,
                                            name: model.name,
                                            type: model.type,
                                            age: model.age,
                                            location: model.location,
                                            description: model.description,
                                            images: model.images,
                                            imageSource: model.imageSource
                                        })
                                    }
                                }

                                MenuItem {
                                    // 1. Assign the icon source
                                    icon.source: "qrc:/qt/qml/GuardianAnimal/icons/celebrationIcon.svg"

                                    // 2. Assign the text
                                    text: "Mover a Happy Tails"

                                    // Optional: Set the icon color (for monochromatic SVGs)
                                    icon.color: Theme.brandPink

                                    onTriggered: {
                                        // ... (Your logic remains the same) ...
                                        backend.resolveCase(model.id, "Adoptado")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // FOOTER Link
        Rectangle {
            Layout.fillWidth: true; height: 50; color: "white"
            Rectangle { width: parent.width; height: 1; color: "#e5e7eb"; anchors.top: parent.top }
            RowLayout {
                anchors.centerIn: parent
                Text { text: "🎉 Ver Finales Felices"; font.bold: true; color: Theme.brandPink }
                Text { text: "→"; font.bold: true; color: Theme.brandPink }
            }
            MouseArea { anchors.fill: parent; onClicked: root.openHappyTails() }
        }
    }

    // FAB (Admin Only)
    FloatingActionButton {
        visible: root.isAdminMode
        anchors.bottom: parent.bottom; anchors.right: parent.right
        anchors.margins: 20

        // Uses default color (Pink) and default icon (Add)
        onClicked: {
            addPetPopup.openForAdd()
        }
    }

    AddPetPopup {
        id: addPetPopup

        onPetAdded: function(name, type, ageVal, ageUnit,
                             sex, isSpayed,
                             shelterName, description,
                             phone, email, images) {

            var ageString = ageVal + " " + ageUnit
            var imageStrings = images.map(function(x) { return x.toString() })

            backend.addAdoption(
                name,
                type,
                ageString,
                sex,
                isSpayed,
                description,
                phone,
                email,
                imageStrings,
                shelterName
            )
        }

        onPetUpdated: function(id, name, type, age,
                               shelterName, description,
                               phone, email, images) {

            var imageStrings = images.map(function(x) { return x.toString() })

            // Recover sex/isSpayed from backend, so edits don't wipe them
            var data = backend.getAnimalDetails(id)
            var sex = data.sex || ""
            var isSpayed = data.isSpayed === true

            backend.updateAdoption(
                id,
                name,
                type,
                age,
                sex,
                isSpayed,
                description,
                phone,
                email,
                imageStrings,
                shelterName
            )
        }
    }

    AdoptionFilter {
        id: filterModal

        onFiltersApplied: {
            console.log("Filters: Radius=" + filterModal.currentRadius + ", Species=" + filterModal.currentSpecies)

            // Apply Radius Filter (Same logic as RescueListView)
            if (filterModal.currentRadius === "Todo") {
                backend.setFilterByRadius(false) // KNN Mode
            } else {
                var km = parseInt(filterModal.currentRadius)
                backend.setSearchRadius(km)
                backend.setFilterByRadius(true) // Range Search Mode
            }

            // Species filter is handled in QML delegate visibility
        }
    }
}
