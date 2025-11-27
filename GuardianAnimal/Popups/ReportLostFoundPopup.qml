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

    signal reportAdded(string status, string name, string type, string breed,
                       string date, string location, string contact, var images)

    property string reportType: "lost"
    property var selectedImages: []

    readonly property bool isFormValid: {
        // 1. Safety Check: Are the inputs loaded?
        if (!locField || !contactField || !dateField) return false

        // 2. Logic Check: Do they have text?
        return locField.text.trim() !== "" &&
               contactField.text.trim() !== "" &&
               dateField.text.trim() !== ""
    }

    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: Math.min(parent.width * 0.95, 450)
    height: Math.min(parent.height * 0.92, 750)
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: Theme.bgWhite
        radius: 16
        border.color: Theme.separatorColor
        border.width: 1
    }

    onOpened: {
        nameField.text = ""
        breedField.text = ""
        dateField.text = ""
        locField.text = ""
        contactField.text = ""
        root.selectedImages = []
    }

    FileDialog {
        id: fileDialog
        title: "Evidencia Fotográfica"
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Image files (*.jpg *.png *.jpeg *.heic)"]
        onAccepted: {
            var current = root.selectedImages
            for (var i = 0; i < selectedFiles.length; ++i)
                current.push(selectedFiles[i].toString())
            root.selectedImages = [].concat(current)
        }
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: 20
        contentHeight: formColumn.height + 20
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
                    width: 40
                    height: 40
                    radius: 20
                    color: root.reportType === "lost" ? "#fee2e2" : "#d1fae5"
                    Text {
                        anchors.centerIn: parent
                        text: root.reportType === "lost" ? "📢" : "👀"
                        font.pixelSize: 20
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Reportar Caso"
                        font.bold: true
                        font.pixelSize: 20
                        color: Theme.textDark
                    }
                    Text {
                        text: root.reportType === "lost"
                              ? "Mi mascota se perdió"
                              : "Encontré/Vi una mascota"
                        font.pixelSize: 13
                        color: Theme.textGray
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "✕"
                    font.pixelSize: 24
                    color: Theme.textGray
                    MouseArea { anchors.fill: parent; onClicked: root.close() }
                }
            }

            // STATUS TOGGLE
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    background: Rectangle {
                        color: root.reportType === "lost" ? "#dc2626" : "#f3f4f6"
                        radius: 10
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: "PERDIDO"
                        color: root.reportType === "lost" ? "white" : Theme.textGray
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.reportType = "lost"
                }

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    background: Rectangle {
                        color: root.reportType === "found" ? "#059669" : "#f3f4f6"
                        radius: 10
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                    contentItem: Text {
                        text: "ENCONTRADO"
                        color: root.reportType === "found" ? "white" : Theme.textGray
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: root.reportType = "found"
                }
            }

            // FORM FIELDS
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "DETALLES"
                    font.bold: true
                    font.pixelSize: 11
                    color: Theme.textGray
                    font.letterSpacing: 0.5
                }

                StyledTextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: root.reportType === "lost"
                                     ? "Nombre de la mascota *"
                                     : "Nombre (si tiene placa)"
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

                    StyledTextField {
                        id: breedField
                        Layout.fillWidth: true
                        placeholderText: "Raza / Color predominante"
                    }
                }

                StyledTextField {
                    id: dateField
                    Layout.fillWidth: true
                    placeholderText: "Fecha y Hora (Ej. Ayer 2pm) *"
                    iconText: "📅"
                }

                StyledTextField {
                    id: locField
                    Layout.fillWidth: true
                    placeholderText: root.reportType === "lost"
                                     ? "Última vez visto en... *"
                                     : "Encontrado en... *"
                    iconText: "📍"
                }

                StyledTextField {
                    id: contactField
                    Layout.fillWidth: true
                    placeholderText: "Teléfono de Contacto *"
                    iconText: "📞"
                    inputMethodHints: Qt.ImhDialableCharactersOnly

                    validator: RegularExpressionValidator  {
                        regularExpression: /^0\d{10}$/
                    }
                }
            }

            // IMAGES
            ColumnLayout {
                spacing: 8

                Text {
                    text: "EVIDENCIA (" + root.selectedImages.length + ")"
                    font.bold: true
                    font.pixelSize: 11
                    color: Theme.textGray
                    font.letterSpacing: 0.5
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 100
                    contentHeight: 100
                    clip: true

                    Row {
                        spacing: 10

                        Rectangle {
                            width: 100
                            height: 100
                            radius: 12
                            color: "#f3f4f6"
                            border.color: "#d1d5db"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Text { text: "📷"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Añadir"; font.pixelSize: 12; color: Theme.textGray }
                            }

                            MouseArea { anchors.fill: parent; onClicked: fileDialog.open() }
                        }

                        Repeater {
                            model: root.selectedImages
                            delegate: Rectangle {
                                width: 100
                                height: 100
                                radius: 12
                                color: "#f3f4f6"
                                clip: true
                                border.color: "#e5e7eb"
                                border.width: 1

                                Image {
                                    anchors.fill: parent
                                    source: modelData
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }

                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 4
                                    width: 24
                                    height: 24
                                    radius: 12
                                    color: "white"
                                    Text {
                                        anchors.centerIn: parent
                                        text: "✕"
                                        color: "red"
                                        font.bold: true
                                        font.pixelSize: 12
                                    }
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
                Layout.topMargin: 10
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.preferredHeight: 50
                    background: Rectangle { color: "#f3f4f6"; radius: 12 }
                    contentItem: Text {
                        text: "Cancelar"
                        color: Theme.textGray
                        font.bold: true
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
                        color: parent.enabled
                               ? (root.reportType === "lost" ? "#dc2626" : "#059669")
                               : "#d1d5db"
                        radius: 12
                    }

                    contentItem: Text {
                        text: "Publicar Reporte"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        var cleanType = typeCombo.currentText.replace(/[^\w\s]/gi, "").trim()
                        root.reportAdded(
                                    root.reportType,
                                    nameField.text,
                                    cleanType,
                                    breedField.text,
                                    dateField.text,
                                    locField.text,
                                    contactField.text,
                                    root.selectedImages)
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
        property alias validator: innerField.validator
        property string iconText: ""

        implicitWidth: 200
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
                placeholderTextColor: Theme.textGray
                background: null
                verticalAlignment: TextInput.AlignVCenter
            }
        }
    }

    component StyledComboBox: ComboBox {
        id: comboRoot
        implicitWidth: 200
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
                ScrollIndicator.vertical: ScrollIndicator { }
            }

            background: Rectangle {
                color: "white"
                border.color: "#e5e7eb"
                radius: 10
            }
        }
    }
}
