cmake_minimum_required(VERSION 3.16)

project(appProjectTest VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appProjectTest
    main.cpp
)

set_source_files_properties(Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appProjectTest
    URI appProjectTest
    QML_FILES
        Main.qml
        Theme.qml
        Header.qml
        ViewSwitch.qml
        DashboardView.qml
        ApplicationScreen.qml
        RescueListView.qml
        AdoptionView.qml
        AdoptionFilter.qml
        AddPetPopup.qml

    RESOURCES
        icons/homeIcon.svg
        icons/notificationIcon.svg
        icons/profileIcon.svg
        icons/reportIcon.svg
        icons/rescueIcon.svg
        icons/lostIcon.svg
        icons/casesIcon.svg
        icons/pawIcon.svg
        icons/dog.svg
        icons/locationsIcon.svg
        icons/filterIcon.svg
        icons/addIcon.png
    RESOURCE_PREFIX /
    QML_FILES PetImageGallery.qml
    QML_FILES LostFoundView.qml
    QML_FILES ReportLostFoundPopup.qml
    QML_FILES NavigationView.qml


)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appProjectTest PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.apptestApp33
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appProjectTest
    PRIVATE Qt6::Quick Qt6::QuickControls2
)

include(GNUInstallDirs)
install(TARGETS appProjectTest
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
