#!/usr/bin/env bash

set -euo pipefail

SRC_DIR=$(pwd)
export SRC_DIR
export CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-$(pwd)/target}
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-x86_64-unknown-linux-gnu}
export RUST_PROFILE=${RUST_PROFILE:-debug}
export REL_VERSION=${REL_VERSION:-}           # this is our target version; given as semver
export SEMVER_PARAMS=${SEMVER_PARAMS:-}       # if we want to override some values
export WORKSPACE_MEMBER=${WORKSPACE_MEMBER:-} # in case in a multi module project we only want to build one member
export ARTIFACTS_DIR=${ARTIFACTS_DIR:-${SRC_DIR}/out}

test -n "${RUST_PROFILE}"
rustup target add "${CARGO_BUILD_TARGET}"
#cargo clean
echo "Building binary/binaries.."
if [ -z "${WORKSPACE_MEMBER}" ]; then
  # build all
  cargo build --workspace
else
  # build only the workspace member
  cargo build -p "${WORKSPACE_MEMBER}"
  # test if it works
  "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/${WORKSPACE_MEMBER}" --version
fi
if [ -z "$REL_VERSION" ]; then
  echo "Will try to extract release version from toml file.."
  REL_VERSION=$(cat Cargo.toml | grep "^version" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?")
  export REL_VERSION
fi
if [ -z "$REL_VERSION" ]; then
  echo "(WARN) no rel version found. Will try to get it from semver file.."
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
RPM_VERSION=$(echo "$SEMVER_VERSION" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)")
export RPM_VERSION
export RPM_RELEASE='alpha.1'
echo "RPM set"
semverBin='semver-formatter'

if [ -f "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter" ]; then
  semverBin="${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter"
fi
echo "Trying to format $SEMVER_VERSION.."
version_string="$(${semverBin} -f deb ${SEMVER_PARAMS} ${SEMVER_VERSION})"
# echo "Will evaluate: $version_string"
eval "$version_string"

BUILD_ROOT="/tmp/debmkp"

if [[ ! -d "os-packaging/linux/deb" ]]; then
  echo "No debian os packaging directory found!"
  exit 2
fi
cd "os-packaging/linux/deb"
packages=$(ls -d */)
echo "Packages: $packages"

for p in $packages; do
  if [[ $p == "." ]]; then
    continue
  fi
  packageId=${p/\//}
  echo "Building package $packageId.."
  export BUILD_PACKAGE_ROOT="$BUILD_ROOT/${packageId}_${DEB_VERSION}-${DEB_REVISION}_amd64"
  SRC_PACKAGE_ROOT="$packageId"
  mkdir -p "$BUILD_PACKAGE_ROOT/DEBIAN"
  mkdir -p "$BUILD_PACKAGE_ROOT/usr/local/bin"
  cp "$SRC_PACKAGE_ROOT/debian.control" "$BUILD_PACKAGE_ROOT/DEBIAN/control"
  if [[ -f "./$SRC_PACKAGE_ROOT/prepare.sh" ]]; then
      . "./$SRC_PACKAGE_ROOT/prepare.sh"
  else
    # assert that we only have a single binary
    cp "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/${packageId}" "$BUILD_PACKAGE_ROOT/usr/local/bin/${packageId}"
  fi

  echo "Version: ${DEB_VERSION}-${DEB_REVISION}" >>"${BUILD_PACKAGE_ROOT}/DEBIAN/control"
  dpkg-deb --build --root-owner-group "${BUILD_PACKAGE_ROOT}"
  dpkg-deb --info "${BUILD_PACKAGE_ROOT}.deb"
  dpkg --contents "${BUILD_PACKAGE_ROOT}.deb"
  mkdir -p "$ARTIFACTS_DIR" || true
  cp "${BUILD_PACKAGE_ROOT}.deb" "${ARTIFACTS_DIR}/"
done
