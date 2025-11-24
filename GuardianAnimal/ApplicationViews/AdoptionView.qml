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

    // controlled by ApplicationScreen (via ProfilePopup)
    property bool isAdminMode: false
    signal openPetProfile(var petData)

    // -- DATA MODELS MOCKUPS--
    ListModel {
        id: availablePetsModel

        ListElement {
            name: "Max"; type: "Perro"; age: "2 años"; location: "Refugio Central"; distance: "2.5 km"; requests: 0
            color1: "#0f766e"; color2: "#115e59"; color3: "#134e4a"
            imageSource: ""; imagesJson: "[]"
        }
        ListElement {
            name: "Luna"; type: "Gato"; age: "8 meses"; location: "Casa Temporal"; distance: "1.8 km"; requests: 2
            color1: "#be185d"; color2: "#9d174d"; color3: "#831843"
            imageSource: ""; imagesJson: "[]"
        }
        ListElement {
            name: "Toby"; type: "Perro"; age: "Cachorro"; location: "La Hechicera"; distance: "7.1 km"; requests: 5
            color1: "#1e40af"; color2: "#1e3a8a"; color3: "#172554"
            imageSource: ""; imagesJson: "[]"
        }
    }

    ListModel {
        id: happyTailsModel
        ListElement { name: "Rocky"; color1: "#f59e0b"; imageSource: "" }
    }

    // -- MAIN LAYOUT --
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER AREA
        Rectangle {
            Layout.fillWidth: true
            height: 110
            color: Theme.backgroundColor
            z: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // Row 1: Title
                RowLayout {
                    Image { source: "qrc:/qt/qml/GuardianAnimal/icons/dog.svg"; sourceSize: Qt.size(24, 24); Layout.preferredWidth: 24; Layout.preferredHeight: 24 }
                    Text { text: "Adopta un Amigo"; font.pixelSize: Theme.largeFontSize + 2; font.bold: true; color: Theme.textDark }
                }

                // Row 2: Search + Filter
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // SEARCH BAR
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: Theme.bgWhite
                        radius: 10
                        border.color: searchInput.activeFocus ? Theme.brandPink : "#e5e7eb"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                            spacing: 8
                            Image { source: "qrc:/qt/qml/GuardianAnimal/icons/lostIcon.svg"; height: 10; width: 10 } // Reusing icon as search icon placeholder if needed

                            TextField {
                                id: searchInput
                                Layout.fillWidth: true
                                placeholderText: "Buscar por nombre..."
                                font.pixelSize: 14
                                color: Theme.textDark
                                background: null
                                verticalAlignment: TextInput.AlignVCenter
                            }

                            // Clear Button
                            Text {
                                text: "✕"
                                color: Theme.textGray
                                visible: searchInput.text !== ""
                                MouseArea { anchors.fill: parent; onClicked: searchInput.text = "" }
                            }
                        }
                    }

                    // FILTER BUTTON
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        radius: 10
                        color: Theme.darkBackgroundColor
                        border.color: Theme.separatorColor

                        Text { anchors.centerIn: parent; text: "⚡"; font.pixelSize: 16 } // Filter Icon placeholder

                        MouseArea { anchors.fill: parent; onClicked: filterModal.open() }
                    }
                }
            }
        }

        // -- GRID VIEW --
        GridView {
            id: adoptionGrid
            Layout.fillWidth: true; Layout.fillHeight: true
            Layout.leftMargin: 16; Layout.rightMargin: 16
            clip: true
            cellWidth: width
            cellHeight: 290

            model: availablePetsModel

            delegate: Rectangle {
                id: cardDelegate
                width: adoptionGrid.cellWidth - 10
                height: adoptionGrid.cellHeight - 10
                radius: 14; color: Theme.bgWhite; border.color: "#e5e7eb"; border.width: 1
                clip: true
                layer.enabled: true

                // FILTERING LOGIC
                visible: searchInput.text === "" || model.name.toLowerCase().includes(searchInput.text.toLowerCase())
                opacity: visible ? 1.0 : 0.0

                ColumnLayout {
                    anchors.fill: parent; spacing: 0
                    visible: cardDelegate.visible

                    // IMAGE AREA
                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 160; clip: true

                        PetImageGallery {
                            id: petGallery
                            anchors.fill: parent
                            // JSON Fix Logic
                            imageList: {
                                if (model.imagesJson && model.imagesJson !== "") {
                                    try {
                                        var parsed = JSON.parse(model.imagesJson)
                                        if (parsed.length > 0) return parsed
                                    } catch (e) { console.log("Error parsing images: " + e) }
                                }
                                if (model.imageSource && model.imageSource !== "") return [model.imageSource]
                                return []
                            }
                        }

                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 10
                            height: 24
                            width: 70
                            radius: 12
                            color: "#dcfce7"
                            z: 10
                            Text {
                                anchors.centerIn: parent
                                text: "DISPONIBLE"
                                font.pixelSize: 9
                                font.bold: true
                                color: "#15803d"
                            }
                        }
                    }

                    // INFO AREA
                    ColumnLayout {
                        Layout.fillWidth: true; Layout.margins: 10; spacing: 4
                        Text {
                            text: model.name
                            font.bold: true
                            font.pixelSize: 16
                            color: Theme.textDark
                        }

                        Text {
                            text: model.type + " • " + model.age
                            font.pixelSize: 11
                            color: Theme.textGray
                        }

                        RowLayout {
                            spacing: 4
                            Text {
                                text: "📍"
                                font.pixelSize: 10
                            } //CHANGE TO ICON
                            Text {
                                text: model.distance
                                font.pixelSize: 11
                                font.bold: true
                                color: "#4f46e5"
                            }
                            Text {
                                text: " (" + model.location + ")"
                                font.pixelSize: 10
                                color: Theme.textGray
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Item { Layout.fillHeight: true } //spacer

                        // DYNAMIC ACTION BUTTON
                        Button {
                            Layout.fillWidth: true; Layout.preferredHeight: 36

                            background: Rectangle {
                                radius: 8
                                // Dark Gray for Admin, Pink for User
                                color: root.isAdminMode ? "#1f2937" : Theme.brandPink
                            }

                            contentItem: Text {
                                text: root.isAdminMode ? "✅ Aprobar" : "Ver Perfil"
                                color: "white"; font.bold: true; font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                if (root.isAdminMode) {
                                    happyTailsModel.insert(0, { "name": model.name, "imageSource": model.imageSource });
                                    availablePetsModel.remove(index);
                                } else {
                                     root.openPetProfile(model)
                                }
                            }
                        }
                    }
                }
            }
        }

        // HISTORY
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 130; color: "white"
            Rectangle { width: parent.width; height: 1; color: Theme.separatorColor; anchors.top: parent.top }

            // IMPORTANT TO FIX THIS VIEW, SINCE ITS GETTING CUT, AND ICON
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 10
                Text { text: "HISTORIAS FELICES"; font.bold: true; font.pixelSize: 11; color: Theme.textGray }

                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true; orientation: ListView.Horizontal; spacing: 15; clip: true
                    model: happyTailsModel
                    delegate: Column {
                        spacing: 5
                        Rectangle {
                            width: 60; height: 60; radius: 30; color: "#f3f4f6"; border.color: "#4ade80"; border.width: 2; clip: true
                            Image { anchors.fill: parent; source: model.imageSource !== "" ? model.imageSource : ""; fillMode: Image.PreserveAspectCrop; visible: model.imageSource !== "" }
                            Text { visible: model.imageSource === ""; text: "🏠"; anchors.centerIn: parent; font.pixelSize: 20 }
                        }
                        Text {
                            text: model.name
                            width: 60
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.textDark
                        }
                    }
                }
            }
        }
    }

    // Floating Action Button -> Visible only in Admin Mode
    ToolButton {
        visible: root.isAdminMode
        z: 50

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        width: 56; height: 56

        display: AbstractButton.IconOnly

        icon.source: "qrc:/qt/qml/GuardianAnimal/icons/addIcon.png" //->MODIFY ICON
        icon.color: "#ffffff"
        icon.width: 24; icon.height: 24

        background: Rectangle {
            radius: 28
            color: Theme.brandPink
            // Optional shadow
            layer.enabled: true
        }

        onClicked: addPetPopup.open()
    }

    // POPUPS
    AddPetPopup {
        id: addPetPopup
        onPetAdded: (name, type, ageVal, ageUnit, sex, isSpayed, location, address, email, phone, images) => {
            var jsonImages = JSON.stringify(images)
            var mainImage = images.length > 0 ? images[0].toString() : ""

            availablePetsModel.insert(0, {
                "name": name, "type": type, "age": ageVal + " " + ageUnit,
                "location": location, "distance": "0.1 km", "requests": 0,
                "imagesJson": jsonImages,
                "imageSource": mainImage,
                "color1": "#eee", "color2": "#ddd", "color3": "#ccc"
            })
        }
    }

    AdoptionFilter { id: filterModal }
}
