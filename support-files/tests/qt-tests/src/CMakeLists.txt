cmake_minimum_required(VERSION 3.16)
project(contextinfo LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core OpenGL)

qt_add_executable(contextinfo
    main.cpp
)

target_link_libraries(contextinfo PUBLIC
    Qt::Core
    Qt::OpenGL
)
