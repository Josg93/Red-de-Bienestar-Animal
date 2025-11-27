import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Popup {
    id: root

    signal petAdded(
        string name,
        string type,
        string ageVal,
        string ageUnit,
        string sex,
        bool isSpayed,
        string shelterName,
        string description,
        string phone,
        string email,
        var images
    )

    signal petUpdated(
        string id,
        string name,
        string type,
        string age,
        string shelterName,
        string description,
        string phone,
        string email,
        var images
    )

    property bool isEditMode: false
    property string editId: ""
    property var selectedImages: []

    // form validations: name + shelter + phone required; email optional-but-valid.
    readonly property bool isFormValid: {
        // During component construction, these ids are not ready yet
        if (typeof nameField === "undefined" ||
            typeof shelterNameField === "undefined" ||
            typeof phoneField === "undefined" ||
            typeof emailField === "undefined") {
            return false
        }

        return nameField.text.trim() !== "" &&
               shelterNameField.text.trim() !== "" &&
               phoneField.text.trim() !== "" && phoneField.acceptableInput &&
               (emailField.text.trim() === "" || emailField.acceptableInput)
    }



    function openForAdd() {
        isEditMode = false
        editId = ""
        nameField.text = ""
        ageField.text = ""
        shelterNameField.text = ""
        descField.text = ""
        phoneField.text = ""
        emailField.text = ""
        root.selectedImages = []
        spayedCheck.checked = false
        typeCombo.currentIndex = 0
        sexCombo.currentIndex = 0
        ageUnitCombo.currentIndex = 0
        root.open()
    }

    function openForEdit(data) {
        isEditMode = true
        editId = data.id || ""
        nameField.text = data.name || ""

        // Restore age number + unit
        ageField.text = ""
        ageUnitCombo.currentIndex = 0
        if (data.age) {
            var parts = data.age.split(" ")
            ageField.text = parts[0] || ""
            var unit = parts[1] || ""
            var unitIndex = ageUnitCombo.model.indexOf(unit)
            if (unitIndex >= 0)
                ageUnitCombo.currentIndex = unitIndex
        }

        shelterNameField.text = data.location || ""
        descField.text = data.description || ""

        // Restore TYPE combobox ("Perro"/"Gato"/"Otro" against ["🐕 Perro", ...])
        typeCombo.currentIndex = 0
        if (data.type) {
            for (var i = 0; i < typeCombo.model.length; ++i) {
                var entry = typeCombo.model[i].toString()
                if (entry.indexOf(data.type) !== -1) {
                    typeCombo.currentIndex = i
                    break
                }
            }
        }

        // Contact info (if already provided from getAnimalDetails)
        phoneField.text = data.contactPhone || ""
        emailField.text = data.contactEmail || ""

        // Load existing images array
        if (data.images && data.images.length > 0) {
            root.selectedImages = data.images
        } else if (data.imageSource && data.imageSource !== "") {
            root.selectedImages = [data.imageSource]
        } else {
            root.selectedImages = []
        }

        console.log("Edit mode - loaded", root.selectedImages.length, "images")
        root.open()
    }

    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.95, 450)
    height: Math.min(parent.height * 0.92, 700)
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Theme.bgWhite
        radius: 16
        border.color: Theme.separatorColor
        border.width: 1
    }

    FileDialog {
        id: fileDialog
        title: "Seleccionar fotos"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Image files (*.jpg *.png *.jpeg *.heic)"]
        onAccepted: {
            var current = root.selectedImages
            for (var i = 0; i < selectedFiles.length; i++) {
                current.push(selectedFiles[i].toString())
            }
            root.selectedImages = [].concat(current)
            console.log("Added images, total:", root.selectedImages.length)
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

            // HEADER
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Rectangle {
                    width: 40; height: 40; radius: 20
                    color: "#fce7f3"
                    Text { anchors.centerIn: parent; text: root.isEditMode ? "✎" : "🐾"; font.pixelSize: 20 }
                }
                ColumnLayout {
                    spacing: 2
                    Text {
                        text: root.isEditMode ? "Editar Perfil" : "Nuevo Ingreso"
                        font.bold: true; font.pixelSize: 20; color: Theme.textDark
                    }
                    Text {
                        text: root.isEditMode ? "Modificar datos existentes" : "Completa la información"
                        font.pixelSize: 13; color: Theme.textGray
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "✕"; font.pixelSize: 24; color: Theme.textGray
                    MouseArea { anchors.fill: parent; onClicked: root.close() }
                }
            }

            // FIELDS
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                StyledTextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Nombre de la mascota *"
                    iconText: "🏷️"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    StyledComboBox {
                        id: typeCombo
                        Layout.fillWidth: true
                        model: ["🐕 Perro", "🐈 Gato", "🦜 Otro"]
                    }
                    StyledComboBox {
                        id: sexCombo
                        Layout.fillWidth: true
                        model: ["♂ Macho", "♀ Hembra"]
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    StyledTextField {
                        id: ageField
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        placeholderText: "Edad *"
                        inputMethodHints: Qt.ImhDigitsOnly
                    }
                    StyledComboBox {
                        id: ageUnitCombo
                        Layout.fillWidth: true
                        Layout.preferredWidth: 2
                        model: ["Años", "Meses", "Semanas"]
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 50
                    radius: 10
                    color: spayedCheck.checked ? "#fce7f3" : "#f9fafb"
                    border.color: spayedCheck.checked ? Theme.brandPink : "#e5e7eb"
                    border.width: 2

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12
                        Text { text: "✓"; font.pixelSize: 18; color: Theme.brandPink }
                        CheckBox {
                            id: spayedCheck
                            text: "Esterilizado / Castrado"
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 10
                    border.color: descField.activeFocus ? Theme.brandPink : "#e5e7eb"
                    border.width: 2
                    color: "#f9fafb"

                    TextArea {
                        id: descField
                        placeholderText: "Descripción..."
                        wrapMode: TextArea.Wrap
                        font.pixelSize: 14
                        color: Theme.textDark
                        background: null
                        anchors.fill: parent
                        anchors.margins: 10
                    }
                }

                StyledTextField {
                    id: shelterNameField
                    Layout.fillWidth: true
                    placeholderText: "Nombre del Refugio *"
                    iconText: "🏠"
                }

                // Venezuelan regex
                StyledTextField {
                    id: phoneField
                    Layout.fillWidth: true
                    placeholderText: "Teléfono (Venezuela) *"
                    iconText: "📞"
                    inputMethodHints: Qt.ImhDialableCharactersOnly

                    validator: RegularExpressionValidator  {
                        // 0 + 10 digits, e.g., 04141234567, 02125551234
                        regularExpression: /^042((?:[246]+)(?:1[2456]))$/
                    }
                }

                // email is optional
                StyledTextField {
                    id: emailField
                    Layout.fillWidth: true
                    placeholderText: "Correo electrónico (opcional)"
                    iconText: "✉️"
                    inputMethodHints: Qt.ImhEmailCharactersOnly

                    validator: RegularExpressionValidator  {
                        regularExpression: /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
                    }
                }

                Text {
                    text: "📍 La ubicación GPS se capturará automáticamente"
                    font.pixelSize: 11
                    color: Theme.textGray
                    font.italic: true
                }
            }

            // IMAGES
            ColumnLayout {
                spacing: 8
                Text {
                    text: "FOTOS (" + root.selectedImages.length + ")"
                    font.bold: true; font.pixelSize: 11; color: Theme.textGray
                }
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    contentHeight: 100
                    clip: true

                    Row {
                        spacing: 10
                        Rectangle {
                            width: 100; height: 100; radius: 12
                            color: "#f3f4f6"
                            border.color: "#d1d5db"
                            border.width: 1
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📷"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Añadir"; font.pixelSize: 12; color: Theme.textGray; Layout.alignment: Qt.AlignHCenter }
                            }
                            MouseArea { anchors.fill: parent; onClicked: fileDialog.open() }
                        }
                        Repeater {
                            model: root.selectedImages
                            delegate: Rectangle {
                                width: 100; height: 100; radius: 12
                                color: "#f3f4f6"; clip: true
                                Image {
                                    anchors.fill: parent
                                    source: modelData
                                    fillMode: Image.PreserveAspectCrop
                                }
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 4
                                    width: 24; height: 24; radius: 12
                                    color: "white"
                                    Text { anchors.centerIn: parent; text: "✕"; color: "red"; font.bold: true }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: {
                                            var list = root.selectedImages
                                            list.splice(index, 1)
                                            root.selectedImages = [].concat(list)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ACTION BUTTONS
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 50
                    background: Rectangle { color: "#f3f4f6"; radius: 12 }
                    contentItem: Text {
                        text: "Cancelar"
                        color: Theme.textGray; font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.close()
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    Layout.preferredHeight: 50
                    enabled: root.isFormValid
                    background: Rectangle {
                        color: parent.enabled ? Theme.brandPink : "#d1d5db"
                        radius: 12
                    }
                    contentItem: Text {
                        text: root.isEditMode ? "Guardar Cambios" : "Crear Perfil"
                        color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var cleanType = typeCombo.currentText.replace(/[^\w\s]/gi, '').trim()
                        var cleanSex = sexCombo.currentText.replace(/[^\w\s]/gi, '').trim()
                        var fullAge = ageField.text + " " + ageUnitCombo.currentText

                        var description = descField.text.trim()
                        if (description === "")
                            description = "Sin descripción disponible"

                        var phone = phoneField.text.trim()
                        var email = emailField.text.trim()

                        console.log("Saving with description:", description)
                        console.log("Saving with", root.selectedImages.length, "images")

                        if (root.isEditMode) {
                            root.petUpdated(
                                root.editId,
                                nameField.text,
                                cleanType,
                                fullAge,
                                shelterNameField.text,
                                description,
                                phone,
                                email,
                                root.selectedImages
                            )
                        } else {
                            root.petAdded(
                                nameField.text,
                                cleanType,
                                ageField.text,
                                ageUnitCombo.currentText,
                                cleanSex,
                                spayedCheck.checked,
                                shelterNameField.text,
                                description,
                                phone,
                                email,
                                root.selectedImages
                            )
                        }
                        root.close()
                    }
                }
            }
        }
    }

    // Styled components
    component StyledTextField: Rectangle {
        id: textFieldRoot
        property alias text: innerField.text
        property alias placeholderText: innerField.placeholderText
        property alias inputMethodHints: innerField.inputMethodHints
        property alias validator: innerField.validator   // expose validator
        property alias acceptableInput: innerField.acceptableInput
        property string iconText: ""

        implicitHeight: 50
        radius: 10
        color: "#f9fafb"
        border.color: innerField.activeFocus ? Theme.brandPink : "#e5e7eb"
        border.width: 2

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10
            Text {
                text: textFieldRoot.iconText
                font.pixelSize: 18
                visible: textFieldRoot.iconText !== ""
            }
            TextField {
                id: innerField
                Layout.fillWidth: true
                font.pixelSize: 14
                color: Theme.textDark
                background: null
                verticalAlignment: TextInput.AlignVCenter
            }
        }
    }

    component StyledComboBox: ComboBox {
        id: comboRoot
        implicitHeight: 50
        background: Rectangle {
            radius: 10
            color: "#f9fafb"
            border.color: comboRoot.pressed ? Theme.brandPink : "#e5e7eb"
            border.width: 2
        }
        contentItem: Text {
            leftPadding: 14
            rightPadding: 44
            text: comboRoot.displayText
            font.pixelSize: 14
            color: Theme.textDark
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
        delegate: ItemDelegate {
            width: comboRoot.width
            height: 44
            contentItem: Text {
                text: modelData
                color: Theme.textDark
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                leftPadding: 14
            }
            background: Rectangle {
                radius: 8
                color: parent.highlighted ? "#fce7f3" : "transparent"
            }
        }
        popup: Popup {
            y: comboRoot.height + 4
            width: comboRoot.width
            implicitHeight: contentItem.implicitHeight
            padding: 4
            contentItem: ListView {
                clip: true
                implicitHeight: contentHeight
                model: comboRoot.popup.visible ? comboRoot.delegateModel : null
                currentIndex: comboRoot.highlightedIndex
            }
            background: Rectangle {
                color: "white"
                border.color: "#e5e7eb"
                radius: 10
            }
        }
    }
}

