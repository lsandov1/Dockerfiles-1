# Build Stage: apache tools (build first so cache is reused by dars/openblas)
include(apache-build.m4)

# Build Stage: install tools
FROM clearlinux:latest AS build
WORKDIR /home

include(dars-build-tools.m4)
include(fetch-mkl.m4)

# Final Stage
FROM clearlinux/os-core:latest
LABEL maintainer=otc-swstacks@intel.com

COPY --from=apache-build /usr/local/bin/apache-hadoop /tmp/
COPY --from=apache-build /usr/local/bin/apache-spark /tmp/
COPY --from=build /install_root /

include(install-hadoop.m4)
include(install-spark.m4)
include(dars-env.m4)
include(install-mkl.m4)
include(dars-ldconf.m4)
include(dars-cleanup.m4)
include(dars-cmd.m4)
