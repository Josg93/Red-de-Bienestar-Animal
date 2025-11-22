import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

Popup {
    id: root

    // Properties to hold selected filter state
    property string currentSpecies: "Perro"
    property string currentRadius: "10 km"
    property string currentBreed: "Mestizo"

    // Age Logic
    property string ageNumber: ""
    property string ageUnit: "Años"

    parent: Overlay.overlay
    x: 0
    y: parent.height - height
    width: parent.width
    height: 550

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    enter: Transition { NumberAnimation { property: "y"; from: parent.height; to: parent.height - 550; duration: 300; easing.type: Easing.OutCubic } }
    exit: Transition { NumberAnimation { property: "y"; from: parent.height - 550; to: parent.height; duration: 300; easing.type: Easing.InCubic } }

    background: Rectangle {
        color: Theme.bgWhite
        radius: 20
        Rectangle { width: parent.width; height: 20; color: Theme.bgWhite; anchors.bottom: parent.bottom }
    }

    // Chip Component for Selections
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

        // 1. ESPECIE (Selection)
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Especie" }
            RowLayout {
                spacing: 10
                FilterChip { text: "🐕 Perro"; value: "Perro"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }
                FilterChip { text: "🐈 Gato"; value: "Gato"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }
                FilterChip { text: "Otro"; value: "Otro"; groupValue: root.currentSpecies; onSelectMe: (v)=>root.currentSpecies=v }

            }
        }

        // 2. EDAD (Number Input + Unit Selection)
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Edad Máxima" }
            RowLayout {
                spacing: 10
                // Number Input
                TextField {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 40
                    placeholderText: "#"
                    text: root.ageNumber
                    onTextChanged: root.ageNumber = text
                    inputMethodHints: Qt.ImhDigitsOnly
                    background: Rectangle { radius: 8; color: "#f9fafb"; border.color: parent.activeFocus ? Theme.brandPink : "#e5e7eb"; border.width: 2 }
                }

                // Unit Selector (Chips)
                FilterChip { text: "Años"; value: "Años"; groupValue: root.ageUnit; onSelectMe: (v)=>root.ageUnit=v }
                FilterChip { text: "Meses"; value: "Meses"; groupValue: root.ageUnit; onSelectMe: (v)=>root.ageUnit=v }
            }
        }

        // 3. RADIO (Selection)
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Radio de Búsqueda" }
            RowLayout {
                spacing: 10
                FilterChip { text: "5 km"; value: "5 km"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                FilterChip { text: "10 km"; value: "10 km"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                FilterChip { text: "50 km"; value: "50 km"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
                //FilterChip { text: "Todo el país"; value: "Todo"; groupValue: root.currentRadius; onSelectMe: (v)=>root.currentRadius=v }
            }
        }

        // 4. RAZA (Selection)
        ColumnLayout {
            spacing: 8
            SectionTitle { text: "Raza" }
            RowLayout {
                spacing: 10
                FilterChip { text: "Mestizo"; value: "Mestizo"; groupValue: root.currentBreed; onSelectMe: (v)=>root.currentBreed=v }
                FilterChip { text: "De Raza"; value: "De Raza"; groupValue: root.currentBreed; onSelectMe: (v)=>root.currentBreed=v }
            }
        }

        Item { Layout.fillHeight: true }

        // Footer Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Button {
                // FIX: Use ratio sizing
                Layout.fillWidth: true
                Layout.preferredWidth: 2 // Sets a ratio (2 parts, so it's wider)
                height: 45

                background: Rectangle { color: Theme.brandPink; radius: 12 }
                contentItem: Text { text: "Aplicar Filtros"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.close()
            }
        }
    }
}
