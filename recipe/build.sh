#!/bin/bash

if [ `uname` == Darwin ]; then
    CMAKE_ARGS="-D CMAKE_OSX_DEPLOYMENT_TARGET:STRING=${MACOSX_DEPLOYMENT_TARGET}"
fi

# When building 32-bits on 64-bit system this flags is not automatically set by conda-build
if [ $ARCH == 32 -a "${OSX_ARCH:-notosx}" == "notosx" ]; then
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
fi

BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}


PYTHON_INCLUDE_DIR=$(${PYTHON} -c 'import sysconfig;print("{0}".format(sysconfig.get_path("platinclude")))')
PYTHON_LIBRARY_DIR=$(${PYTHON} -c 'import sysconfig;print("{0}/{1}".format(*map(sysconfig.get_config_var, ("LIBDIR", "LDLIBRARY"))))')


cmake \
    -D "CMAKE_CXX_FLAGS:STRING=-fvisibility=hidden -fvisibility-inlines-hidden ${CXXFLAGS}" \
    -D "CMAKE_C_FLAGS:STRING=-fvisibility=hidden ${CFLAGS}" \
    -D "CMAKE_EXE_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_MODULE_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_SHARED_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_STATIC_LINKER_FLAGS:STRING=${LDFLAGS}" \
    ${CMAKE_ARGS} \
    -D SimpleITK_GIT_PROTOCOL:STRING=git \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D CMAKE_BUILD_TYPE:STRING=RELEASE \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D WRAP_DEFAULT:BOOL=OFF \
    -D WRAP_PYTHON:BOOL=ON \
    -D SimpleITK_USE_SYSTEM_SWIG:BOOL=ON \
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF \
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON \
    -D ITK_USE_SYSTEM_PNG:BOOL=ON \
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON \
    -D ITK_USE_SYSTEM_ZLIB:BOOL=ON \
    -D "CMAKE_SYSTEM_PREFIX_PATH:FILEPATH=${PREFIX}" \
    -D "PYTHON_EXECUTABLE:FILEPATH=${PYTHON}" \
    -D "PYTHON_INCLUDE_DIR:PATH=${PYTHON_INCLUDE_DIR}" \
    -D "PYTHON_LIBRARY_DIR:PATH=${PYTHON_LIBRARY_DIR}" \
    -D "SWIG_EXECUTABLE:FILEPATH=${PREFIX}/bin/swig" \
    "${SRC_DIR}/SuperBuild"

make -j ${CPU_COUNT}
cd ${BUILD_DIR}/SimpleITK-build/Wrapping/Python
${PYTHON} Packaging/setup.py install

