# Move to latest Clear Linux release to ensure
# that the swupd command line arguments are
# correct
RUN swupd update --no-boot-update $swupd_args

# Grab os-release info from the minimal base image so
# that the new content matches the exact OS version
COPY --from=clearlinux/os-core:latest /usr/lib/os-release /

# Install additional content in a target directory
# using the os version from the minimal base
RUN source /os-release && \
    mkdir /install_root \
    && swupd os-install -V ${VERSION_ID} \
    --path /install_root --statedir /swupd-state \
    --bundles=alsa-utils,devpkg-libass,devpkg-opus,devpkg-libsrtp,devpkg-taglib,qt-basic-dev,os-core-update,mpv --no-boot-update \
    && rm -rf /install_root/var/lib/swupd/*

