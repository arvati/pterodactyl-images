#!/usr/bin/env bash

set -e

# omada controller package installer script for pterodactyl base image
OMADA_VER="${OMADA_VER:-}"
OMADA_TAR="${OMADA_TAR:-}"
OMADA_URL="${OMADA_URL:-}"
OMADA_MAJOR_VER="${OMADA_VER%.*.*}"
OMADA_MAJOR_MINOR_VER="${OMADA_VER%.*}"
OMADA_DIR="${OMADA_DIR:-/home/container}"
OMADA_USER="${OMADA_USER:-container}"
LINK_CMD="/usr/bin/tpeap"

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

ln -s "${OMADA_DIR}/bin/control.sh" ${LINK_CMD}
chmod +x ${LINK_CMD}
ln -sf $(which mongod) "${OMADA_DIR}/bin/mongod"
ln -sf "$(command -v mongod)" "${OMADA_DIR}/bin/mongod"
chmod 755 "${OMADA_DIR}"/bin/*

mkdir -p "${OMADA_DIR}/logs" 
mkdir -p "${OMADA_DIR}/work"
mkdir -p "${OMADA_DIR}/cert"
mkdir -p "${OMADA_DIR}/data/pdf"
mkdir -p "${OMADA_DIR}/data/db"
mkdir -p "${OMADA_DIR}/data/keystore"


echo "#!/bin/bash
SHOW_SERVER_LOGS=\"\${SHOW_SERVER_LOGS:-true}\"
SHOW_MONGODB_LOGS=\"\${SHOW_MONGODB_LOGS:-false}\"
SSL_CERT_NAME=\${SSL_CERT_NAME:-tls.crt}
SSL_KEY_NAME=\${SSL_KEY_NAME:-tls.key}
OMADA_DIR=\"\${OMADA_DIR:-${OMADA_DIR}}\"
SSL_FOLDER=\"\$OMADA_DIR/cert\"

if [ \"\${SHOW_SERVER_LOGS}\" = \"true\" ] && [ -f \${OMADA_DIR}/logs/server.log ]
then
  tail -F -n 0 \${OMADA_DIR}/logs/server.log &
fi
if [ \"\${SHOW_MONGODB_LOGS}\" = \"true\" ] && [ -f \${OMADA_DIR}/logs/mongod.log ]
then
  tail -F -n 0 \${OMADA_DIR}/logs/mongod.log &
fi

# Include bin to path
if [ -d \$OMADA_DIR/bin ] ; then
    export PATH=\"\$OMADA_DIR/bin:\$PATH\"
fi

if [ -f \$SSL_FOLDER/\$SSL_KEY_NAME ] && [ -f \$SSL_FOLDER/\$SSL_CERT_NAME ]; then
  rm -f \$OMADA_DIR/data/keystore/eap.keystore
  openssl pkcs12 -export \
    -inkey \$SSL_FOLDER/\$SSL_KEY_NAME \
    -in \$SSL_FOLDER/\$SSL_CERT_NAME \
    -certfile \$SSL_FOLDER/\$SSL_CERT_NAME \
    -name eap \
    -out \$OMADA_DIR/data/keystore/eap.keystore \
    -passout pass:tplink
  chmod 400 \$OMADA_DIR/data/keystore/eap.keystore
fi
" > ${OMADA_DIR}/.profile

chown -R ${OMADA_USER}:${OMADA_USER} "${OMADA_DIR}"

if [ -d ${OMADA_DIR} ]
then
  # create backup
  cd ${OMADA_DIR}
  tar zcvf /omada.tar.gz .
  chmod -v 1777 /omada.tar.gz
fi

# echo "**** Cleanup ****"
rm -rf /tmp/* ${OMADA_DIR}
