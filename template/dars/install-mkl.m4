COPY dars.ld.so.conf /etc/ld.so.conf
COPY silent.cfg /mkl

RUN /mkl/install.sh -s /mkl/silent.cfg && \   
    ldconfig

RUN rm -rf /mkl_wrapper /mkl
