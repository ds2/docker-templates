#!/usr/bin/env bash
set -euo pipefail #e=exitonfail u=unboundvarsdisallow o=pipefail x=debug

# set ENV vars
export RUST_PROFILE=${RUST_PROFILE:-debug}
export CARGO_BUILD_TARGET=${CARGO_BUILD_TARGET:-'x86_64-unknown-linux-gnu'}
export CARGO_TARGET_DIR=${CARGO_TARGET_DIR:-/tmp/my-rust}
export WORKSPACE_MEMBER=${WORKSPACE_MEMBER:-}
export REL_VERSION=${REL_VERSION:-}
export SEMVER_PARAMS=${SEMVER_PARAMS:-"-a"}
export SRC_DIR=${SRC_DIR:-$(pwd)}
export ARTIFACTS_DIR=${ARTIFACTS_DIR:-/tmp/artifacts}

# execute tests
mkdir -p ${CARGO_TARGET_DIR} ${ARTIFACTS_DIR}
sudo chown -R rusty:users ${CARGO_TARGET_DIR} ${CARGO_HOME}

while getopts ':cbp' OPTION; do
    case "$OPTION" in
    c)
        echo "Cleaning output.."
        cargo clean
        ;;
    b)
        echo "Building binary/binaries.."
        test -n ${RUST_PROFILE}
        rustup target add ${CARGO_BUILD_TARGET}
        if [ -z "${WORKSPACE_MEMBER}" ]; then
            # build all
            cargo build --workspace
        else
            # build only the workspace member
            cargo build -p ${WORKSPACE_MEMBER}
            ${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/${WORKSPACE_MEMBER} --version
        fi
        ;;
    p)
        echo "Perform packaging.."
        if [ -z "$REL_VERSION" ]; then
            echo "Will try to extract release version from toml file.."
            export REL_VERSION=$(cat Cargo.toml | grep "^version" | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?")
        fi
        if [ -z "$REL_VERSION" ]; then
            echo "(WARN) no rel version found. Will try to get it from semver file.."
            if [ -f ".semver-version" ]; then
                REL_VERSION=$(cat .semver-version)
            fi
        fi
        test -n $REL_VERSION
        echo "Release version at least is $REL_VERSION.."
        export SEMVER_VERSION=$(echo $REL_VERSION | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$")
        test -n "${SEMVER_VERSION}" # check if set
        export RPM_VERSION=$(echo $SEMVER_VERSION | grep -Po "(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$")
        export RPM_RELEASE='alpha.1'
        semverBin='semver-formatter'
        if [ -f "${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter" ]; then
            semverBin="${CARGO_TARGET_DIR}/${CARGO_BUILD_TARGET}/${RUST_PROFILE}/semver-formatter"
        fi
        echo "Trying to format $SEMVER_VERSION.."
        version_string="$(${semverBin} -f rpm ${SEMVER_PARAMS} ${SEMVER_VERSION})"
        # echo "Will evaluate: $version_string"
        eval "$version_string"
        echo "Now we should have changed versions: ${RPM_VERSION} and ${RPM_RELEASE}"
        test -n "${RPM_VERSION}"
        export RPM_RELEASE=${RPM_RELEASE:-alpha.1}
        test -n "${RPM_RELEASE}"
        rpmdev-setuptree
        cp --update *.ol8.spec ~/rpmbuild/SPECS/ || true
        cp --update os-packaging/linux/el8/*.ol8.spec ~/rpmbuild/SPECS/ || true
        rpmbuild -bb ~/rpmbuild/SPECS/*.spec
        rpm -qip ~/rpmbuild/RPMS/x86_64/*.rpm
        if [[ ! -d "$ARTIFACTS_DIR" ]]; then
            mkdir ${ARTIFACTS_DIR}
        fi
        cp ~/rpmbuild/RPMS/x86_64/*.rpm ${ARTIFACTS_DIR}/
        cp ~/rpmbuild/RPMS/x86_64/*.rpm ${CARGO_TARGET_DIR}/
        ;;
    \?) echo "Invalid param: $OPTARG" ;;

    *) echo "Unbekannter Parameter" ;;

    esac
done
