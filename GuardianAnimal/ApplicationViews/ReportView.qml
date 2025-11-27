import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import QtPositioning
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    // Signals
    signal caseReported(string type, string severity, string location, string description, string imageSource, var gps)
    signal cancelReport()

    // Properties
    property bool formUnlocked: false
    property string selectedImage: ""
    property string currentSeverity: "MEDIUM"
    property var currentCoordinates: null
    property var duplicateResults: []
    property bool showDuplicateDialog: false
    property bool usingGpsLocation: false    // location from GPS or fallback

    // Validation
    readonly property bool isFormValid: {
        if (typeof locField === "undefined" ||
            typeof descField === "undefined")
            return false

        return locField.text.trim() !== "" &&
               descField.text.trim() !== ""
    }

    // --- REAL GPS LOGIC WITH FALLBACK ---
    PositionSource {
        id: positionSource
        active: false
        updateInterval: 0  // we use update() for single-shot requests

        onPositionChanged: {
            var coord = position.coordinate
            if (coord && coord.isValid) {
                var lat = coord.latitude.toFixed(5)
                var lon = coord.longitude.toFixed(5)

                root.currentCoordinates = { lat: coord.latitude, lon: coord.longitude }
                locField.text = "Lat: " + lat + ", Lon: " + lon + " (Mi ubicación)"
                root.usingGpsLocation = true
                locField.readOnly = true
                active = false
                console.log("GPS fix:", lat, lon)
                return
            }
            useFallbackLocation()
        }

        onSourceErrorChanged: {
            if (sourceError !== PositionSource.NoError) {
                console.log("GPS error, using fallback. Error code:", sourceError)
                useFallbackLocation()
            }
        }
    }

    function useFallbackLocation() {
        root.currentCoordinates = { lat: 8.605, lon: -71.150 }
        locField.text = "Lat: 8.605, Lon: -71.150 (Ubicación por defecto)"
        root.usingGpsLocation = true
        locField.readOnly = true
        positionSource.active = false
    }

    function getGPSLocation() {
        root.usingGpsLocation = false
        locField.readOnly = true
        locField.text = "Buscando ubicación..."
        root.currentCoordinates = null

        if (!positionSource.active) {
            positionSource.update()   // request one position update
        }
    }

    FileDialog {
        id: fileDialog
        title: "Evidencia (Opcional)"
        nameFilters: ["Image files (*.jpg *.png)"]
        onAccepted: root.selectedImage = selectedFile
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Theme.backgroundColor
            z: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "#fee2e2"
                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/qt/qml/GuardianAnimal/icons/highPriority.svg"
                    }
                }

                Text {
                    text: "Reportar Emergencia"
                    font.bold: true
                    font.pixelSize: 20
                    color: Theme.textDark
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "✕"
                    font.pixelSize: 24
                    color: Theme.textGray
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.cancelReport()
                    }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentCol.height + 40
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 20

                Item { Layout.preferredHeight: 10 }

                // --- SECTION A: DUPLICATE CHECKER ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    implicitHeight: dupCheckInner.implicitHeight + 32
                    radius: 12
                    color: Theme.bgWhite
                    border.color: root.formUnlocked ? "#e5e7eb" : "#4f46e5"
                    border.width: 2

                    ColumnLayout {
                        id: dupCheckInner
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            Text { text: "📍"; font.pixelSize: 16 }
                            Text {
                                text: "Paso 1: Verificar Duplicados"
                                font.bold: true
                                font.pixelSize: 14
                                color: Theme.textDark
                            }
                        }

                        Text {
                            text: "El sistema buscará reportes similares cercanos."
                            font.pixelSize: 12
                            color: Theme.textGray
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            StyledComboBox {
                                id: checkType
                                Layout.fillWidth: true
                                model: ["Perro", "Gato", "Fauna Silvestre"]
                            }

                            StyledComboBox {
                                id: checkRadius
                                Layout.fillWidth: true
                                model: ["Radio 1km", "Radio 2km"]
                            }
                        }

                        Button {
                            visible: !root.formUnlocked
                            Layout.fillWidth: true
                            Layout.preferredHeight: 45

                            background: Rectangle {
                                color: "#e0e7ff"
                                radius: 8
                            }

                            contentItem: Text {
                                text: "Verificar Duplicados"
                                color: "#4338ca"
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            onClicked: {
                                var lat = root.currentCoordinates ? root.currentCoordinates.lat : backend.userLocation.latitude
                                var lon = root.currentCoordinates ? root.currentCoordinates.lon : backend.userLocation.longitude

                                var animalType = checkType.currentText
                                var radius = checkRadius.currentIndex === 0 ? 1.0 : 2.0

                                console.log("Checking duplicates:", animalType, "at", lat, lon, "radius:", radius)

                                root.duplicateResults = backend.checkDuplicates(animalType, lat, lon, radius)

                                console.log("Found", root.duplicateResults.length, "potential duplicates")

                                if (root.duplicateResults.length > 0) {
                                    root.showDuplicateDialog = true
                                } else {
                                    root.formUnlocked = true
                                }
                            }
                        }

                        Rectangle {
                            visible: root.formUnlocked
                            Layout.fillWidth: true
                            height: 30
                            color: "#dcfce7"
                            radius: 6

                            RowLayout {
                                anchors.centerIn: parent
                                Text {
                                    text: "✓ No hay duplicados."
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#166534"
                                }
                            }
                        }
                    }
                }

                // --- SECTION B: REPORT FORM ---
                ColumnLayout {
                    visible: root.formUnlocked
                    opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 500 } }

                    Layout.fillWidth: true
                    Layout.leftMargin: 16
                    Layout.rightMargin: 16
                    spacing: 16

                    Text {
                        text: "Paso 2: Datos de la Emergencia"
                        font.bold: true
                        font.pixelSize: 14
                        color: Theme.textDark
                        Layout.topMargin: 10
                    }

                    // 1. LOCATION
                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Text {
                            text: "UBICACIÓN EXACTA *"
                            font.bold: true
                            font.pixelSize: 10
                            color: Theme.textGray
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            StyledTextField {
                                id: locField
                                Layout.fillWidth: true
                                placeholderText: "Dirección o referencia visual..."
                                readOnly: root.usingGpsLocation
                            }

                            Button {
                                Layout.preferredWidth: 50
                                Layout.preferredHeight: 50

                                background: Rectangle {
                                    color: "#f3f4f6"
                                    radius: 10
                                    border.color: "#d1d5db"
                                    border.width: 1
                                }

                                contentItem: Text {
                                    text: "📍"
                                    font.pixelSize: 20
                                    anchors.centerIn: parent
                                }

                                onClicked: root.getGPSLocation()
                            }
                        }
                    }

                    // 2. SEVERITY
                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Text {
                            text: "GRAVEDAD (Heap Priority) *"
                            font.bold: true
                            font.pixelSize: 10
                            color: Theme.textGray
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Repeater {
                                model: [
                                    { label: "ALTA", value: "HIGH",  color: "#ef4444", icon: "🚨" },
                                    { label: "MEDIA", value: "MEDIUM", color: "#f97316", icon: "⚠️" },
                                    { label: "BAJA", value: "LOW",   color: "#22c55e", icon: "👀" }
                                ]

                                Button {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50

                                    background: Rectangle {
                                        color: root.currentSeverity === modelData.value
                                               ? Qt.lighter(modelData.color, 1.9)
                                               : "white"
                                        border.color: root.currentSeverity === modelData.value
                                                      ? modelData.color
                                                      : "#e5e7eb"
                                        border.width: 2
                                        radius: 10
                                    }

                                    contentItem: Column {
                                        anchors.centerIn: parent

                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 16
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: modelData.label
                                            font.bold: true
                                            font.pixelSize: 10
                                            color: modelData.color
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }

                                    onClicked: root.currentSeverity = modelData.value
                                }
                            }
                        }
                    }

                    // 3. DESCRIPTION
                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Text {
                            text: "DESCRIPCIÓN *"
                            font.bold: true
                            font.pixelSize: 10
                            color: Theme.textGray
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 90
                            radius: 10
                            border.color: "#e5e7eb"
                            border.width: 2
                            color: "#f9fafb"

                            TextArea {
                                id: descField
                                anchors.fill: parent
                                anchors.margins: 10
                                placeholderText: "Ej: Perro atropellado..."
                                wrapMode: TextArea.Wrap
                                font.pixelSize: 14
                                color: Theme.textDark
                                background: null
                            }
                        }
                    }

                    // 4. PHOTO
                    ColumnLayout {
                        spacing: 6
                        Layout.fillWidth: true

                        Text {
                            text: "EVIDENCIA (Opcional)"
                            font.bold: true
                            font.pixelSize: 10
                            color: Theme.textGray
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 120
                            color: root.selectedImage === "" ? "#f9fafb" : "black"
                            radius: 10
                            border.color: "#d1d5db"
                            border.width: root.selectedImage === "" ? 2 : 0
                            clip: true

                            ColumnLayout {
                                visible: root.selectedImage === ""
                                anchors.centerIn: parent

                                Text {
                                    text: "📷"
                                    font.pixelSize: 24
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: "Toca para adjuntar"
                                    font.pixelSize: 11
                                    color: Theme.textGray
                                }
                            }

                            Image {
                                visible: root.selectedImage !== ""
                                anchors.fill: parent
                                source: root.selectedImage
                                fillMode: Image.PreserveAspectCrop
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: fileDialog.open()
                            }
                        }
                    }

                    // SUBMIT BUTTON
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        Layout.topMargin: 10
                        enabled: root.isFormValid

                        background: Rectangle {
                            color: parent.enabled ? "#dc2626" : "#9ca3af"
                            radius: 12
                        }

                        contentItem: Text {
                            text: "ENVIAR REPORTE"
                            color: "white"
                            font.bold: true
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            var coords = root.currentCoordinates ? root.currentCoordinates : null

                            root.caseReported(
                                        checkType.currentText,
                                        root.currentSeverity,
                                        locField.text,
                                        descField.text,
                                        root.selectedImage,
                                        coords)

                            // Reset state
                            locField.text = ""
                            descField.text = ""
                            root.selectedImage = ""
                            root.formUnlocked = false
                            root.currentSeverity = "MEDIUM"
                            root.currentCoordinates = null
                            root.usingGpsLocation = false
                            locField.readOnly = false
                        }
                    }

                    Item { Layout.preferredHeight: 30 }
                }
            }
        }
    }

    // --- DUPLICATE WARNING DIALOG --- (unchanged)
    Dialog {
        id: duplicateDialog
        width: Math.min(parent.width - 40, 400)
        height: Math.min(parent.height - 100, 500)
        anchors.centerIn: parent
        visible: root.showDuplicateDialog
        modal: true
        title: "⚠️ Posibles Duplicados"

        onClosed: root.showDuplicateDialog = false

        ColumnLayout {
            anchors.fill: parent
            spacing: 12

            Text {
                text: "Se encontraron " + root.duplicateResults.length + " reportes similares:"
                font.bold: true
                font.pixelSize: 14
                color: "#dc2626"
                Layout.fillWidth: true
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: root.duplicateResults

                delegate: Rectangle {
                    width: ListView.view.width
                    height: 110
                    radius: 8
                    color: "#fff7ed"
                    border.color: "#f97316"
                    border.width: 2

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: modelData.type + " - " + modelData.name
                                font.bold: true
                                font.pixelSize: 14
                            }

                            Item { Layout.fillWidth: true }

                            Rectangle {
                                width: 50
                                height: 20
                                radius: 10
                                color: "#fee2e2"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.score + "%"
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#dc2626"
                                }
                            }
                        }

                        Text {
                            text: "📍 " + modelData.location + " (" + modelData.distance + ")"
                            font.pixelSize: 11
                            color: "#6b7280"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "⏱️ " + modelData.timeAgo + " • " + modelData.severity
                            font.pixelSize: 11
                            color: "#6b7280"
                        }

                        Text {
                            text: modelData.description
                            font.pixelSize: 10
                            color: "#6b7280"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                        }
                    }
                }
            }

            Text {
                text: "¿Deseas continuar con el reporte de todas formas?"
                font.pixelSize: 12
                color: "#6b7280"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Button {
                    Layout.fillWidth: true
                    text: "Cancelar"

                    background: Rectangle {
                        color: "#f3f4f6"
                        radius: 8
                        border.color: "#d1d5db"
                        border.width: 1
                    }

                    contentItem: Text {
                        text: parent.text
                        color: "#374151"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: root.showDuplicateDialog = false
                }

                Button {
                    Layout.fillWidth: true

                    background: Rectangle {
                        color: "#dc2626"
                        radius: 8
                    }

                    contentItem: Text {
                        text: "Continuar"
                        color: "white"
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        root.showDuplicateDialog = false
                        root.formUnlocked = true
                    }
                }
            }
        }
    }

    // --- STYLED COMPONENTS ---
    component StyledTextField: Rectangle {
        id: textFieldRoot
        property alias text: innerField.text
        property alias placeholderText: innerField.placeholderText
        property alias inputMethodHints: innerField.inputMethodHints
        property alias validator: innerField.validator
        property alias readOnly: innerField.readOnly

        implicitHeight: 50
        radius: 10
        color: "#f9fafb"
        border.color: innerField.activeFocus ? Theme.brandPink : "#e5e7eb"
        border.width: 2

        TextField {
            id: innerField
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            font.pixelSize: 14
            color: Theme.textDark
            background: null
            verticalAlignment: TextInput.AlignVCenter
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
