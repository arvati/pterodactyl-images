#!/usr/bin/env bash

set -e

# omada controller package installer script for pterodactyl base image
OMADA_VER="${OMADA_VER:-}"
OMADA_TAR="${OMADA_TAR:-}"
OMADA_URL="${OMADA_URL:-}"
OMADA_MAJOR_VER="${OMADA_VER%.*.*}"
OMADA_MAJOR_MINOR_VER="${OMADA_VER%.*}"
OMADA_DIR="/opt/tplink/EAPController"

cd /tmp
chmod -v 1777 /tmp

wget -nv "${OMADA_URL}"
tar zxvf "${OMADA_TAR}"
rm -f "${OMADA_TAR}"
cd Omada_SDN_Controller_*

mkdir -p "${OMADA_DIR}"
NAMES=( bin data properties lib install.sh uninstall.sh )
# copy over the files to the destination
for NAME in "${NAMES[@]}"
do
  cp -r "${NAME}" "${OMADA_DIR}"
done

# symlink for mongod
ln -sf "$(command -v mongod)" "${OMADA_DIR}/bin/mongod"
chmod 755 "${OMADA_DIR}"/bin/*

mkdir -p "${OMADA_DIR}/logs" 
mkdir -p "${OMADA_DIR}/work"
mkdir -p "${OMADA_DIR}/data/pdf"
mkdir -p "${OMADA_DIR}/data/db"
mkdir -p "${OMADA_DIR}/data/keystore"
chown -R container:container "${OMADA_DIR}"

if [ -d ${OMADA_DIR} ]
then
  # create backup
  cd ${OMADA_DIR}
  tar zcvf /omada.tar.gz .
  chmod -v 1777 /omada.tar.gz
fi

# echo "**** Cleanup ****"
rm -rf /tmp/* ${OMADA_DIR}