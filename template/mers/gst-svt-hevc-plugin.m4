COPY svt-hevc-patches/0001-include-pbutils-as-gst-plugin-depedency.patch /home/SVT-HEVC/gstreamer-plugin/

RUN cd SVT-HEVC/gstreamer-plugin && \
    git apply 0001-include-pbutils-as-gst-plugin-depedency.patch && \
    cmake . && \
    make -j$(nproc) && \
    make install DESTDIR=/home/build && \
    make install
