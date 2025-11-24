import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import GuardianAnimal

Popup {
    id: root

    // SIGNAL UPDATE: 'images' is now an array of strings
    signal petAdded(
        string name,
        string type,
        string ageVal, string ageUnit,
        string sex, bool isSpayed,
        string location,
        string address, string email, string phone,
        var images // array of strings (var)
    )

    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.95, 450)
    height: Math.min(parent.height * 0.92, 700)
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    // INTERNAL STATE: Array of selected image paths
    property var selectedImages: []

    readonly property bool isFormValid:
        nameField.text.trim() !== "" &&
        ageField.text.trim() !== "" &&
        locField.text.trim() !== "" &&
        addressField.text.trim() !== "" &&
        emailField.text.trim() !== "" &&
        phoneField.text.trim() !== ""

    background: Rectangle {
        color: Theme.bgWhite; radius: 16; border.color: Theme.separatorColor; border.width: 1
    }

    FileDialog {
        id: fileDialog
        title: "Seleccionar fotos"
        // ENABLE MULTIPLE SELECTION
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Image files (*.jpg *.png *.jpeg *.heic)"]
        onAccepted: {
            // Append new files to existing array
            // We create a new array reference to trigger QML bindings updates
            var current = root.selectedImages
            for (var i = 0; i < selectedFiles.length; i++) {
                current.push(selectedFiles[i].toString())
            }
            root.selectedImages = [].concat(current) // Force update
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 20
        contentHeight: formColumn.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: formColumn
            width: parent.width
            spacing: 16

            // --- HEADER ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle { width: 40; height: 40; radius: 20; color: "#fce7f3"; Text { anchors.centerIn: parent; text: "🐾"; font.pixelSize: 20 } }
                ColumnLayout { spacing: 2; Text { text: "Nuevo Ingreso"; font.bold: true; font.pixelSize: 20; color: Theme.textDark } Text { text: "Completa la información"; font.pixelSize: 13; color: Theme.textGray } }
                Item { Layout.fillWidth: true }
                Text { text: "✕"; font.pixelSize: 24; color: Theme.textGray; MouseArea { anchors.fill: parent; onClicked: root.close() } }
            }

            // --- INFO FIELDS ---
            ColumnLayout {
                Layout.fillWidth: true; spacing: 12
                Text { text: "INFORMACIÓN BÁSICA"; font.bold: true; font.pixelSize: 11; color: Theme.textGray; font.letterSpacing: 0.5 }
                StyledTextField { id: nameField; Layout.fillWidth: true; placeholderText: "Nombre de la mascota *"; iconText: "🏷️" }
                RowLayout {
                    Layout.fillWidth: true; spacing: 12
                    StyledComboBox { id: typeCombo; Layout.fillWidth: true; model: ["🐕 Perro", "🐈 Gato", "🦜 Otro"] }
                    StyledComboBox { id: sexCombo; Layout.fillWidth: true; model: ["♂ Macho", "♀ Hembra"] }
                }
                RowLayout {
                    Layout.fillWidth: true; spacing: 12
                    StyledTextField { id: ageField; Layout.fillWidth: true; Layout.preferredWidth: 1; placeholderText: "Edad *"; inputMethodHints: Qt.ImhDigitsOnly }
                    StyledComboBox { id: ageUnitCombo; Layout.fillWidth: true; Layout.preferredWidth: 2; model: ["Años", "Meses", "Semanas"] }
                }
                // Spayed Checkbox
                Rectangle {
                    Layout.fillWidth: true; height: 50; radius: 10; color: spayedCheck.checked ? "#fce7f3" : "#f9fafb"; border.color: spayedCheck.checked ? Theme.brandPink : "#e5e7eb"; border.width: 2
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 12
                        Text { text: "✓"; font.pixelSize: 18; color: Theme.brandPink }
                        CheckBox { id: spayedCheck; text: "Esterilizado / Castrado"; font.pixelSize: 14; Layout.fillWidth: true; indicator: Rectangle { implicitWidth: 22; implicitHeight: 22; x: spayedCheck.leftPadding; y: parent.height/2-height/2; radius: 4; border.color: spayedCheck.checked ? Theme.brandPink : "#d1d5db"; border.width: 2; color: spayedCheck.checked ? Theme.brandPink : "transparent"; Text { anchors.centerIn: parent; text: "✓"; color: "white"; font.pixelSize: 14; font.bold: true; visible: spayedCheck.checked } } }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 10; border.color: descField.activeFocus ? Theme.brandPink : "#e5e7eb"; border.width: 2; color: "#f9fafb"
                    TextArea { id: descField; placeholderText: "Descripción: Historia, temperamento..."; wrapMode: TextArea.Wrap; font.pixelSize: 14; color: Theme.textDark; background: null; anchors.fill: parent; anchors.margins: 10 }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.separatorColor; Layout.margins: 8 }

            // --- CONTACT INFO ---
            ColumnLayout {
                Layout.fillWidth: true; spacing: 12
                Text { text: "UBICACIÓN Y CONTACTO"; font.bold: true; font.pixelSize: 11; color: Theme.textGray; font.letterSpacing: 0.5 }
                StyledTextField { id: locField; Layout.fillWidth: true; placeholderText: "Nombre del lugar / refugio *"; iconText: "📍" }
                StyledTextField { id: addressField; Layout.fillWidth: true; placeholderText: "Dirección exacta *"; iconText: "🏠" }
                RowLayout {
                    Layout.fillWidth: true; spacing: 12
                    StyledTextField { id: phoneField; Layout.fillWidth: true; placeholderText: "Teléfono *"; iconText: "📞"; inputMethodHints: Qt.ImhDialableCharactersOnly }
                    StyledTextField { id: emailField; Layout.fillWidth: true; placeholderText: "Email *"; iconText: "✉️"; inputMethodHints: Qt.ImhEmailCharactersOnly }
                }
            }

            // --- MULTI-IMAGE UPLOAD SECTION ---
            ColumnLayout {
                spacing: 8
                Text { text: "GALERÍA DE FOTOS"; font.bold: true; font.pixelSize: 11; color: Theme.textGray; font.letterSpacing: 0.5 }

                // Horizontal list of images
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    contentHeight: 100
                    clip: true

                    Row {
                        spacing: 10

                        // 1. Add Button (Always first)
                        Rectangle {
                            width: 100; height: 100; radius: 12
                            color: "#f3f4f6"; border.color: "#d1d5db"; border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent; spacing: 4
                                Text { text: "📷"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Añadir"; font.pixelSize: 12; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }
                            }
                            MouseArea { anchors.fill: parent; onClicked: fileDialog.open() }
                        }

                        // 2. List of Selected Thumbnails
                        Repeater {
                            model: root.selectedImages
                            delegate: Rectangle {
                                width: 100; height: 100; radius: 12; color: "#f3f4f6"; clip: true
                                border.color: "#e5e7eb"; border.width: 1

                                Image {
                                    anchors.fill: parent
                                    source: modelData // The path string
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                // Remove Button (X)
                                Rectangle {
                                    anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 4
                                    width: 24; height: 24; radius: 12; color: "white"
                                    Text { anchors.centerIn: parent; text: "✕"; color: "red"; font.bold: true; font.pixelSize: 12 }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            var list = root.selectedImages
                                            list.splice(index, 1) // Remove item
                                            root.selectedImages = [].concat(list) // Force update
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: root.selectedImages.length === 0
                    text: "Sube al menos una foto (Max 10MB)"
                    font.pixelSize: 11
                    color: Theme.textGray
                }
            }

            // --- ACTION BUTTONS ---
            RowLayout {
                Layout.fillWidth: true; Layout.topMargin: 8; spacing: 12
                Button {
                    Layout.fillWidth: true; Layout.preferredWidth: 1; Layout.preferredHeight: 50
                    background: Rectangle { color: parent.pressed ? "#e5e7eb" : "#f3f4f6"; radius: 12; border.color: "#d1d5db"; border.width: 1 }
                    contentItem: Text { text: "Cancelar"; color: Theme.textGray; font.bold: true; font.pixelSize: 15; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: root.close()
                }
                Button {
                    Layout.fillWidth: true; Layout.preferredWidth: 2; Layout.preferredHeight: 50
                    enabled: root.isFormValid
                    background: Rectangle { color: parent.enabled ? (parent.pressed ? "#ec4899" : Theme.brandPink) : "#d1d5db"; radius: 12; Behavior on color { ColorAnimation { duration: 200 } } }
                    contentItem: Row {
                        spacing: 8; anchors.centerIn: parent
                        Text { text: "✓"; color: "white"; font.pixelSize: 18; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Guardar Perfil"; color: "white"; font.bold: true; font.pixelSize: 15; anchors.verticalCenter: parent.verticalCenter }
                    }
                    onClicked: {
                        var cleanType = typeCombo.currentText.replace(/[^\w\s]/gi, '').trim()
                        var cleanSex = sexCombo.currentText.replace(/[^\w\s]/gi, '').trim()

                        root.petAdded(
                            nameField.text, cleanType, ageField.text, ageUnitCombo.currentText,
                            cleanSex, spayedCheck.checked, locField.text, addressField.text,
                            emailField.text, phoneField.text, root.selectedImages // Pass array
                        )

                        // Clean up
                        nameField.text = ""; ageField.text = ""; locField.text = ""; addressField.text = ""; emailField.text = ""; phoneField.text = ""; descField.text = ""; root.selectedImages = []; spayedCheck.checked = false
                        root.close()
                    }
                }
            }
        }
    }
    // Custom components (StyledTextField, StyledComboBox)
    component StyledTextField: Rectangle {
        id: textFieldRoot
        property alias text: innerField.text
        property alias placeholderText: innerField.placeholderText
        property alias inputMethodHints: innerField.inputMethodHints
        property string iconText: ""
        readonly property bool isFocused: innerField.activeFocus
        implicitWidth: 200; implicitHeight: 50
        radius: 10; color: "#f9fafb"; border.color: innerField.activeFocus ? Theme.brandPink : "#e5e7eb"; border.width: 2
        Behavior on border.color { ColorAnimation { duration: 200 } }
        RowLayout {
            anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14; spacing: 10
            Text { text: textFieldRoot.iconText; font.pixelSize: 18; visible: textFieldRoot.iconText !== "" }
            TextField { id: innerField; Layout.fillWidth: true; font.pixelSize: 14; color: Theme.textDark; placeholderTextColor: Theme.textGray; background: null; verticalAlignment: TextInput.AlignVCenter }
        }
    }
    component StyledComboBox: ComboBox {
        id: comboRoot
        implicitWidth: 200; implicitHeight: 50
        background: Rectangle { radius: 10; color: "#f9fafb"; border.color: comboRoot.pressed ? Theme.brandPink : "#e5e7eb"; border.width: 2; Behavior on border.color { ColorAnimation { duration: 200 } } }
        contentItem: Text { leftPadding: 14; rightPadding: 44; text: comboRoot.displayText; font.pixelSize: 14; color: Theme.textDark; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
        delegate: ItemDelegate {
            width: comboRoot.width; height: 44
            contentItem: Text { text: modelData; color: Theme.textDark; font.pixelSize: 14; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter; leftPadding: 14 }
            background: Rectangle { radius: 8; color: parent.highlighted ? "#fce7f3" : "transparent" }
        }
        popup: Popup {
            y: comboRoot.height + 4; width: comboRoot.width; implicitHeight: contentItem.implicitHeight; padding: 4
            contentItem: ListView { clip: true; implicitHeight: contentHeight; model: comboRoot.popup.visible ? comboRoot.delegateModel : null; currentIndex: comboRoot.highlightedIndex; ScrollIndicator.vertical: ScrollIndicator { } }
            background: Rectangle { color: "white"; border.color: "#e5e7eb"; radius: 10 }
        }
    }
}

