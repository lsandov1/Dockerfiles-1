FROM clearlinux:latest AS build
WORKDIR /home

include(dars-build-tools.m4)
include(mkl.m4)

FROM clearlinux/os-core:latest
LABEL maintainer=otc-swstacks@intel.com

# TODO
# include(apache-build.m4)
# include(hadoop.m4)
# include(spark.m4)
# include(dars-env.m4)
# include(install.mkl.m4)

