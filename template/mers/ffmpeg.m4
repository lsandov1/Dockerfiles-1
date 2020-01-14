# Fetch FFmpeg source
ARG FFMPEG_VER=n4.1.4
ARG FFMPEG_REPO=https://github.com/FFmpeg/FFmpeg/archive/${FFMPEG_VER}.tar.gz

ARG FFMPEG_1TN_PATCH_REPO=https://patchwork.ffmpeg.org/patch/11625/raw
ARG FFMPEG_THREAD_PATCH_REPO=https://patchwork.ffmpeg.org/patch/11035/raw

ARG FFMPEG_PATCHES_RELEASE_VER=0.1
ARG FFMPEG_PATCHES_RELEASE_URL=https://github.com/VCDP/CDN/archive/v${FFMPEG_PATCHES_RELEASE_VER}.tar.gz
ARG FFMPEG_PATCHES_PATH=/home/CDN-${FFMPEG_PATCHES_RELEASE_VER}
RUN wget -O - ${FFMPEG_PATCHES_RELEASE_URL} | tar xz

ARG FFMPEG_MA_RELEASE_VER=0.2
ARG FFMPEG_MA_RELEASE_URL=https://github.com/VCDP/FFmpeg-patch/archive/v${FFMPEG_MA_RELEASE_VER}.tar.gz
ARG FFMPEG_MA_PATH=/home/FFmpeg-patch-${FFMPEG_MA_RELEASE_VER}
RUN wget -O - ${FFMPEG_MA_RELEASE_URL} | tar xz

RUN wget -O - ${FFMPEG_REPO} | tar xz && mv FFmpeg-${FFMPEG_VER} FFmpeg && \
    cd FFmpeg && \
    wget -O - https://git.ffmpeg.org/gitweb/ffmpeg.git/commitdiff_plain/434588596fef6bd2cef17f8c9c2979a010153edd | patch -p1 && \
    wget -O - https://git.ffmpeg.org/gitweb/ffmpeg.git/commitdiff_plain/02f909dc24b1f05cfbba75077c7707b905e63cd2 | patch -p1 && \
    find ${FFMPEG_PATCHES_PATH}/FFmpeg_patches -type f -name '0001*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i && \
    wget -O - ${FFMPEG_1TN_PATCH_REPO} | patch -p1 && \
    wget -O - ${FFMPEG_THREAD_PATCH_REPO} | patch -p1  && \
    find ${FFMPEG_MA_PATH}/media-analytics -type f -name '*.patch' -print0 | sort -z | xargs -t -0 -n 1 patch -p1 -i;

# Patch FFmpeg source for SVT-HEVC
RUN cd FFmpeg && \
    patch -p1 < ../SVT-HEVC/ffmpeg_plugin/0001-lavc-svt_hevc-add-libsvt-hevc-encoder-wrapper.patch;

# Patch FFmpeg source for SVT-AV1
RUN cd FFmpeg; \
    patch -p1 < ../SVT-AV1/ffmpeg_plugin/0001-Add-ability-for-ffmpeg-to-run-svt-av1-with-svt-hevc.patch;

# Patch for CLR build issues
COPY ffmpeg-patches/* ffmpeg-patches/
RUN cd FFmpeg; \
    for file in ../ffmpeg-patches/*.patch; do patch -p1 < $file; done

# Compile FFmpeg (base on http://kojiclear.jf.intel.com/cgit/packages/not-ffmpeg/plain/configure + MeRS codecs and tools)
ARG MERS_ENABLE_ENCODERS=libsvt_hevc,libsvt_av1,libx264
ARG MERS_ENABLE_DECODERS=h264,hevc,libaom_av1
ARG MERS_ENABLE_MUXERS=mp4
ARG MERS_ENABLES="--enable-libsvthevc --enable-libsvtav1 --enable-nonfree --enable-gpl --enable-libx264"
ARG MERS_OTHERS="--enable-ffprobe"

RUN cd FFmpeg && \
    ./configure \
    --disable-static \
    --extra-ldflags='-ldl' \
    --disable-everything \
    --enable-avcodec \
    --enable-avformat \
    --enable-avutil \
    --enable-avdevice \
    --enable-rdft \
    --enable-pixelutils \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-muxer="crc,image2,jpeg,ogg,md5,nut,webm,webm_chunk,webm_dash_manifest,rawvideo,ivf,null,wav,framecrc,rtp,rtsp,ass,webvtt,mjpeg,framehash,hash,${MERS_ENABLE_MUXERS}" \
    --enable-bsf="mp3_header_decompress,vp9_superframe" \
    --enable-demuxer="mjpeg,image2,webm_dash_manifest,ogg,matroska,mp3,pcm_s16le,rawvideo,wav,mov,ivf,rtp,rtsp,flv,ass,subviewer,subviewer1,webvtt" \
    --enable-decoder="rawvideo,libvorbis,mjpeg,jpeg,opus,mp3,pcm_u8,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_s16be,pcm_s24be,pcm_mulaw,pcm_alaw,pcm_u24le,pcm_u32be,pcm_u32le,pgm,pgmyuv,libvpx_vp8,vp8_qsv,vp8,libvpx_vp9,vp9,tiff,bmp,wavpack,ass,saa,subviewer,subviewer1,webvtt,${MERS_ENABLE_DECODERS}" \
    --enable-encoder="rawvideo,wrapped_avframe,libvorbis,opus,yuv4,tiff,bmp,libvpx_vp8,vp8_vaapi,libvpx_vp9,vp9_vaapi,mjpeg_vaapi,pcm_u8,pcm_s16le,pcm_s24le,pcm_s32le,pcm_f32le,pcm_s16be,pcm_s24be,pcm_mulaw,pcm_alaw,pcm_u24le,pcm_u32be,pcm_u32le,ass,ssa,webvtt,mjpeg_qsv,${MERS_ENABLE_ENCODERS}" \
    --enable-hwaccel="vp8_vaapi,vp9_vaapi,mjpeg_vaapi" \
    --enable-parser="opus,libvorbis,vp3,vp8,vp9,mjpeg" \
    --enable-protocol="file,md5,pipe,rtp,tcp,http,https,httpproxy,ftp,librtmp,librtmpe,librtmps,librtmpt,librtmpte,rtmpe,rtmps,rtmpt,rtmpte,rtmpts" \
    --enable-filter="aresample,asetpts,denoise_vaapi,deinterlace_vaapi,hwupload,hwdownload,pixdesctest,procamp_vaapi,scale,scale_vaapi,sharpness_vaapi,color,format,subtitles,select,setpts" \
    --disable-error-resilience \
    --enable-pic \
    --enable-shared \
    --enable-swscale \
    --enable-avfilter \
    --enable-vaapi \
    --enable-libmfx \
    --disable-xvmc \
    --disable-doc \
    --disable-htmlpages \
    --enable-version3 \
    --disable-mmx \
    --disable-mmxext \
    --disable-programs \
    --enable-ffmpeg \
    --enable-ffplay \
    --enable-sdl2 \
    --enable-network \
    --enable-openssl \
    --enable-librtmp \
    --enable-libv4l2 \
    --enable-indev=v4l2 \
    --enable-libass \
    ${MERS_ENABLES} \
    ${MERS_OTHERS} && \
    make -j $(nproc) && \
    make install DESTDIR=/home/build && \
    make install
