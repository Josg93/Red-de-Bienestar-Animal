set(MODULE_NAME Popups)
set(LIB_NAME ${MODULE_NAME}Lib) # PopupsLib

qt_add_library(${LIB_NAME} STATIC)

set_target_properties(${LIB_NAME} PROPERTIES AUTOMOC ON)
target_link_libraries(${LIB_NAME} PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Positioning)

qt_add_qml_module(${LIB_NAME}
    URI ${MODULE_NAME}
    # VERSION 1.0
    RESOURCE_PREFIX /
    QML_FILES
        ProfilePopup.qml
        OutcomeModal.qml
        ReportLostFoundPopup.qml
        AdoptionFilter.qml
	AddPetPopup.qml
)
