find_package(PhysFS)

if(PHYSFS_LIBRARY)
  set(CMAKE_REQUIRED_LIBRARIES ${PHYSFS_LIBRARY})
  check_symbol_exists("PHYSFS_getPrefDir" "${PHYSFS_INCLUDE_DIR}/physfs.h" HAVE_PHYSFS_GETPREFDIR)
endif()

if(HAVE_PHYSFS_GETPREFDIR)
  set(USE_SYSTEM_PHYSFS ON CACHE BOOL "Use preinstalled physfs (must support getPrefDir)")
else()
  set(USE_SYSTEM_PHYSFS OFF CACHE BOOL "Use preinstalled physfs (must support getPrefDir)")
endif()

if(NOT USE_SYSTEM_PHYSFS)
  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/external/physfs/CMakeLists.txt)
    message(FATAL_ERROR "physfs submodule is not checked out or ${CMAKE_CURRENT_SOURCE_DIR}/external/physfs/CMakeLists.txt is missing")
  endif()

  if(WIN32)
    set(PHYSFS_BUILD_SHARED TRUE)
    set(PHYSFS_BUILD_STATIC FALSE)
  else()
    set(PHYSFS_BUILD_SHARED FALSE)
    set(PHYSFS_BUILD_STATIC TRUE)
  endif()

  set(PHYSFS_PREFIX ${CMAKE_BINARY_DIR}/physfs)
  ExternalProject_Add(physfs
    SOURCE_DIR "${CMAKE_SOURCE_DIR}/external/physfs/"
    BUILD_BYPRODUCTS
    "${PHYSFS_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}physfs${CMAKE_SHARED_LIBRARY_SUFFIX}"
    "${PHYSFS_PREFIX}/lib${LIB_SUFFIX}/physfs${CMAKE_LINK_LIBRARY_SUFFIX}"
    "${PHYSFS_PREFIX}/lib${LIB_SUFFIX}/${CMAKE_STATIC_LIBRARY_PREFIX}physfs${CMAKE_STATIC_LIBRARY_SUFFIX}"
    CMAKE_ARGS
    -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
    -DCMAKE_INSTALL_PREFIX=${PHYSFS_PREFIX}
    -DLIB_SUFFIX=${LIB_SUFFIX}
    -DPHYSFS_BUILD_SHARED=${PHYSFS_BUILD_SHARED}
    -DPHYSFS_BUILD_STATIC=${PHYSFS_BUILD_STATIC}
    -DPHYSFS_BUILD_TEST=FALSE)

  if(WIN32)
    add_library(physfs_lib SHARED IMPORTED)
    set_target_properties(physfs_lib PROPERTIES IMPORTED_LOCATION "${PHYSFS_PREFIX}/bin/${CMAKE_SHARED_LIBRARY_PREFIX}physfs${CMAKE_SHARED_LIBRARY_SUFFIX}")
    set_target_properties(physfs_lib PROPERTIES IMPORTED_IMPLIB "${PHYSFS_PREFIX}/lib${LIB_SUFFIX}/physfs${CMAKE_LINK_LIBRARY_SUFFIX}")
  else()
    add_library(physfs_lib STATIC IMPORTED)
    set_target_properties(physfs_lib PROPERTIES IMPORTED_LOCATION "${PHYSFS_PREFIX}/lib${LIB_SUFFIX}/${CMAKE_STATIC_LIBRARY_PREFIX}physfs${CMAKE_STATIC_LIBRARY_SUFFIX}")
  endif()
  set(PHYSFS_INCLUDE_DIR "${PHYSFS_PREFIX}/include/")
endif()

include_directories(BEFORE SYSTEM ${PHYSFS_INCLUDE_DIR})

mark_as_advanced(
  PHYSFS_INCLUDE_DIR
  PHYSFS_LIBRARY
  )

# EOF #
