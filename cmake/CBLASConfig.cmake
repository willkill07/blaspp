# Copyright (c) 2017-2020, University of Tennessee. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
# This program is free software: you can redistribute it and/or modify it under
# the terms of the BSD 3-Clause license. See the accompanying LICENSE file.

# Check if this file has already been run with these settings.
if ("${cblas_config_cache}" STREQUAL "${BLAS_LIBRARIES}")
    message( DEBUG "CBLAS config already done" )
    return()
endif()
set( cblas_config_cache "${BLAS_LIBRARIES}" CACHE INTERNAL "" )

include( "cmake/util.cmake" )

set( lib_list ";-lcblas" )
message( DEBUG "lib_list ${lib_list}" )

foreach (lib IN LISTS lib_list)
    message( STATUS "Checking for CBLAS library ${lib}" )

    try_run(
        run_result compile_result ${CMAKE_CURRENT_BINARY_DIR}
        SOURCES
            "${CMAKE_CURRENT_SOURCE_DIR}/config/cblas.cc"
        LINK_LIBRARIES
            "${lib} ${BLAS_LIBRARIES}"
        COMPILE_DEFINITIONS
            "${blas_defines}"
        COMPILE_OUTPUT_VARIABLE
            compile_output
        RUN_OUTPUT_VARIABLE
            run_output
    )
    debug_try_run( "cblas.cc" "${compile_result}" "${compile_output}"
                              "${run_result}" "${run_output}" )

    if (compile_result AND "${run_output}" MATCHES "ok")
        set( cblas_defines "-DHAVE_CBLAS" CACHE INTERNAL "" )
        set( cblas_libraries "${lib}" CACHE INTERNAL "" )
        set( cblas_found true CACHE INTERNAL "" )
        break()
    endif()
endforeach()

#-------------------------------------------------------------------------------
if (BLAS_FOUND)
    message( "${blue}   Found CBLAS library ${cblas_libraries}${plain}" )
else()
    message( "${red}   CBLAS library not found. Testers cannot be built.${plain}" )
endif()

message( DEBUG "
cblas_found         = '${cblas_found}'
cblas_libraries     = '${cblas_libraries}'
cblas_defines       = '${cblas_defines}'")
