// Theme.qml
pragma Singleton
import QtQuick

QtObject {
    id: root

    property bool darkMode: false

    // --- Guardian Animal Palette ---
    readonly property color brandPink: "#ec4899"
    readonly property color brandPinkHover: "#db2777"
    readonly property color bgLightGray: "#f4f7fa"
    readonly property color bgWhite: "#ffffff"
    readonly property color textDark: "#333333"
    readonly property color textGray: "#6b7280"
    readonly property color brandBlue: "#e0e7ff"
    readonly property color lightPink: "#fce7f3"

    // --- Mapped Properties ---
    readonly property color backgroundColor: root.darkMode ? "#06054b" : root.bgLightGray
    readonly property color darkBackgroundColor: root.darkMode ? "#020233" : root.bgWhite
    readonly property color textMainColor: root.darkMode ? "#ffffff" : root.textDark
    readonly property color textSecondaryColor: root.textGray

    readonly property color greenColor: root.brandPink
    readonly property color inUseColor: root.brandPink
    readonly property color inViewColor: "#a5b4fc"

    readonly property color iconNormal: root.textGray
    readonly property color iconSelected: root.brandPink
    readonly property color iconTextNormal: root.textGray
    readonly property color iconTextSelected: root.brandPink

    readonly property color separatorColor: "#e5e7eb"

    // Fonts
    readonly property int largeFontSize: 18
    readonly property int mediumFontSize: 14
    readonly property int smallFontSize: 12
    readonly property int fontDefaultWeight: Font.DemiBold
    readonly property int fontLightWeight: Font.Normal

    readonly property int defaultSpacing: 10
}
