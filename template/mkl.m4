RUN swupd bundle-add curl
# fetch MKL library and wrapper
RUN URL='http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15816' && \
    MKL_VERSION='l_mkl_2019.5.281_online' && \
    mkdir /install_root/mkl /install_root/mkl_wrapper && \
    curl ${URL}/${MKL_VERSION}.tgz -o /install_root/mkl/${MKL_VERSION}.tgz && \
    tar -xvf /install_root/mkl/${MKL_VERSION}.tgz -C /install_root/mkl --strip-components=1 && \
    curl -L https://github.com/Intel-bigdata/mkl_wrapper_for_non_CDH/raw/master/mkl_wrapper.jar -o /install_root/mkl_wrapper/mkl_wrapper.jar && \
    curl -L https://github.com/Intel-bigdata/mkl_wrapper_for_non_CDH/raw/master/mkl_wrapper.so  -o /install_root/mkl_wrapper/mkl_wrapper.so
