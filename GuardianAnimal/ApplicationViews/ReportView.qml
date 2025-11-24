import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import QtQuick.Dialogs
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    // Signal to send the new case
    signal caseReported(string type, string severity, string location, string description, string imageSource)
    // Signal to cancel and go back
    signal cancelReport()

    property bool formUnlocked: false
    property string selectedImage: ""

    // FIX: Store the selected severity at the root level
    property string currentSeverity: "MEDIUM"

    // --- MOCK GPS ---
    function getGPSLocation() {
        locField.text = "Buscando satélites..."
        gpsTimer.start()
    }
    Timer {
        id: gpsTimer; interval: 1500; repeat: false
        onTriggered: locField.text = "Lat: 8.605, Lon: -71.150 (Mi Ubicación)"
    }

    FileDialog {
        id: fileDialog; title: "Evidencia"; nameFilters: ["Image files (*.jpg *.png)"]
        onAccepted: root.selectedImage = selectedFile
    }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // HEADER
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 80; color: Theme.backgroundColor; z: 10
            RowLayout {
                anchors.fill: parent; anchors.margins: 16; spacing: 12
                Rectangle { width: 40; height: 40; radius: 20; color: "#fee2e2"; Text { anchors.centerIn: parent; text: "🚨"; font.pixelSize: 20 } }
                Text { text: "Reportar Emergencia"; font.bold: true; font.pixelSize: 20; color: Theme.textDark }
                Item { Layout.fillWidth: true }
                // Cancel Button (X)
                Text {
                    text: "✕"; font.pixelSize: 24; color: Theme.textGray
                    MouseArea { anchors.fill: parent; onClicked: root.cancelReport() }
                }
            }
        }

        Flickable {
            Layout.fillWidth: true; Layout.fillHeight: true
            contentHeight: contentCol.height + 40; clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentCol; width: parent.width; spacing: 20

                // SPACER
                Item { Layout.preferredHeight: 10 }

                // --- SECTION A: DUPLICATE CHECKER ---
                // (This logic perfectly matches your K-D Tree "Nearest Neighbor" query requirement)
                Rectangle {
                    Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16
                    implicitHeight: dupCheckInner.implicitHeight + 32; radius: 12
                    color: Theme.bgWhite; border.color: root.formUnlocked ? "#e5e7eb" : "#4f46e5"; border.width: 2

                    ColumnLayout {
                        id: dupCheckInner; anchors.fill: parent; anchors.margins: 16; spacing: 12
                        RowLayout {
                            Text { text: "📍"; font.pixelSize: 16 }
                            Text { text: "Paso 1: Verificar Duplicados"; font.bold: true; font.pixelSize: 14; color: Theme.textDark }
                        }
                        Text { text: "El sistema buscará reportes cercanos (K-D Tree Query)."; font.pixelSize: 12; color: Theme.textGray; wrapMode: Text.WordWrap; Layout.fillWidth: true }

                        RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            StyledComboBox { id: checkType; Layout.fillWidth: true; model: ["Perro", "Gato", "Fauna Silvestre"] }
                            // K-D Tree Query parameters
                            StyledComboBox { id: checkRadius; Layout.fillWidth: true; model: ["5 Casos más cercanos", "Radio 1km"] }
                        }

                        Button {
                            visible: !root.formUnlocked
                            Layout.fillWidth: true; Layout.preferredHeight: 45
                            background: Rectangle { color: "#e0e7ff"; radius: 8 }
                            contentItem: Text { text: "🔍 Verificar"; color: "#4338ca"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            onClicked: root.formUnlocked = true
                        }

                        Rectangle {
                            visible: root.formUnlocked
                            Layout.fillWidth: true; height: 30; color: "#dcfce7"; radius: 6
                            RowLayout { anchors.centerIn: parent; Text { text: "✅ No hay duplicados."; font.pixelSize: 11; font.bold: true; color: "#166534" } }
                        }
                    }
                }

                // --- SECTION B: REPORT FORM ---
                ColumnLayout {
                    visible: root.formUnlocked; opacity: visible ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 500 } }
                    Layout.fillWidth: true; Layout.leftMargin: 16; Layout.rightMargin: 16; spacing: 16

                    Text { text: "Paso 2: Datos de la Emergencia"; font.bold: true; font.pixelSize: 14; color: Theme.textDark; Layout.topMargin: 10 }

                    // 1. LOCATION
                    ColumnLayout {
                        spacing: 6; Layout.fillWidth: true
                        Text { text: "UBICACIÓN EXACTA *"; font.bold: true; font.pixelSize: 10; color: Theme.textGray }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            StyledTextField { id: locField; Layout.fillWidth: true; placeholderText: "Dirección o referencia visual..." }
                            Button {
                                Layout.preferredWidth: 50; Layout.preferredHeight: 50
                                background: Rectangle { color: "#f3f4f6"; radius: 10; border.color: "#d1d5db"; border.width: 1 }
                                contentItem: Text { text: "📍"; font.pixelSize: 20; anchors.centerIn: parent }
                                onClicked: root.getGPSLocation()
                            }
                        }
                    }

                    // 2. SEVERITY (FIXED)
                    ColumnLayout {
                        spacing: 6; Layout.fillWidth: true
                        Text { text: "GRAVEDAD (Heap Priority) *"; font.bold: true; font.pixelSize: 10; color: Theme.textGray }
                        RowLayout {
                            Layout.fillWidth: true; spacing: 10
                            Repeater {
                                model: [
                                    { label: "ALTA", value: "HIGH", color: "#ef4444", icon: "🚨" },
                                    { label: "MEDIA", value: "MEDIUM", color: "#f97316", icon: "⚠️" },
                                    { label: "BAJA", value: "LOW", color: "#22c55e", icon: "👀" }
                                ]
                                Button {
                                    Layout.fillWidth: true; Layout.preferredHeight: 50
                                    background: Rectangle {
                                        // FIX: Use root.currentSeverity for binding
                                        color: root.currentSeverity === modelData.value ? Qt.lighter(modelData.color, 1.9) : "white"
                                        border.color: root.currentSeverity === modelData.value ? modelData.color : "#e5e7eb"
                                        border.width: 2; radius: 10
                                    }
                                    contentItem: Column {
                                        anchors.centerIn: parent
                                        Text { text: modelData.icon; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter }
                                        Text { text: modelData.label; font.bold: true; font.pixelSize: 10; color: modelData.color; anchors.horizontalCenter: parent.horizontalCenter }
                                    }
                                    // FIX: Update root property on click
                                    onClicked: root.currentSeverity = modelData.value
                                }
                            }
                        }
                    }

                    // 3. DESCRIPTION
                    ColumnLayout {
                        spacing: 6; Layout.fillWidth: true
                        Text { text: "DESCRIPCIÓN *"; font.bold: true; font.pixelSize: 10; color: Theme.textGray }
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: 90; radius: 10; border.color: "#e5e7eb"; border.width: 2; color: "#f9fafb"
                            TextArea { id: descField; anchors.fill: parent; anchors.margins: 10; placeholderText: "Ej: Perro atropellado..."; wrapMode: TextArea.Wrap; font.pixelSize: 14; color: Theme.textDark; background: null }
                        }
                    }

                    // 4. PHOTO
                    ColumnLayout {
                        spacing: 6; Layout.fillWidth: true
                        Text { text: "EVIDENCIA"; font.bold: true; font.pixelSize: 10; color: Theme.textGray }
                        Rectangle {
                            Layout.fillWidth: true; height: 120; color: root.selectedImage === "" ? "#f9fafb" : "black"; radius: 10; border.color: "#d1d5db"; border.width: root.selectedImage === "" ? 2 : 0; clip: true
                            ColumnLayout {
                                visible: root.selectedImage === ""; anchors.centerIn: parent
                                Text { text: "📷"; font.pixelSize: 24; Layout.alignment: Qt.AlignHCenter }
                                Text { text: "Toca para adjuntar"; font.pixelSize: 11; color: Theme.textGray }
                            }
                            Image { visible: root.selectedImage !== ""; anchors.fill: parent; source: root.selectedImage; fillMode: Image.PreserveAspectCrop }
                            MouseArea { anchors.fill: parent; onClicked: fileDialog.open() }
                        }
                    }

                    // SUBMIT
                    Button {
                        Layout.fillWidth: true; Layout.preferredHeight: 50; Layout.topMargin: 10
                        enabled: locField.text !== "" && descField.text !== ""
                        background: Rectangle { color: parent.enabled ? "#dc2626" : "#9ca3af"; radius: 12 }
                        contentItem: Text { text: "ENVIAR REPORTE"; color: "white"; font.bold: true; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }

                        onClicked: {
                            // FIX: Send the actual selected severity
                            root.caseReported(checkType.currentText, root.currentSeverity, locField.text, descField.text, root.selectedImage)
                            // Reset
                            locField.text=""; descField.text=""; root.selectedImage=""; root.formUnlocked=false; root.currentSeverity="MEDIUM"
                        }
                    }
                    Item { Layout.preferredHeight: 30 }
                }
            }
        }
    }

    // --- REUSED COMPONENTS (To avoid missing types) ---
        component StyledTextField: Rectangle {
            id: textFieldRoot
            property alias text: innerField.text
            property alias placeholderText: innerField.placeholderText
            implicitHeight: 50
            radius: 10; color: "#f9fafb"; border.color: innerField.activeFocus ? Theme.brandPink : "#e5e7eb"; border.width: 2
            Behavior on border.color { ColorAnimation { duration: 200 } }
            TextField {
                id: innerField; anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                font.pixelSize: 14; color: Theme.textDark; placeholderTextColor: Theme.textGray
                background: null; verticalAlignment: TextInput.AlignVCenter
            }
        }

        component StyledComboBox: ComboBox {
            id: comboRoot
            implicitHeight: 50
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
