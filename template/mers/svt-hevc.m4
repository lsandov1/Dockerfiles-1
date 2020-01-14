ARG SVT_HEVC_VER=v1.4.1
ARG SVT_HEVC_REPO=https://github.com/OpenVisualCloud/SVT-HEVC

ARG AVX512_HEVC_PATCH=0001-disable-AVX512-in-SVT-HEVC-codec.patch
COPY svt-hevc-patches/${AVX512_HEVC_PATCH} /home/

RUN git clone ${SVT_HEVC_REPO} && \
    cd SVT-HEVC/Build/linux && \
    git checkout ${SVT_HEVC_VER} && \
    patch -p1 /home/${AVX512_HEVC_PATCH} && rm /home/${AVX512_HEVC_PATCH} && \
    mkdir -p ../../Bin/Release && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64 -DCMAKE_ASM_NASM_COMPILER=yasm ../.. && \
    make -j $(nproc) && \
    make install DESTDIR=/home/build && \
    make install
