#!/usr/bin/env bash

set -euo pipefail #e=exitonfail u=unboundvarsdisallow o=pipefail x=debug
unalias cp || true

# set ENV vars
export SRC_DIR=$(pwd)
export BUILD_ARGS=${BUILD_ARGS:-}
export NEW_SRC_DIR=${NEW_SRC_DIR:-/tmp/work-mirrored}
MIRROR_SRC_DIR=${MIRROR_SRC_DIR:-}
export ARTIFACTS_DIR=${ARTIFACTS_DIR:-${SRC_DIR}/out}
export ARTIFACTS_DIR=$(readlink -f $ARTIFACTS_DIR)

if [[ ! -z "$MIRROR_SRC_DIR" ]]; then
    mkdir $NEW_SRC_DIR
    echo "Using new src dir $NEW_SRC_DIR to address user permissions.."
    cp -R $SRC_DIR/* $NEW_SRC_DIR/
    cp -R $SRC_DIR/.* $NEW_SRC_DIR/
    cd $NEW_SRC_DIR
fi

echo "Running in $(pwd) :)"

export CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-$(pwd)/target}
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-x86_64-unknown-linux-gnu}
export RUST_PROFILE=${RUST_PROFILE:-debug}
export REL_VERSION=${REL_VERSION:-}           # this is our target version; given as semver
export SEMVER_PARAMS=${SEMVER_PARAMS:-}       # if we want to override some values
export WORKSPACE_MEMBER=${WORKSPACE_MEMBER:-} # in case in a multi module project we only want to build one member

function get_os_name() {
    local rc=""
    if [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        rc=$(echo $PLATFORM_ID | tr -dc '0-9')
    fi
    if [[ -z "$rc" ]]; then
        echo "Could not find os name!"
        exit 1
    fi
    echo "${rc}"
}

function build_workspace() {
    test -n "${RUST_PROFILE}"
    rustup target add "${CARGO_BUILD_TARGET}"
    #cargo clean
    echo "Building binary/binaries.."
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
    rpmdev-setuptree
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
        SRC_PACKAGE_ROOT="$packageId"
        local countSpecs=$(ls -1 ${SRC_PACKAGE_ROOT}/*.spec 2>/dev/null | wc -l)
        local countDeb=$(ls -1 ${SRC_PACKAGE_ROOT}/debian.control 2>/dev/null | wc -l)
        if [[ $countSpecs -eq 0 ]]; then
            echo "No manifest file found, ignoring directory"
            continue
        fi
        if [[ -f "$SRC_PACKAGE_ROOT/project.spec" ]]; then
            # default way in case we do not have a dep for the RHEL version
            cp --update $SRC_PACKAGE_ROOT/project.spec ~/rpmbuild/SPECS/${packageId}.spec || true
        fi
        # new way to look for RHEL stuff from root dir
        cp --update $SRC_PACKAGE_ROOT/project.el${RHEL_NUMBER}.spec ~/rpmbuild/SPECS/${packageId}.spec || true
        # old way to look for OracleLinux stuff
        cp --update $SRC_PACKAGE_ROOT/project.ol${RHEL_NUMBER}.spec ~/rpmbuild/SPECS/${packageId}.spec || true
        if [[ -f "./$SRC_PACKAGE_ROOT/prepare.sh" ]]; then
            echo "Preparing package.."
            . "./$SRC_PACKAGE_ROOT/prepare.sh"
        fi

        # build package
        rpmbuild -bb ~/rpmbuild/SPECS/${packageId}.spec

        # verify package
        rpm -qip ~/rpmbuild/RPMS/x86_64/${packageId}*.rpm
        rpm -q --list -p ~/rpmbuild/RPMS/x86_64/${packageId}*.rpm

        # copy package to artifacts directory
        echo "Copying artifact to output directory.."
        cp ~/rpmbuild/RPMS/x86_64/${packageId}*.rpm "${ARTIFACTS_DIR}/"
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

RHEL_NUMBER=$(get_os_name)
test -n $RHEL_NUMBER

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
version_string="$(${semverBin} -f rpm ${SEMVER_PARAMS} ${SEMVER_VERSION})"
# echo "Will evaluate: $version_string"
eval "$version_string"

build_packages

echo "Artifacts:"
ls $ARTIFACTS_DIR/*.rpm
