#!/bin/bash
check_env() {
  # env
  sudo apt update
  sudo apt upgrade -y
  sudo apt install gcc git bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev gdisk zhcon g++ llvm clang make net-tools  hwloc libhwloc-dev cargo -y
  
  if [ -z $GOPROXY ]; then
    sudo echo "#GOPROXY
    export GO111MODULE=on
    export GOPROXY=https://goproxy.cn
    export GOPATH=$HOME/gopath
    " >> /etc/profile
  fi
  
  if [ -z $RUSTUP_DIST_SERVER ]; then
    sudo echo "# RUST
    export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
    export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
    " >> /etc/profile
  fi
  
  source /etc/profile
}

check_go() {
  RESULT=$(go version)
  RESULT=${RESULT:13:7}
  #echo $RESULT
  RESULT=${RESULT%.*}
  echo $RESULT
  if [ -z $RESULT ] || [ `expr $RESULT \> 1.13` -eq 0 ]; then
    echo "go version must > 1.13 . "
    # go install
    sudo add-apt-repository ppa:longsleep/golang-backports -y
    sudo apt-get update
    sudo apt install golang-go -y
    
    # check
    go version && go env
  fi
  echo " "
  return 1
}

check_rustup() {
  RESULT=$(rustup --version)
  RESULT=${RESULT:7:7}
  #echo $RESULT
  RESULT=${RESULT%.*}
  echo $RESULT
  if [ -z $RESULT ] || [ `expr $RESULT \> 1.20` -eq 0 ]; then
    echo "rustup version must > 1.20 . "
    # rustup env config
    if [ ! -s "$HOME/.rustup/config" ]; then
      echo '
      [source.crates-io]
      registry = "https://github.com/rust-lang/crates.io-index"
      replace-with = 'tuna'
      [source.tuna]
      registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
      ' > $HOME/.rustup/config
    fi
    # rustup install
    apt install libcurl4 curl -y
    curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env
    
    # check
    rustup --version
  fi
  echo " "
  return 1
}

set_ulimits() {
grep -q "65535" /etc/security/limits.conf
if [ $? -ne 0 ]; then
cat >>/etc/security/limits.conf<<EOF
root    soft    nofile  65535
root    hard    nofile  65535
root    soft    noproc  65535
root    hard    noproc  65535
EOF
fi
}
add_swap(){

#检查是否存在swap
swapsize=100
grep -q "/swap" /etc/fstab
#如果不存在将为其创建swap
if [ $? -ne 0 ]; then
	echo -e "${Green}swap未发现，正在为其创建${Font}"
	fallocate -l ${swapsize}G /swap
	chmod 600 /swap
	mkswap /swap
	swapon /swap
	echo '/swap none swap defaults 0 0' >> /etc/fstab
         echo -e "${Green}swap创建成功，并查看信息：${Font}"
         cat /proc/swaps
         cat /proc/meminfo | grep Swap
else
	echo -e "${Red}swap已存在，swap设置失败，请先运行脚本删除swap后重新设置！${Font}"
fi
}

del_swap(){
#检查是否存在swap.img
grep -q "swap.img" /etc/fstab

#如果存在就将其移除
if [ $? -eq 0 ]; then
	echo -e "${Green}swap.img已发现，正在将其移除...${Font}"
	sed -i '/swap.img/d' /etc/fstab
	echo "3" > /proc/sys/vm/drop_caches
	swapoff -a
	rm -f /swap.img
    echo -e "${Green}swap.img已删除！${Font}"
else
	echo -e "${Red}swap.img未发现，swap删除失败！${Font}"
fi
}


set_wk_env() {
grep -q "MINER_API_INFO" /etc/profile
if [ $? -ne 0 ]; then
   cat >>/etc/profile<<EOF
export RUST_BACKTRACE=info
export RUST_LOG=info
EOF
else
  echo "wk env has already set"
fi
source /etc/profile
}

mk_wk_run_sh() {
if [[ ! -d "/ipfs/filecoin/lotusworker1" ]]; then
    mkdir -p /ipfs/filecoin/lotusworker1 
    mkdir -p /ipfs/filecoin/lotusworker2 
    mkdir -p /ipfs/filecoin/tmpdir1 
    mkdir -p /ipfs/filecoin/tmpdir2
fi
if [[ ! -f "/filestar/lotusworker/" ]]; then
cp ./run-fil-wk-moran-p1p2.sh /ipfs/filecoin/lotusworker1/
cp ./run-fil-wk-moran-p2c1.sh /ipfs/filecoin/lotusworker2/
cp ~/fil-auto-deploy/killworker.sh /ipfs/filecoin/
cp ~/fil-auto-deploy//wk-ap-switch.sh  /ipfs/filecoin/
fi
}

check_env
check_go
check_rustup
set_ulimits
#set time-zone
echo "sect timezone"
timedatectl set-timezone "Asia/Shanghai"
#reset swap
#del_swap
#add_swap
set_wk_env
mk_wk_run_sh
#scp lotus-worker
#apt install expect -y
#exec ./scp_lotus-worker.sh
