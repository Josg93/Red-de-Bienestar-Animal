pragma Singleton
import QtQuick

QtObject {
    id: root

    // Current User Data
    property string userId: ""
    property string userName: ""
    property string userEmail: ""
    property bool isLoggedIn: userId !== ""

    // Helper to simulate logging in
    function login(name, email) {

        // In a real app, this data comes from the backend/database
        // We simulate a unique ID based on the email
        root.userId = email.replace(/[^a-zA-Z0-9]/g, "") // Simple ID generation
        root.userName = name
        root.userEmail = email
    }

    function logout() {
        root.userId = ""
        root.userName = ""
        root.userEmail = ""
    }
}
