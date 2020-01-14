RUN cd SVT-AV1/gstreamer-plugin && \
    cmake . && \
    make -j$(nproc) && \
    make install DESTDIR=/home/build && \
    make install
