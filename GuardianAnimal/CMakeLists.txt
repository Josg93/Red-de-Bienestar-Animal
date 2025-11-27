cmake_minimum_required(VERSION 3.16)

project(GuardianAnimal VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Positioning Location Network Core)

qt_standard_project_setup(REQUIRES 6.8)

add_subdirectory(Start)
add_subdirectory(ApplicationViews)
add_subdirectory(Popups)

qt_add_executable(appGuardianAnimal
    main.cpp
    src/animalrecord.cpp
    src/animalroles.cpp
    src/googlemapsmanager.cpp
    src/jobticket.cpp
    src/kdtree.cpp
    src/maxheap.cpp
    src/rescuemodel.cpp
    src/rescuesystem.cpp
)

target_sources(appGuardianAnimal
    PRIVATE
        FILE_SET HEADERS
        BASE_DIRS ${CMAKE_SOURCE_DIR}/headers
        FILES
            headers/animalrecord.h
            headers/animalroles.h
            headers/googlemapsmanager.h
            headers/jobticket.h
            headers/kdtree.h
            headers/maxheap.h
            headers/rescuemodel.h
            headers/rescuesystem.h
)

target_include_directories(appGuardianAnimal
    PRIVATE
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/headers
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
        FloatingActionButton.qml
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
        icons/petsHotel.svg
        icons/petsHotel2.svg
        icons/calendar.svg
        icons/warningIcon.svg
        icons/reports3.svg
        icons/highPriority.svg
        icons/mediumPriority.svg
        icons/lowPriority.svg
        icons/emailIcon.svg
        icons/phoneIcon.svg
        icons/cameraIcon.svg
        icons/celebrationIcon.svg
        icons/filterIcon3.svg
        icons/dogIcon3.svg
        icons/ambulanceIcon.svg
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
            Qt6::Location
            Qt6::Network
            Qt6::Core
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
