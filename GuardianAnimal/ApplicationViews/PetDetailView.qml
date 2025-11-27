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

    property var petData: ({})
    property bool isAdminMode: false

    signal backClicked()
    signal contactClicked()
    signal editClicked()

    // --- Image Logic ---
    property var imageList: {
        if (petData.images && petData.images.length > 0) return petData.images
        if (petData.imagesJson) {
            try { return JSON.parse(petData.imagesJson) } catch(e) { return [] }
        }
        if (petData.imageSource && petData.imageSource !== "") return [petData.imageSource]
        return []
    }

    Connections {
        target: backend
        function onFilterChanged() {
            if (petData.id) {
                var updated = backend.getAnimalDetails(petData.id)
                if (updated && updated.id) petData = updated
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Flickable {
            id: flickable
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Fix: Use implicitHeight to ensure it calculates the full scroll area correctly
            contentHeight: contentCol.implicitHeight + 60
            clip: true

            // Optional: Adds a visible scrollbar so you know it's working
            ScrollBar.vertical: ScrollBar { }

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 0

                // ==========================
                // 1. HEADER (Fixed height)
                // ==========================
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 350

                    PetImageGallery {
                        anchors.fill: parent
                        imageList: root.imageList
                    }

                    // Back Button
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        color: "white"
                        anchors.top: parent.top; anchors.left: parent.left; anchors.margins: 20
                        layer.enabled: true
                        Text {
                            anchors.centerIn: parent; text: "←"; font.bold: true; font.pixelSize: 24; color: Theme.textDark
                        }
                        MouseArea { anchors.fill: parent; onClicked: root.backClicked() }
                    }
                }

                // ==========================
                // 2. INFO LIST BODY
                // ==========================
                Rectangle {
                    Layout.fillWidth: true
                    // FIX: We must tell the Rectangle how tall its children are
                    implicitHeight: bodyList.implicitHeight + 48
                    color: Theme.backgroundColor

                    ColumnLayout {
                        id: bodyList // ID needed for height calculation
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 24
                        spacing: 24

                        // --- A. NAME ---
                        ColumnLayout {
                            Layout.topMargin: 20
                            spacing: 4
                            Text {
                                text: petData.name || "Sin Nombre"
                                font.bold: true
                                font.pixelSize: 28
                                color: Theme.textDark
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                text: "Agregado recientemente"
                                font.pixelSize: 12
                                color: Theme.textGray
                            }
                        }

                        // --- HELPER COMPONENTS ---
                        component SectionHeader: Text {
                            font.bold: true
                            font.pixelSize: 12
                            color: Theme.textGray
                            font.capitalization: Font.AllUppercase
                            Layout.topMargin: 10
                        }

                        component InfoRow: RowLayout {
                            property string icon
                            property string text
                            property bool isLink: false

                            spacing: 16
                            Layout.fillWidth: true

                            // Fixed width icon container for alignment
                            Item {
                                Layout.preferredWidth: 24
                                Layout.preferredHeight: 24
                                Text {
                                    anchors.centerIn: parent
                                    text: icon
                                    font.pixelSize: 20
                                    color: Theme.iconNormal
                                }
                            }

                            Text {
                                text: parent.text
                                font.pixelSize: 16
                                color: isLink ? Theme.brandPink : Theme.textDark
                                font.bold: isLink
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }
                        }

                        // PHYSICAL
                        ColumnLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            SectionHeader { text: "Características Físicas" }

                            InfoRow {
                                icon: "🐾"
                                text: petData.type || "Raza desconocida"
                            }
                            InfoRow {
                                icon: "⚧"
                                text: petData.sex || "Sexo desconocido"
                            }
                            InfoRow {
                                icon: "⏳"
                                text: petData.age || "Edad desconocida"
                            }
                        }

                        // HEALTH – guard visible against undefined
                        ColumnLayout {
                            spacing: 12
                            Layout.fillWidth: true
                            visible: petData && petData.isSpayed === true

                            SectionHeader { text: "Salud" }

                            InfoRow {
                                icon: "⚕️"
                                text: "Esterilizado / Castrado"
                            }
                        }

                        // STORY
                        ColumnLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            SectionHeader { text: "Historia" }

                            InfoRow {
                                icon: "📝"
                                text: petData.description || "No hay descripción disponible."
                            }
                        }

                        // LOCATION & CONTACT
                        ColumnLayout {
                            spacing: 12
                            Layout.fillWidth: true

                            SectionHeader { text: "Ubicación y Contacto" }

                            InfoRow {
                                icon: "🏠"
                                text: petData.shelterName || petData.location || "Refugio Patitas"
                            }

                            InfoRow {
                                icon: "📍"
                                text: (petData.location || "Sin ubicación") +
                                      (petData.distance ? " (" + petData.distance + ")" : "")
                            }

                            InfoRow {
                                visible: !!(petData && petData.contactPhone)
                                icon: "📞"
                                text: petData.contactPhone || ""
                                isLink: true
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally("tel:" + petData.contactPhone)
                                }
                            }

                            InfoRow {
                                visible: !!(petData && petData.contactEmail)
                                icon: "✉️"
                                text: petData.contactEmail || ""
                                isLink: true
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Qt.openUrlExternally("mailto:" + petData.contactEmail)
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}
