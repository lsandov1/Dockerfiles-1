###################### dars-cleanup template ######################
RUN /tmp/* && \
    swupd bundle-remove cpio
