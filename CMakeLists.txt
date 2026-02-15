# file: CMakeLists.txt version: 0.1.0
cmake_minimum_required(VERSION 3.0)
project(
  facile
  VERSION 0.1.0
  LANGUAGES C)

# Add glib
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB2 REQUIRED glib-2.0)
include_directories(${GLIB2_INCLUDE_DIRS})
link_directories(${GLIB2_LIBRARY_DIRS})
add_definitions(${GLIB2_CFLAGS_OTHER})

# Search for the flex cmake package
find_package(FLEX)
# Definition of a scanner
flex_target(FACILE_SCANNER facile.lex
            "${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c")

# Creation of the "facile" executable Definition of a parser
find_package(BISON)
bison_target(FACILE_PARSER facile.y "${CMAKE_CURRENT_BINARY_DIR}/facile.y.c")

add_executable(facile ${FLEX_FACILE_SCANNER_OUTPUTS}
                      ${BISON_FACILE_PARSER_OUTPUTS})
target_link_libraries(facile fl ${GLIB2_LIBRARIES})

# Make tests
enable_testing()
file(GLOB TEST_FILES "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.facile")

foreach(testfile ${TEST_FILES})
  get_filename_component(testname ${testfile} NAME_WE)
  add_test(NAME ${testname} COMMAND facile ${testfile})
endforeach()

# Add zip generator
set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_SOURCE_IGNORE_FILES "build;~$;${CPACK_SOURCE_IGNORE_FILES}")
set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
include(CPack)
