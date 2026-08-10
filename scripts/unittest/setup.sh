#!/bin/bash

set -e

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
THIRD_PARTY_DIR="${SCRIPT_PATH}/../../third_party"
CMOCKA_PATH="${THIRD_PARTY_DIR}/cmocka"

if [ ! -d "${THIRD_PARTY_DIR}" ];then
  mkdir -p ${THIRD_PARTY_DIR}
fi

if [ ! -d "${CMOCKA_PATH}" ]; then
  echo "cmocka install"
  git clone --depth 1 https://git.cryptomilk.org/projects/cmocka.git ${CMOCKA_PATH}
  sudo apt-get update -qq
  sudo apt-get install -y -qq cmake build-essential libcmocka0 libcmocka-dev gcovr
else
  echo "cmocka already installed"
fi

pushd $SCRIPT_PATH

mkdir -p "${HOME}/opt"

if [ -d "${CMOCKA_PATH}/build" ]; then
    rm -rf $CMOCKA_PATH/build
fi

cmake -DCMAKE_INSTALL_PREFIX=${HOME}/opt -DCMAKE_BUILD_TYPE=Debug -S $CMOCKA_PATH -B $CMOCKA_PATH/build

make -C $CMOCKA_PATH/build
make install -C $CMOCKA_PATH/build

pip install gcovr

popd

echo "Unit test setup complete."