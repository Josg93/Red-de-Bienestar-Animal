import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import GuardianAnimal
import ApplicationViews
import Popups
import Start

Popup {
    id: root

    property string currentSpecies: "Todos"
    property string currentRadius: "Todo" // "Todo", "5", "10"

    signal filtersApplied()

    parent: Overlay.overlay
    x: 0
    y: parent.height - height
    width: parent.width
    height: 500

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "y"; from: parent.height; to: parent.height - 500; duration: 300; easing.type: Easing.OutCubic } }
    exit: Transition { NumberAnimation { property: "y"; from: parent.height - 500; to: parent.height; duration: 300; easing.type: Easing.InCubic } }

    background: Rectangle {
        color: Theme.bgWhite
        radius: 20
        Rectangle { width: parent.width; height: 20; color: Theme.bgWhite; anchors.bottom: parent.bottom }
    }

    component FilterChip: Button {
        id: chip
        required property string groupValue
        required property string value
        signal selectMe(string val)
        Layout.fillWidth: true; height: 40
        property bool isSelected: chip.groupValue === chip.value

        background: Rectangle {
            color: chip.isSelected ? "#fce7f3" : Theme.bgWhite
            border.color: chip.isSelected ? Theme.brandPink : "#e5e7eb"
            border.width: 2
            radius: 8
        }
        contentItem: Text {
            text: chip.text
            color: chip.isSelected ? Theme.brandPink : Theme.textGray
            font.bold: true; font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        onClicked: chip.selectMe(chip.value)
    }

    component SectionTitle: Text { font.bold: true; font.pixelSize: 10; color: Theme.textGray; font.capitalization: Font.AllUppercase }

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 20

        // Header
        RowLayout {
            Layout.fillWidth: true
            Text { text: "Filtrar Adopciones"; font.bold: true; font.pixelSize: 18; color: Theme.textDark }
            Item { Layout.fillWidth: true }
            Text { text: "✕"; font.bold: true; font.pixelSize: 18; color: Theme.textGray; MouseArea { anchors.fill: parent; onClicked: root.close() } }
        }

        // 1. RADIO DE BÚSQUEDA
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Radio de Búsqueda" }
            RowLayout {
                spacing: 10
                FilterChip { text: "5 km"; value: "5"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                FilterChip { text: "10 km"; value: "10"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                FilterChip { text: "20 km"; value: "20"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                FilterChip { text: "Todo"; value: "Todo"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
            }
        }

        // 2. ESPECIE
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Especie" }
            RowLayout {
                spacing: 10
                FilterChip { text: "Todos"; value: "Todos"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }
                FilterChip { text: "Perro"; value: "Perro"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }
                FilterChip { text: "Gato"; value: "Gato"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }
            }
        }

        Item { Layout.fillHeight: true }

        // Footer
        RowLayout {
            Layout.fillWidth: true; spacing: 10
            Button {
                Layout.preferredWidth: parent.width * 0.3; height: 45
                background: Rectangle { color: "#f3f4f6"; radius: 12 }
                contentItem: Text { text: "Limpiar"; color: Theme.textGray; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    root.currentSpecies = "Todos"
                    root.currentRadius = "Todo"
                    backend.setSpeciesFilter("Todos")
                    backend.setSearchQuery("")
                }

            }
            Button {
                Layout.fillWidth: true; height: 45
                background: Rectangle { color: Theme.brandPink; radius: 12 }
                contentItem: Text {
                    text: "Aplicar Filtros"
                    color: "white"; font.bold: true;
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    console.log("Applying filters - Radius:", root.currentRadius, "Species:", root.currentSpecies)

                    // 1) Radius filter → backend
                    if (root.currentRadius === "Todo") {
                        backend.setFilterByRadius(false)   // KNN mode
                    } else {
                        var km = parseInt(root.currentRadius)
                        backend.setSearchRadius(km)
                        backend.setFilterByRadius(true)    // strict radius mode
                    }

                    // 2) Species filter → backend
                    backend.setSpeciesFilter(root.currentSpecies)

                    root.filtersApplied()
                    root.close()
                }
            }

        }
    }
}
