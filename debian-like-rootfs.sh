#!/usr/bin/env -S sudo bash
# vim: ts=2 expandtab sw=2

SCRIPT_DIR=$(dirname $(readlink -f "$0"))

# basic configs
CODENAME=$1
CODENAME=${CODENAME:-bookworm}
MIRROR=$2
EXTENDED_REPO=''

case "$CODENAME" in
  precise|trusty|xenial|bionic|focal|jammy)
    # all LTS versions
    MIRROR=${MIRROR:-https://opentuna.cn/ubuntu/}
    EXTENDED_REPO="restricted universe multiverse"
    ;;
  jessie|stretch|buster|bullseye|bookworm)
    MIRROR=${MIRROR:-https://opentuna.cn/debian/}
    EXTENDED_REPO="contrib non-free"
    ;;
  *)
    if [ -z "$MIRROR" ]; then
      echo "Unsupported codename \`$CODENAME', please provide a mirror manually, either set a \`MIRROR' environment variable or pass it as the script's second parameter."
      exit 1
    fi
    ;;
esac

ARCH=${ARCH:-amd64}

CACHE_DIR=$SCRIPT_DIR/cache/$CODENAME
ROOTFS_DIR=$SCRIPT_DIR/$CODENAME

setup_cache_dir() {
  mkdir -p "$CACHE_DIR"
}

run_debootstrap() {
  debootstrap --arch=$ARCH --cache-dir "$CACHE_DIR" --foreign "$CODENAME" "$ROOTFS_DIR" "$MIRROR"
}


run_in_rootfs_with_bash() {
  chroot "$ROOTFS_DIR" /bin/bash -c "$@"
}

run_in_rootfs() {
  chroot "$ROOTFS_DIR" "$@"
}

main() {
  echo "# Setup cache dir"
  setup_cache_dir
  
  echo "# Stage 1"
  run_debootstrap
  
  echo "# Stage 2"
  run_in_rootfs /debootstrap/debootstrap --second-stage
  
  echo "# Configuring mirror"
  if [ ! -z "$EXTENDED_REPO" ]; then
    sed -i "s/$CODENAME main/$CODENAME main $EXTENDED_REPO/g" "$ROOTFS_DIR/etc/apt/sources.list"
  fi

  echo "# Setting up builder(user), shell(chsh), git and sudo"
  run_in_rootfs_with_bash "/bin/apt update && apt upgrade && apt install -y sudo git"
  run_in_rootfs_with_bash "/sbin/useradd -m builder"
  run_in_rootfs_with_bash "echo 'builder ALL=(ALL:ALL) NOPASSWD: ALL' >> /etc/sudoers"
  run_in_rootfs_with_bash "chsh -s /bin/bash builder"
  
  echo "# RootFS $CODENAME configured"
}

main
