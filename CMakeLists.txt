include(ExternalProject)
include(cmake/import_external_libs.cmake)

cmake_minimum_required(VERSION 4.0.0 FATAL_ERROR)
project(tcltk_cmake LANGUAGES C)

# Build options
option(TCLTK_STATIC "Build tcl/tk as static library" OFF)
option(TCLTK_PDBS "Build tcl/tk with debugging symbols" ON)
option(TCLTK_BUILD_TK "Build tk" ON)

set(TCL_ROOT ${CMAKE_BINARY_DIR}/tcl_project)
set(TK_ROOT ${CMAKE_BINARY_DIR}/tk_project)

if (MSVC)
    set(PLATFORM MSVC)
elseif (MINGW)
    set(PLATFORM MINGW)
    message(FATAL_ERROR "Exit due MINGW not yet implemented.")
else()
    message(STATUS "Unsupported setup for building Tcl/Tk:")
    message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
    message(STATUS "C Compiler ID: ${CMAKE_C_COMPILER_ID}")
    message(STATUS "C Compiler Version: ${CMAKE_C_COMPILER_VERSION}")
    message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER}")
    message(STATUS "C++ Compiler ID: ${CMAKE_CXX_COMPILER_ID}")
    message(STATUS "C++ Compiler Version: ${CMAKE_CXX_COMPILER_VERSION}")

    message(STATUS "CMake Generator: ${CMAKE_GENERATOR}")
    message(STATUS "Generator Platform: ${CMAKE_GENERATOR_PLATFORM}")
    message(STATUS "Generator Toolset: ${CMAKE_GENERATOR_TOOLSET}")

    message(STATUS "CYGWIN: ${CYGWIN}")
    message(STATUS "LINUX: ${LINUX}")
    message(STATUS "MSVC: ${MSVC}")
    message(STATUS "MINGW: ${MINGW}")
    message(STATUS "WIN32: ${WIN32}")
    message(STATUS "UNIX: ${UNIX}")
    message(STATUS "MSYS: ${MSYS}")
    message(FATAL_ERROR "Exit due to unsupported build setup.")
endif()

# Set up build commands and imported libraries based compiler/platform
if (PLATFORM STREQUAL "MSVC")
    set(OPTS "")
    if (TCLTK_PDBS)
        list(APPEND OPTS "pdbs")
    endif()
    if (TCLTK_STATIC)
        list(APPEND OPTS "static")
    endif()
    list(JOIN OPTS "," OPTS)

    set(TCL_CONFIGURE_COMMAND   "")
    #set(TCL_BUILD_COMMAND       cd win && nmake -f makefile.vc release OPTS=${OPTS})
    #set(TCL_INSTALL_COMMAND     cd win && nmake -f makefile.vc install INSTALLDIR=<INSTALL_DIR>)
    #set(TCL_BUILD_COMMAND       cd win && nmake -f makefile.vc release OPTS=${OPTS} && nmake -f makefile.vc install INSTALLDIR=<INSTALL_DIR>)
    set(TCL_BUILD_COMMAND       cd win && nmake -f makefile.vc release install OPTS=${OPTS} INSTALLDIR=<INSTALL_DIR>)
    set(TCL_INSTALL_COMMAND     "")

    set(TCL_IMPORTED_LOCATIONS  libtommath tcl91 zlib1)
    set(TCL_IMPORTED_IMPLIBS    tommath tcl91 zdll)

    set(TK_CONFIGURE_COMMAND   "")
    #set(TK_BUILD_COMMAND       cd win && nmake -f makefile.vc release TCLDIR=${TCL_ROOT}/src/tcl_project OPTS=${OPTS})
    #set(TK_INSTALL_COMMAND     cd win && nmake -f makefile.vc install TCLDIR=${TCL_ROOT}/src/tcl_project INSTALLDIR=<INSTALL_DIR>)
    #set(TK_BUILD_COMMAND       cd win && nmake -f makefile.vc release TCLDIR=${TCL_ROOT}/src/tcl_project OPTS=${OPTS} && nmake -f makefile.vc install TCLDIR=${TCL_ROOT}/src/tcl_project INSTALLDIR=<INSTALL_DIR>)
    set(TK_BUILD_COMMAND        cd win && nmake -f makefile.vc release install OPTS=${OPTS} INSTALLDIR=<INSTALL_DIR> TCLDIR=${TCL_ROOT}/src/tcl_project)
    set(TK_INSTALL_COMMAND     "")

    set(TK_IMPORTED_LOCATIONS   tcl9tk91)
    set(TK_IMPORTED_IMPLIBS     tcl9tk91)
elseif(PLATFORM STREQUAL "MINGW")
endif()

