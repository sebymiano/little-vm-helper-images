#!/usr/bin/env bash
set -euxo pipefail

set +u
. /etc/profile
set -u

resolv_path="/etc/resolv.conf"

cat >> "$resolv_path" <<EOF
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

apt update
apt install software-properties-common -y

# add-apt-repository ppa:deadsnakes/ppa -y
cat > /etc/apt/sources.list.d/deadsnakes-ppa.list <<EOF
deb [arch=$(dpkg --print-architecture)] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu noble main 
deb-src [arch=$(dpkg --print-architecture)] https://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu noble main 
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
# echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/deadsnakes-ppa.list
apt update
apt install python3.11 python3.11-dev python3.11-venv -y

LLVM_VERSION=15
# wget https://apt.llvm.org/llvm.sh
# chmod +x llvm.sh
# ./llvm.sh $LLVM_VERSION

cat > /etc/apt/sources.list.d/llvm.list <<EOF
deb [arch=$(dpkg --print-architecture)] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main
deb-src [arch=$(dpkg --print-architecture)] http://apt.llvm.org/jammy/ llvm-toolchain-jammy-15 main
EOF

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

apt update
apt install clang-$LLVM_VERSION llvm-$LLVM_VERSION llvm-$LLVM_VERSION-dev llvm-$LLVM_VERSION-tools llvm clang -y

#bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -yq llvm clang"

update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-$LLVM_VERSION 200
update-alternatives --install /usr/bin/clang clang /usr/bin/clang-$LLVM_VERSION 200
update-alternatives --config clang
update-alternatives --config clang++

update-alternatives --install \
        /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-$LLVM_VERSION  200 \
--slave /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-$LLVM_VERSION \
--slave /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-$LLVM_VERSION \
--slave /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-$LLVM_VERSION \
--slave /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-$LLVM_VERSION \
--slave /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-$LLVM_VERSION \
--slave /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-$LLVM_VERSION \
--slave /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-$LLVM_VERSION \
--slave /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-$LLVM_VERSION \
--slave /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-$LLVM_VERSION \
--slave /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-$LLVM_VERSION \
--slave /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-$LLVM_VERSION \
--slave /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-$LLVM_VERSION \
--slave /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-$LLVM_VERSION \
--slave /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-$LLVM_VERSION \
--slave /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-$LLVM_VERSION \
--slave /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-$LLVM_VERSION \
--slave /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-$LLVM_VERSION \


update-alternatives --install \
        /usr/bin/llvm-config       llvm-config      /usr/bin/llvm-config-$LLVM_VERSION  200 \
--slave /usr/bin/llvm-ar           llvm-ar          /usr/bin/llvm-ar-$LLVM_VERSION \
--slave /usr/bin/llvm-as           llvm-as          /usr/bin/llvm-as-$LLVM_VERSION \
--slave /usr/bin/llvm-bcanalyzer   llvm-bcanalyzer  /usr/bin/llvm-bcanalyzer-$LLVM_VERSION \
--slave /usr/bin/llvm-cov          llvm-cov         /usr/bin/llvm-cov-$LLVM_VERSION \
--slave /usr/bin/llvm-diff         llvm-diff        /usr/bin/llvm-diff-$LLVM_VERSION \
--slave /usr/bin/llvm-dis          llvm-dis         /usr/bin/llvm-dis-$LLVM_VERSION \
--slave /usr/bin/llvm-dwarfdump    llvm-dwarfdump   /usr/bin/llvm-dwarfdump-$LLVM_VERSION \
--slave /usr/bin/llvm-extract      llvm-extract     /usr/bin/llvm-extract-$LLVM_VERSION \
--slave /usr/bin/llvm-link         llvm-link        /usr/bin/llvm-link-$LLVM_VERSION \
--slave /usr/bin/llvm-mc           llvm-mc          /usr/bin/llvm-mc-$LLVM_VERSION \
--slave /usr/bin/llvm-objdump      llvm-objdump     /usr/bin/llvm-objdump-$LLVM_VERSION \
--slave /usr/bin/llvm-ranlib       llvm-ranlib      /usr/bin/llvm-ranlib-$LLVM_VERSION \
--slave /usr/bin/llvm-readobj      llvm-readobj     /usr/bin/llvm-readobj-$LLVM_VERSION \
--slave /usr/bin/llvm-rtdyld       llvm-rtdyld      /usr/bin/llvm-rtdyld-$LLVM_VERSION \
--slave /usr/bin/llvm-size         llvm-size        /usr/bin/llvm-size-$LLVM_VERSION \
--slave /usr/bin/llvm-stress       llvm-stress      /usr/bin/llvm-stress-$LLVM_VERSION \
--slave /usr/bin/llvm-tblgen       llvm-tblgen      /usr/bin/llvm-tblgen-$LLVM_VERSION \
