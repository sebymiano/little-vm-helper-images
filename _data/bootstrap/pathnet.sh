#!/usr/bin/env bash
set -euxo pipefail

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
./llvm.sh 15

bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -yq llvm clang"