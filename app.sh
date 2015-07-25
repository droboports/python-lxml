CPPFLAGS="${CPPFLAGS:-} -I${DEPS}/include/libxml2"
CFLAGS="${CFLAGS:-} -ffunction-sections -fdata-sections"
LDFLAGS="${LDFLAGS:-} -L${DEPS}/lib -Wl,--gc-sections"

### LIBXML2 ###
_build_libxml2() {
local VERSION="2.9.2"
local FOLDER="libxml2-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://xmlsoft.org/libxml2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PATH="${DEPS}/bin:${PATH}" ./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared --without-python
make
make install
popd
}

### LIBXSLT ###
_build_libxslt() {
local VERSION="1.1.28"
local FOLDER="libxslt-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="ftp://xmlsoft.org/libxslt/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host="${HOST}" --prefix="${DEPS}" --disable-shared --with-libxml-prefix="${DEPS}" --without-debug --without-python --without-crypto
sed -i -e "/^.doc \\\\/d" Makefile
make
make install
popd
}

### LXML ###
_build_lxml() {
local VERSION="3.4.4"
local FOLDER="lxml-${VERSION}"
local FILE="${FOLDER}.tgz"
local URL="http://lxml.de/files/${FILE}"
local XPYTHON="${HOME}/xtools/python2/${DROBO}"
local BASE="${PWD}"
export QEMU_LD_PREFIX="${TOOLCHAIN}/${HOST}/libc"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
PKG_CONFIG_PATH="${XPYTHON}/lib/pkgconfig" \
  LDFLAGS="${LDFLAGS:-} -Wl,-rpath,/mnt/DroboFS/Share/DroboApps/python2/lib -L${XPYTHON}/lib" \
  "${XPYTHON}/bin/python" setup.py \
    build_ext -lrt --include-dirs="${XPYTHON}/include" --library-dirs="${XPYTHON}/lib" --force \
    build --force \
    build_scripts --executable="/mnt/DroboFS/Share/DroboApps/python2/bin/python" --force \
    bdist_egg --dist-dir "${BASE}" \
    --with-xslt-config="${DEPS}/bin/xslt-config"
popd
}

### BUILD ###
_build() {
  _build_libxml2
  _build_libxslt
  _build_lxml
}

_clean() {
  rm -v -fr *.egg
  rm -vfr "${DEPS}"
  rm -vfr "${DEST}"
  rm -v -fr target/*
}
