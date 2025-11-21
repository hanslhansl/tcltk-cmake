# ==========================================================================
# import_external_libs(
#     TARGET        <imported-target-name>
#     DEPENDS       <external-project-target>
#     LIB_PATHS     <dir1> [dir2 ...]    # where import libs live
#     DLL_PATHS     <dir1> [dir2 ...]    # where DLLs live
#     LIB_PATTERNS  <pattern1> [pattern2 ...]  # e.g., *.lib, *.a
#     DLL_PATTERNS  <pattern1> [pattern2 ...]  # e.g., *.dll
#     VERBOSE       ON|OFF
# )
#
# Creates an INTERFACE target that:
#   - Links all import libraries automatically
#   - DLLs can be copied with TARGET_RUNTIME_DLLS to the final binary folder of any target that links it
# ==========================================================================
function(import_external_libs)
    set(options VERBOSE)
    set(oneValueArgs TARGET DEPENDS)
    set(multiValueArgs LIB_PATHS DLL_PATHS LIB_PATTERNS DLL_PATTERNS)
    cmake_parse_arguments(IMPL "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT IMPL_TARGET)
        message(FATAL_ERROR "import_external_libs: TARGET missing")
    endif()

    if(NOT IMPL_DEPENDS)
        message(FATAL_ERROR "import_external_libs: DEPENDS missing")
    endif()

    add_library(${IMPL_TARGET} INTERFACE)

    # ---------- Collect import libraries ----------
    set(_import_libs "")
    foreach(_path IN LISTS IMPL_LIB_PATHS)
        foreach(_pat IN LISTS IMPL_LIB_PATTERNS)
            file(GLOB _tmp "${_path}/${_pat}")
            list(APPEND _import_libs ${_tmp})
        endforeach()
    endforeach()

    # ---------- Collect DLLs ----------
    set(_runtime_dlls "")
    foreach(_path IN LISTS IMPL_DLL_PATHS)
        foreach(_pat IN LISTS IMPL_DLL_PATTERNS)
            file(GLOB _tmp "${_path}/${_pat}")
            list(APPEND _runtime_dlls ${_tmp})
        endforeach()
    endforeach()

    # ---------- Import DLLs ----------
    set(_imported_runtime_dlls "")
    if(_runtime_dlls)
        list(GET _import_libs 0 _first_import_lib)
        foreach(dll IN LISTS _runtime_dlls)
            get_filename_component(dll_name "${dll}" NAME_WE)
            add_library(${dll_name} SHARED IMPORTED)
            set_target_properties(${dll_name} PROPERTIES
                IMPORTED_LOCATION   "${dll}"
                IMPORTED_IMPLIB     "${_first_import_lib}"
            )
            add_dependencies(${dll_name} ${IMPL_DEPENDS})
            list(APPEND _imported_runtime_dlls ${dll_name})
        endforeach()
    endif()

    # ---------- Verbose output ----------
    if(IMPL_VERBOSE)
        message(STATUS "[${IMPL_TARGET}] Import libraries:")
        if(_import_libs)
            foreach(lib IN LISTS _import_libs)
                message(STATUS "  LIB: ${lib}")
            endforeach()
        else()
            message(STATUS "  (none found yet)")
        endif()

        message(STATUS "[${IMPL_TARGET}] Runtime DLLs:")
        if(_runtime_dlls)
            foreach(dll IN LISTS _runtime_dlls)
                message(STATUS "  DLL: ${dll}")
            endforeach()
        else()
            message(STATUS "  (none found yet)")
        endif()
    endif()

    # ---------- Link libraries ----------
    target_link_libraries(${IMPL_TARGET} INTERFACE ${_import_libs})
    target_link_libraries(${IMPL_TARGET} INTERFACE ${_imported_runtime_dlls})

    # ---------- Ensure external project builds first ----------
    add_dependencies(${IMPL_TARGET} ${IMPL_DEPENDS})
endfunction()
