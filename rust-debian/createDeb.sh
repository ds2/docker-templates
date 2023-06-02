#!/usr/bin/env bash

set -euo pipefail #e=exitonfail u=unboundvarsdisallow o=pipefail x=debug

echo "I am $(id) and will perform the build process :)"

unalias cp || true

# set ENV vars
export SRC_DIR=$(pwd)
export BUILD_ARGS=${BUILD_ARGS:-}
export NEW_SRC_DIR=${NEW_SRC_DIR:-/tmp/work-mirrored}
MIRROR_SRC_DIR=${MIRROR_SRC_DIR:-}
export ARTIFACTS_DIR=${ARTIFACTS_DIR:-${SRC_DIR}/out}
export ARTIFACTS_DIR=$(readlink -f $ARTIFACTS_DIR)
export SUDO_CLEAN_TARGET=${SUDO_CLEAN_TARGET:-0}
export PERFORM_CLEAN_TARGET=${PERFORM_CLEAN_TARGET:-0}

if [[ ! -z "$MIRROR_SRC_DIR" ]]; then
  mkdir $NEW_SRC_DIR
  echo "Using new src dir $NEW_SRC_DIR to address user permissions.."
  cp -R $SRC_DIR/* $NEW_SRC_DIR/
  cp -R $SRC_DIR/.* $NEW_SRC_DIR/
  cd $NEW_SRC_DIR
fi

echo "Running in $(pwd) :)"

export CARGO_TARGET_DIR=$(readlink -f "$CARGO_TARGET_DIR")
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-x86_64-unknown-linux-gnu}
export RUST_PROFILE=${RUST_PROFILE:-debug}
export REL_VERSION=${REL_VERSION:-}           # this is our target version; given as semver
export SEMVER_PARAMS=${SEMVER_PARAMS:-}       # if we want to override some values
export WORKSPACE_MEMBER=${WORKSPACE_MEMBER:-} # in case in a multi module project we only want to build one member

function get_os_name() {
  local rc=""
  if [[ -f "/etc/os-release" ]]; then
    source /etc/os-release
    rc=$VERSION_CODENAME
  fi
  if [[ -z "$rc" ]]; then
    echo "Could not find os name!"
    exit 1
  fi
  echo $rc
}

function build_workspace() {
  echo "Setting build target to $CARGO_BUILD_TARGET"
  test -n "${RUST_PROFILE}"
  rustup target add "${CARGO_BUILD_TARGET}"
  test -n "$CARGO_TARGET_DIR"
  if [[ ! -w "$CARGO_TARGET_DIR" ]]; then
    echo "Cannot write target directory?? I will change the target dir for now to a temporary directory."
    export CARGO_TARGET_DIR=/tmp/my-temp-rust-cargo-target-dir
  fi
  if [ $SUDO_CLEAN_TARGET -ge 1 -a -d "$CARGO_TARGET_DIR" ]; then
    echo "Sudoing the target directory $CARGO_TARGET_DIR.."
    sudo rm -rf "$CARGO_TARGET_DIR"
  else
    echo "Will not sudo removing the target directory $CARGO_TARGET_DIR. This is ok :)"
  fi
  if [ $PERFORM_CLEAN_TARGET -ge 1 ]; then
    echo "Cleaning cargo.."
    cargo clean
  fi
  if [ ! -d "$CARGO_TARGET_DIR" ]; then
    echo "Creating target directory $CARGO_TARGET_DIR .."
    sudo install -o rusty -g users -m 0777 -d "$CARGO_TARGET_DIR"
  fi
  echo "Building binary/binaries.."
  ls -alFh $CARGO_TARGET_DIR
  if [ "release" == "$RUST_PROFILE" ]; then
    BUILD_ARGS+=" --release"
  fi
  if [ -z "${WORKSPACE_MEMBER}" ]; then
    # build all
    cargo build $BUILD_ARGS --workspace
  else
    # build only the workspace member
    cargo build $BUILD_ARGS -p "${WORKSPACE_MEMBER}"
    # test if it works
    "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/${WORKSPACE_MEMBER}" --version
  fi
}

function build_packages() {
  BUILD_ROOT="/tmp/debmkp"

  cd "os-packaging/linux"
  packages=$(ls -d */)
  echo "Packages: $packages"

  for p in $packages; do
    if [[ $p == "." ]]; then
      continue
    fi
    packageId=${p/\//}
    echo "Testing package $packageId.."
    export BUILD_PACKAGE_ROOT="$BUILD_ROOT/${packageId}_${DEB_VERSION}-${DEB_REVISION}_amd64"
    SRC_PACKAGE_ROOT="$packageId"
    local countSpecs=$(ls -1 ${SRC_PACKAGE_ROOT}/*.spec 2>/dev/null | wc -l)
    local countDeb=$(ls -1 ${SRC_PACKAGE_ROOT}/debian.control 2>/dev/null | wc -l)
    mkdir -p "$BUILD_PACKAGE_ROOT/DEBIAN"
    mkdir -p "$BUILD_PACKAGE_ROOT/usr/local/bin"
    if [[ $countDeb -eq 0 ]]; then
      echo "No manifest file found, ignoring directory"
      continue
    fi
    cp "$SRC_PACKAGE_ROOT/debian.control" "$BUILD_PACKAGE_ROOT/DEBIAN/control"
    if [[ -f "./$SRC_PACKAGE_ROOT/prepare.sh" ]]; then
      echo "Preparing package.."
      . "./$SRC_PACKAGE_ROOT/prepare.sh"
    else
      # assert that we only have a single binary
      cp "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/${packageId}" "$BUILD_PACKAGE_ROOT/usr/local/bin/${packageId}"
    fi
    echo "Version: ${DEB_VERSION}-${DEB_REVISION}" >>"${BUILD_PACKAGE_ROOT}/DEBIAN/control"

    # build package
    dpkg-deb --build --root-owner-group "${BUILD_PACKAGE_ROOT}"

    # verify package
    dpkg-deb --info "${BUILD_PACKAGE_ROOT}.deb"
    dpkg --contents "${BUILD_PACKAGE_ROOT}.deb"

    # copy package to artifacts directory
    echo "Copying artifacts to output directory.."
    cp "${BUILD_PACKAGE_ROOT}.deb" "${ARTIFACTS_DIR}/"
  done
}

echo "Preparations.."

if [[ ! -d "$ARTIFACTS_DIR" ]]; then
  echo "Creating artifacts directory in $ARTIFACTS_DIR .."
  install -m 0755 -d $ARTIFACTS_DIR
else
  echo "Artifacts will be put into $ARTIFACTS_DIR. Please check if this directory has the right permissions!"
  if [[ ! -w "$ARTIFACTS_DIR" ]]; then
    echo "Cannot write to artifacts directory $ARTIFACTS_DIR ! Please check."
    exit 3
  fi
fi
echo "Testing write to artifacts directory.."
touch "$ARTIFACTS_DIR/.$(date | sha256sum).log"

build_workspace

echo "Perform packaging.."
if [ -z "$REL_VERSION" ]; then
  # first try
  echo "Will try to extract release version from toml file.."
  REL_VERSION=$(cat Cargo.toml | grep "^version" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?")
  export REL_VERSION
fi
if [ -z "$REL_VERSION" ]; then
  # second try
  echo "(WARN) no rel version found. Will try to get it from semver file (if found).."
  if [ -f ".semver-version" ]; then
    REL_VERSION=$(cat .semver-version)
  fi
fi
test -n "$REL_VERSION"
echo "Release version at least is $REL_VERSION.."
SEMVER_VERSION=$(echo "$REL_VERSION" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$")
export SEMVER_VERSION
test -n "${SEMVER_VERSION}" # check if set
echo "SEMVER_VERSION is set to $SEMVER_VERSION"

echo "Setting default build env vars"
RPM_VERSION=$(echo "$SEMVER_VERSION" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")
export RPM_VERSION
export RPM_RELEASE='alpha.1'

semverBin='semver-formatter'

if [ -f "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter" ]; then
  semverBin="${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter"
fi
echo "Trying to format $SEMVER_VERSION.."
version_string="$(${semverBin} -f deb ${SEMVER_PARAMS} ${SEMVER_VERSION})"
# echo "Will evaluate: $version_string"
eval "$version_string"

build_packages

echo "Artifacts:"
ls $ARTIFACTS_DIR/*.deb
