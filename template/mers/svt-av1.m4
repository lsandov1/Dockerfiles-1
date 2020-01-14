# Fetch SVT-AV1
ARG SVT_AV1_VER=v0.7.0
ARG SVT_AV1_REPO=https://github.com/OpenVisualCloud/SVT-AV1

ARG AVX512_AV1_PATCH=0001-disable-AVX512-in-SVT-AV1-codec.patch
COPY svt-av1-patches/${AVX512_AV1_PATCH} /home/

RUN git clone ${SVT_AV1_REPO} && \
    cd SVT-AV1/Build/linux && \
    git checkout ${SVT_AV1_VER} && \
    patch -p1 /home/${AVX512_AV1_PATCH} && rm /home/${AVX512_AV1_PATCH} && \
    mkdir -p ../../Bin/Release && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=lib64 -DCMAKE_ASM_NASM_COMPILER=yasm ../.. && \
    make -j8 && \
    make install DESTDIR=/home/build && \
    make install
