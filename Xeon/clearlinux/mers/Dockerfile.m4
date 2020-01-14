FROM clearlinux:latest AS tools

include(build-tools.m4)

FROM clearlinux:latest AS build
WORKDIR /home

COPY --from=mers-build-tools /install_root /
ENV GCC_IGNORE_WERROR=1

ifelse(defn(`BUILD_X264'),`ON',`include(x264.m4)')

# Transcoding
include(svt-hevc.m4)
include(svt-av1.m4)
include(ffmpeg.m4)

# Video Analytics
include(gst.m4)
include(gst-plugins-base.m4)
include(gst-plugins-good.m4)
include(gst-plugins-bad.m4)
include(gst-plugins-ugly.m4)
include(gst-svt-hevc-plugin.m4)
include(gst-svt-av1-plugin.m4)
include(gst-libav.m4)
include(opencv.m4)
include(dldt.m4)
include(gst-video-analytics.m4)
include(build-cleanup.m4)

# Bundle Stage
FROM clearlinux:latest AS bundles

include(bundles.m4)

# Final stage
FROM clearlinux/os-core:latest
LABEL Description="This is the image for Media Stacks on ClearLinux OS"
LABEL Vendor="Intel Corporation"
LABEL maintainer=otc-swstacks@intel.com

COPY --from=bundles /install_root /
COPY --from=build /home/build /
COPY scripts/entrypoint.sh scripts/docker-healthcheck /usr/bin/

include(env.m4)
include(user.m4)
HEALTHCHECK --interval=15s CMD ["docker-healthcheck"]
include(entrypoint.m4)

