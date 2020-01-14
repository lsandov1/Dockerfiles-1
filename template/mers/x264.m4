ARG X264_VER=3759fcb7b48037a5169715ab89f80a0ab4801cdf
ARG X264_REPO=https://code.videolan.org/videolan/x264.git

RUN  git clone ${X264_REPO} && \
     cd x264 && \
     git checkout ${X264_VER} && \
     ./configure --prefix=/usr --libdir=/usr/lib64 --enable-shared && \
     make -j $(nproc) && \
     make install DESTDIR=/home/build && \
     make install
