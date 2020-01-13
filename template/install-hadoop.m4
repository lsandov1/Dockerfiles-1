# Install Hadoop
RUN mkdir -p /usr/share/defaults/hadoop && \
    mkdir -p /usr/share/doc/hadoop && \
    tar -xf /tmp/hadoop-*.tar.gz -C /usr --strip-components=1 && \
    mv /usr/*.txt /usr/share/doc/hadoop && \
    mv /usr/etc/* /usr/share/defaults && \
    find /usr -iname *.cmd -delete && \
    find /usr -iname *.orig -delete && \
    rm -r /usr/etc/

RUN mkdir -p /etc/hadoop && \
    cp -r /usr/share/defaults/hadoop/* /etc/hadoop

COPY hadoop_conf/* /etc/hadoop/