#[[ Set up build instructions for static / shared
if (TCLTK_STATIC)
    set(LIBRARY_TYPE "STATIC")

    set(TCL_FULL_IMPORTED_LOCATIONS "")
    foreach(item IN LISTS TCL_IMPORTED_LOCATIONS)
        list(APPEND TCL_FULL_IMPORTED_LOCATIONS "${TCL_ROOT}/lib/${item}s${CMAKE_STATIC_LIBRARY_SUFFIX}")
    endforeach()
    set(TCL_FULL_IMPORTED_IMPLIBS "")
    foreach(item IN LISTS TCL_IMPORTED_IMPLIBS)
        list(APPEND TCL_FULL_IMPORTED_IMPLIBS "")
    endforeach()

    set(TK_FULL_IMPORTED_LOCATIONS "")
    foreach(item IN LISTS TK_IMPORTED_LOCATIONS)
        list(APPEND TK_FULL_IMPORTED_LOCATIONS "${TK_ROOT}/lib/${item}s${CMAKE_STATIC_LIBRARY_SUFFIX}")
    endforeach()
    set(TK_FULL_IMPORTED_IMPLIBS "")
    foreach(item IN LISTS TK_IMPORTED_IMPLIBS)
        list(APPEND TK_FULL_IMPORTED_IMPLIBS "")
    endforeach()
else()
    set(LIBRARY_TYPE "SHARED")

    set(TCL_FULL_IMPORTED_LOCATIONS "")
    foreach(item IN LISTS TCL_IMPORTED_LOCATIONS)
        list(APPEND TCL_FULL_IMPORTED_LOCATIONS "${TCL_ROOT}/bin/${item}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    endforeach()
    set(TCL_FULL_IMPORTED_IMPLIBS "")
    foreach(item IN LISTS TCL_IMPORTED_IMPLIBS)
        list(APPEND TCL_FULL_IMPORTED_IMPLIBS "${TCL_ROOT}/lib/${item}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    endforeach()

    set(TK_FULL_IMPORTED_LOCATIONS "")
    foreach(item IN LISTS TK_IMPORTED_LOCATIONS)
        list(APPEND TK_FULL_IMPORTED_LOCATIONS "${TK_ROOT}/bin/${item}${CMAKE_SHARED_LIBRARY_SUFFIX}")
    endforeach()
    set(TK_FULL_IMPORTED_IMPLIBS "")
    foreach(item IN LISTS TK_IMPORTED_IMPLIBS)
        list(APPEND TK_FULL_IMPORTED_IMPLIBS "${TK_ROOT}/lib/${item}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    endforeach()
endif()]]

# Download and build tcl
ExternalProject_Add(tcl_project
    PREFIX              ${TCL_ROOT}

    GIT_REPOSITORY      https://github.com/tcltk/tcl.git
    GIT_TAG             main
    GIT_PROGRESS        ON
    GIT_SHALLOW         ON

    CONFIGURE_COMMAND   "${TCL_CONFIGURE_COMMAND}"

    BUILD_IN_SOURCE     1
    BUILD_COMMAND       "${TCL_BUILD_COMMAND}"

    INSTALL_COMMAND     "${TCL_INSTALL_COMMAND}"

    #BUILD_BYPRODUCTS ${TCL_FULL_IMPORTED_LOCATIONS} ${TCL_FULL_IMPORTED_IMPLIBS}
    #BUILD_BYPRODUCTS ${TCL_ROOT}/lib/* ${TCL_ROOT}/bin/*
)
ExternalProject_Get_Property(tcl_project SOURCE_DIR)
set(TCL_SOURCE_DIR "${SOURCE_DIR}")

# Import libraries created by tcl
import_external_libs(
    TARGET        tcl
    DEPENDS       tcl_project
    LIB_PATHS     "${TCL_ROOT}/lib"
    DLL_PATHS     "${TCL_ROOT}/bin"
    LIB_PATTERNS  "*.lib" "*.a"
    DLL_PATTERNS  "*.dll"
    VERBOSE       ON
)
target_include_directories(tcl INTERFACE ${TCL_ROOT}/include)

if(TCLTK_BUILD_TK)
    # Download and build tk
    ExternalProject_Add(tk_project
        PREFIX              ${TK_ROOT}

        GIT_REPOSITORY      https://github.com/tcltk/tk.git
        GIT_TAG             main
        GIT_PROGRESS        ON
        GIT_SHALLOW         ON

        CONFIGURE_COMMAND   "${TK_CONFIGURE_COMMAND}"

        BUILD_IN_SOURCE     1
        BUILD_COMMAND       "${TK_BUILD_COMMAND}"

        INSTALL_COMMAND     "${TK_INSTALL_COMMAND}"

        #BUILD_BYPRODUCTS    ${TK_FULL_IMPORTED_LOCATIONS} ${TK_FULL_IMPORTED_IMPLIBS}
        #BUILD_BYPRODUCTS ${TK_ROOT}/lib/*.* ${TK_ROOT}/bin/*.*
        DEPENDS             tcl_project
    )

    # Import libraries created by tk
    import_external_libs(
        TARGET        tk
        DEPENDS       tk_project
        LIB_PATHS     "${TK_ROOT}/lib"
        DLL_PATHS     "${TK_ROOT}/bin"
        LIB_PATTERNS  "*.lib" "*.a"
        DLL_PATTERNS  "*.dll"
        VERBOSE       ON
    )
    target_include_directories(tk INTERFACE ${TK_ROOT}/include)
endif()

#  Example usage
add_executable(test main.c)
target_link_libraries(test PUBLIC tcl tk)

# copy dlls
if(CMAKE_IMPORT_LIBRARY_SUFFIX)
    add_custom_command(TARGET test POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_RUNTIME_DLLS:test> $<TARGET_FILE_DIR:test>
        COMMAND_EXPAND_LISTS
  )
endif()
#]]