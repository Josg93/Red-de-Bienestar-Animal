cmake_minimum_required(VERSION 3.16)

project(GuardianAnimal VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Positioning)

qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(Start)
add_subdirectory(ApplicationViews)
add_subdirectory(Popups)

qt_add_executable(appGuardianAnimal
    main.cpp
)

set_source_files_properties(Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
set_source_files_properties(UserSession.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appGuardianAnimal
    URI GuardianAnimal
    QML_FILES
        Main.qml
        ApplicationScreen.qml
        Theme.qml
        Header.qml
        ViewSwitch.qml
        UserSession.qml
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

)



# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appGuardianAnimal PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appGuardianAnimal
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appGuardianAnimal
    PRIVATE Qt6::Quick
            Qt6::QuickControls2
            Qt6::Positioning
            ApplicationViewsLibplugin
            PopupsLibplugin
            StartLibplugin



)

include(GNUInstallDirs)
install(TARGETS appGuardianAnimal
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
