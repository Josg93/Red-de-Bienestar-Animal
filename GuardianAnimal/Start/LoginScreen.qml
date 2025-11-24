import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import GuardianAnimal

Rectangle {
    id: root
    color: Theme.backgroundColor

    signal loginSuccess(string username)

    property bool isRegistering: false

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 20

        // Header
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Text { text: "🐾"; font.pixelSize: 50; Layout.alignment: Qt.AlignHCenter }
            Text {
                text: root.isRegistering ? "Crear Cuenta" : "Bienvenido de nuevo"
                font.bold: true; font.pixelSize: 24; color: Theme.textDark
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: root.isRegistering ? "Únete a nuestra comunidad de rescate" : "Ingresa para continuar"
                font.pixelSize: 14; color: Theme.textGray
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Fields
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 15

            // Name (Register only)
            StyledTextField {
                id: nameField
                visible: root.isRegistering
                Layout.fillWidth: true
                placeholderText: "Nombre Completo"
                iconText: "👤"
            }

            StyledTextField {
                id: emailField
                Layout.fillWidth: true
                placeholderText: "Correo Electrónico"
                iconText: "✉️"
                inputMethodHints: Qt.ImhEmailCharactersOnly
            }

            StyledTextField {
                id: passField
                Layout.fillWidth: true
                placeholderText: "Contraseña"
                iconText: "🔒"
                // Mask the password
                text: innerField.echoMode = TextInput.Password
            }
        }

        // Action Button
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.topMargin: 10

            background: Rectangle {
                color: Theme.brandPink
                radius: 12
            }

            contentItem: Text {
                text: root.isRegistering ? "Registrarse" : "Iniciar Sesión"
                color: "white"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            // ... inside your Button onClicked ...
            onClicked: {
                if (emailField.text !== "" && passField.text !== "") {
                    var name = root.isRegistering ? nameField.text : "Usuario Demo" // Use input or default

                    // 1. LOGIN TO SESSION
                    UserSession.login(name, emailField.text)

                    // 2. NOTIFY APP
                    root.loginSuccess(name)
                } else {
                    console.log("Fill fields")
                }
            }
        }

        // Toggle Mode
        Text {
            text: root.isRegistering ? "¿Ya tienes cuenta? <b>Inicia Sesión</b>" : "¿Nuevo aquí? <b>Regístrate</b>"
            color: Theme.textGray
            font.pixelSize: 14
            Layout.alignment: Qt.AlignHCenter

            MouseArea {
                anchors.fill: parent
                onClicked: root.isRegistering = !root.isRegistering
            }
        }
    }

    // Helper Component (Reuse the one from ReportView/AddPet if you made it a separate file,
    // otherwise define it here again to be safe)
    component StyledTextField: Rectangle {
        id: tfRoot
        property alias text: inner.text
        property alias placeholderText: inner.placeholderText
        property alias inputMethodHints: inner.inputMethodHints
        property alias echoMode: inner.echoMode // Expose echoMode for password
        property string iconText: ""
        implicitHeight: 50
        radius: 12
        color: "white"
        border.color: inner.activeFocus ? Theme.brandPink : "#e5e7eb"
        border.width: 2
        RowLayout {
            anchors.fill: parent; anchors.margins: 14; spacing: 10
            Text { text: tfRoot.iconText; font.pixelSize: 16 }
            TextField {
                id: inner; Layout.fillWidth: true
                background: null; font.pixelSize: 14; color: Theme.textDark
                verticalAlignment: TextInput.AlignVCenter
            }
        }
    }
}
