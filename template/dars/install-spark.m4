###################### install-spark template ######################

# Install Spark
RUN mkdir -p /usr/share/apache-spark/ && \
    tar -xf /tmp/spark-*.tgz \
    -C /usr/share/apache-spark  --strip 1 && \
    find /usr/share/apache-spark/bin/ -iname *.cmd -delete && \
    mkdir -p /usr/share/defaults/spark && \
    cp /usr/share/apache-spark/conf/* /usr/share/defaults/spark/ && \
    sed -i 's/-Dmaven.repo.local=\(.*\)\/.m2/-Dmaven.repo.local=BUILDROOT\/.m2/' /usr/share/apache-spark/RELEASE && \
    mkdir -p /usr/bin && \
    cd /usr/share/apache-spark/bin/ && \
    for cmd in beeline pyspark spark-class spark-shell spark-sql spark-submit sparkR; do \
    ln -sf /usr/share/apache-spark/bin/$cmd /usr/bin/$cmd; \
    chmod +x /usr/bin/$cmd; \
    done

RUN mkdir -p /etc/spark && \
    cp /usr/share/apache-spark/conf/log4j.properties.template /etc/spark/log4j.properties

COPY spark_conf/* /etc/spark/
