#!/bin/bash -e
#
# Author: Vitaly Shishlyannikov <vitaly@dragolabs.org>
# Build debian package of memcached
# http://memcached.org/
#

usage() { echo "Usage: $0 [-m maintainer] [-o org-prefix] [-v version_of_memcached]

Example: $0 -m 'John Smith' -o 'my_org' -v 1.2.3" 1>&2; exit 1; }

# get options
while getopts v:m:o:h option
do
  case "${option}"
  in
    v) VERSION=${OPTARG};;
    m) MAINTAINER=${OPTARG};;
    o) ORG_PREFIX=${OPTARG};;
    h) usage;;
  esac
done

if [ ! `which fpm` ]; then
  echo "I can't find fpm. Try 'gem install fpm'"
  exit 128
fi


# Set workspace
[ -z $WORKSPACE ] && WORKSPACE=`(cd "$(dirname "${0}")"; echo $(pwd))`

# Set defaults
[ -z ${ORG_PREFIX} ] && ORG_PREFIX='debian'
[ -z ${MAINTAINER} ] && MAINTAINER="`whoami`@`hostname`"
[ -z ${VERSION} ] && VERSION='1.4.22'


# Vars
INSTALL_DIR="${WORKSPACE}/install_dir"
SRC_DIR="${WORKSPACE}/source_dir"
PKG_DIR="${WORKSPACE}/_pkg"
CONTROL_DIR="${WORKSPACE}/control"
PKG_NAME='memcached'
ITERATION="${ORG_PREFIX}`date +%y%m%d%H%M`"
# I know about nproc, but in openvz it fails.
CPU_COUNT=`grep processor /proc/cpuinfo | wc -l`

mkdir -p ${INSTALL_DIR} ${SRC_DIR} ${PKG_DIR}

# install build depends
sudo apt-get update -qq
sudo apt-get -y install build-essential libevent-dev

# Download and untar
wget http://www.memcached.org/files/${PKG_NAME}-${VERSION}.tar.gz -P ${SRC_DIR}
tar xzvf ${SRC_DIR}/${PKG_NAME}-${VERSION}.tar.gz -C ${SRC_DIR}

# Complile, install
cd ${SRC_DIR}/${PKG_NAME}-${VERSION}
./configure --prefix=/usr
make -j${CPU_COUNT}
make install DESTDIR=${INSTALL_DIR}

mkdir -p ${INSTALL_DIR}/usr/share/memcached ${INSTALL_DIR}/etc
cp -R ${SRC_DIR}/${PKG_NAME}-${VERSION}/scripts ${INSTALL_DIR}/usr/share/memcached/
cp -R ${SRC_DIR}/${PKG_NAME}-${VERSION}/scripts/memcached-init ${CONTROL_DIR}/memcached.init
cp ${CONTROL_DIR}/memcached.conf ${INSTALL_DIR}/etc/

cd ${WORKSPACE}

# Build package
fpm --force \
    -s dir \
    -t deb \
    --vendor ${ORG_PREFIX} \
    --maintainer "${MAINTAINER}" \
    --deb-user root \
    --deb-group root \
    --url http://memcached.org \
    --version $VERSION \
    --iteration ${ITERATION} \
    -C ${INSTALL_DIR} \
    --description 'Memcached is an in-memory key-value store.' \
    --config-files '/etc/memcached.conf' \
    --deb-suggests 'libcache-memcached-perl' \
    --deb-suggests 'libmemcached' \
    --deb-init ${CONTROL_DIR}/memcached.init \
    --after-install ${CONTROL_DIR}/memcached.postinst \
    --before-remove ${CONTROL_DIR}/memcached.prerm \
    --after-remove ${CONTROL_DIR}/memcached.postrm \
    --name 'memcached' \
    --package ${PKG_DIR}/memcached-VERSION-${ITERATION}-ARCH.deb \
    .
