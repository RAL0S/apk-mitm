#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]
then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1
  
  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  wget https://github.com/RAL0S/apk-mitm/releases/download/v1.2.1/zip-tools.tar.gz -O $RALPM_TMP_DIR/zip-tools.tar.gz
  tar xf $RALPM_TMP_DIR/zip-tools.tar.gz -C $RALPM_PKG_INSTALL_DIR/
  rm $RALPM_TMP_DIR/zip-tools.tar.gz

  wget https://github.com/RAL0S/apk-mitm/releases/download/v1.2.1/apk-mitm.tar.gz -O $RALPM_TMP_DIR/apk-mitm.tar.gz
  tar xf $RALPM_TMP_DIR/apk-mitm.tar.gz -C $RALPM_PKG_INSTALL_DIR/bin/
  rm $RALPM_TMP_DIR/apk-mitm.tar.gz

  chmod +x $RALPM_PKG_INSTALL_DIR/bin/*

  wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O $RALPM_TMP_DIR/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz
  tar xf $RALPM_TMP_DIR/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -C $RALPM_PKG_INSTALL_DIR/

  echo "#!/usr/bin/env sh" > $RALPM_PKG_BIN_DIR/apk-mitm
  echo "PATH=$RALPM_PKG_INSTALL_DIR/bin/:$RALPM_PKG_INSTALL_DIR/jdk8u345-b01-jre/bin:\$PATH $RALPM_PKG_INSTALL_DIR/bin/apk-mitm \"\$@\"" >> $RALPM_PKG_BIN_DIR/apk-mitm
  chmod +x $RALPM_PKG_BIN_DIR/apk-mitm

  echo "This package adds the command: apk-mitm"
}

uninstall() {
  rm -rf $RALPM_PKG_INSTALL_DIR/*
  rm $RALPM_PKG_BIN_DIR/apk-mitm
}

run() {
  if [[ "$1" == "install" ]]; then 
    install
  elif [[ "$1" == "uninstall" ]]; then 
    uninstall
  else
    show_usage
  fi
}

check_env
run $1