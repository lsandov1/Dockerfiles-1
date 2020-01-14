ARG VA_GSTREAMER_PLUGINS_VER=0.6.1
ARG VA_GSTREAMER_PLUGINS_REPO=https://github.com/opencv/gst-video-analytics/archive/v${VA_GSTREAMER_PLUGINS_VER}.tar.gz
ARG ENABLE_PAHO_INSTALLATION=OFF
ARG ENABLE_RDKAFKA_INSTALLATION=OFF

RUN wget -O - ${VA_GSTREAMER_PLUGINS_REPO} | tar xz && \
    cd gst-video-analytics-${VA_GSTREAMER_PLUGINS_VER} && \
    mkdir build && \
    cd build && \
    cmake \
    -DVERSION_PATCH=$(echo "$(git rev-list --count --first-parent HEAD)") \
    -DGIT_INFO=$(echo "git_$(git rev-parse --short HEAD)") \
    -DCMAKE_BUILD_TYPE=Release \
    -DDISABLE_SAMPLES=ON \
    -DDISABLE_VAAPI=ON  \
    -DENABLE_PAHO_INSTALLATION=${ENABLE_PAHO_INSTALLATION} \
    -DENABLE_RDKAFKA_INSTALLATION=${ENABLE_RDKAFKA_INSTALLATION} \
    -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=/usr .. && \
    make -j $(nproc) && \
    make install
RUN mkdir -p build/usr/lib64/gstreamer-1.0 && \
    cp -r gst-video-analytics-${VA_GSTREAMER_PLUGINS_VER}/build/intel64/Release/lib/* build/usr/lib64/gstreamer-1.0
RUN mkdir -p /usr/lib64/gstreamer-1.0 && \
    cp -r gst-video-analytics-${VA_GSTREAMER_PLUGINS_VER}/build/intel64/Release/lib/* /usr/lib64/gstreamer-1.0
