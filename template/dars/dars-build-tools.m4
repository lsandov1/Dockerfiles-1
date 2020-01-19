

###################### dars-build-tools template ######################
# Common Build Tools
ARG swupd_args

# Move to latest Clear Linux release to ensure
# that the swupd command line arguments are
# correct
RUN swupd update --no-boot-update $swupd_args

# Grab os-release info from the minimal base image so
# that the new content matches the exact OS version
COPY --from=clearlinux/os-core:latest /usr/lib/os-release /

ifelse(index(DOCKER_IMAGE,mkl),-1,dnl
ARG BUILD_BUNDLES=`os-core-update,python-basic-dev,which,java11-basic,openblas',
dnl
ARG BUILD_BUNDLES=`os-core-update,cpio,which,java11-basic'
)dnl

# Install additional content in a target directory
# using the os version from the minimal base
RUN source /os-release && \
    mkdir /install_root \
    && swupd os-install -V ${VERSION_ID} \
    --path /install_root --statedir /swupd-state \
    --bundles=${BUILD_BUNDLES} --no-boot-update \
    && rm -rf /install_root/var/lib/swupd/*

