FROM clearlinux:latest AS build
WORKDIR /home

include(dars-build-tools.m4)
#include(mkl.m4)
include(apache-build.m4)

FROM clearlinux/os-core:latest
LABEL maintainer=otc-swstacks@intel.com

COPY --from=apache-build /usr/local/bin/apache-hadoop /tmp/
COPY --from=apache-build /usr/local/bin/apache-spark /tmp/
COPY --from=dars-builder /install_root /

include(install-hadoop.m4)
include(install-spark.m4)
include(dars-env.m4)
#include(install-mkl.m4)
include(dars-cleanup.m4)
