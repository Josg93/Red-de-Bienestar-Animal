import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import ApplicationViews
import Popups
import Start
import GuardianAnimal

Rectangle {
    id: root

    property bool requestDenied: false
    signal requestPermission

    color: Theme.backgroundColor

    ColumnLayout {
        id: rootLayout
        anchors.fill: parent
        spacing: 20

        Item { Layout.fillHeight: true } // Spacer Top

        // Icon
        Text {
            text: "📍" //CAMBIAR ICONO
            font.pixelSize: 60
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: titleText
            text: root.requestDenied
                  ? "Permiso Denegado"
                  : "Permiso de Ubicación"
            font.bold: true
            font.pixelSize: 24
            color: Theme.textDark
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            id: descriptionText
            text: root.requestDenied
                  ? "La aplicación no puede funcionar sin acceso a tu ubicación.\nPor favor habilítalo en la configuración de tu dispositivo."
                  : "Guardian Animal necesita tu ubicación para encontrar\nmascotas cercanas y calcular rutas de rescate."

            horizontalAlignment: Text.AlignHCenter
            color: Theme.textGray
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width * 0.8
            wrapMode: Text.WordWrap
        }

        Item { height: 20 }

        Button {
            visible: !root.requestDenied
            Layout.preferredWidth: parent.width * 0.8
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignHCenter

            background: Rectangle {
                color: Theme.brandPink
                radius: 12
            }

            contentItem: Text {
                text: "Permitir Acceso"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: root.requestPermission()
        }

        Item { Layout.fillHeight: true } // Spacer Bottom
    }
}

