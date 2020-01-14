# Build Stage: apache tools (build first so cache is reused by dars/openblas)

FROM clearlinux/stacks-clearlinux:30960 as apache-build

RUN swupd bundle-add java11-basic curl patch R-basic R-extras time-server-basic machine-learning-pytorch \
    devpkg-openssl kde-frameworks5-dev --no-boot-update

RUN mkdir -p /root/.m2/ /usr/local/bin/apache-spark/ /usr/local/bin/apache-hadoop/ /opt/
WORKDIR /home

# Install Maven
RUN curl -o /opt/apache-maven.tar.gz http://mirror.reverse.net/pub/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
RUN tar xzf /opt/apache-maven.tar.gz --directory /opt
ENV M2_HOME="/opt/apache-maven-3.6.2"
ENV PATH=${PATH}:/opt/apache-maven-3.6.2/bin
RUN ln -sf /opt/apache-maven-3.6.2/bin/mvn /usr/bin/mvn
ARG maven_opts
ENV MAVEN_OPTS=$maven_opts

ENV JAVA_HOME='/usr/lib/jvm/java-1.11.0-openjdk'

# Build Hadoop
RUN curl -LO --silent https://archive.apache.org/dist/hadoop/common/hadoop-3.2.0/hadoop-3.2.0-src.tar.gz
RUN tar xzf hadoop-3.2.0-src.tar.gz

COPY patches/hadoop/ hadoop_patches/
RUN cd hadoop-3.2.0-src && \
    patch -p1 < ../hadoop_patches/0001-Integrate-JDK11.patch && \
    patch -p1 < ../hadoop_patches/0001-Java_home-on-CLR.patch && \
    patch -p1 < ../hadoop_patches/HADOOP-11364.01.patch && \
    patch -p1 < ../hadoop_patches/0001-Stateless-v2.patch && \
    patch -p1 < ../hadoop_patches/0001-Change-protobuf-version.patch && \
    patch -p1 < ../hadoop_patches/protobuf3.patch && \
    patch -p1 < ../hadoop_patches/protobuf-3.6.1-hadoop-3.2.0-On-CLR.patch && \
    patch -p1 < ../hadoop_patches/0001-YARN-8498.-Yarn-NodeManager-OOM-Listener-Fails-Compi.patch

RUN cd hadoop-3.2.0-src && \
    mvn package -q -fae -Pnative -Pdist -DskipTests -Dtar -Danimal.sniffer.skip=true -Dmaven.javadoc.skip=true \
    -Djavac.version=11 -Dguava.version=19.0 -Dmaven.plugin-tools.version=3.6.0

# Build Spark
RUN curl -LO --silent https://archive.apache.org/dist/spark/spark-2.4.0/spark-2.4.0.tgz
RUN tar xzf spark-2.4.0.tgz
COPY patches/spark/ spark_patches/

RUN cd spark-2.4.0/ && \
    patch -p1 < ../spark_patches/Add-javax.ws.rs-in-core-pom.xml.patch && \
    patch -p1 < ../spark_patches/Dont-generate-SparkR-docs.patch && \
    patch -p1 < ../spark_patches/spark-script.patch && \
    patch -p1 < ../spark_patches/stateless.patch && \
    patch -p1 < ../spark_patches/R-pkg-allow-java11.patch && \
    patch -p1 < ../spark_patches/spark-java11-aggregated-changes.patch && \
    patch -p1 < ../spark_patches/sparkr-vignettes-fix.patch && \
    patch -p1 < ../spark_patches/set-jar-full-pathname.patch

RUN cd spark-2.4.0/ && \
    ./dev/change-scala-version.sh 2.12 && \
    ./dev/make-distribution.sh --mvn \
    mvn --name custom-spark --pip --r --tgz \
    -Dhadoop.version=3.2.0 -Phadoop-3 -Phive -Phive-thriftserver -Dzookeeper.version=3.4.13 \
    -Pkubernetes -Pmesos -Pscala-2.12 -Psparkr -Pyarn -Pnetlib-lgpl --fae >> /dev/null

# Move components
RUN cd hadoop-3.2.0-src && \
    mv hadoop-dist/target/hadoop-*.tar.gz /usr/local/bin/apache-hadoop
RUN cd spark-2.4.0/ && \
    mv spark-2.4.0-bin-custom-spark.tgz /usr/local/bin/apache-spark

# Clean up
RUN rm -rf /home/* /tmp/* /opt/*


# Build Stage: install tools
FROM clearlinux:latest AS build
WORKDIR /home


# Common Build Tools
ARG swupd_args

# Move to latest Clear Linux release to ensure
# that the swupd command line arguments are
# correct
RUN swupd update --no-boot-update $swupd_args

# Grab os-release info from the minimal base image so
# that the new content matches the exact OS version
COPY --from=clearlinux/os-core:latest /usr/lib/os-release /

ARG BUILD_BUNDLES=os-core-update,cpio,which,java11-basic

# Install additional content in a target directory
# using the os version from the minimal base
RUN source /os-release && \
    mkdir /install_root \
    && swupd os-install -V ${VERSION_ID} \
    --path /install_root --statedir /swupd-state \
    --bundles=${BUILD_BUNDLES} --no-boot-update \
    && rm -rf /install_root/var/lib/swupd/*


RUN swupd bundle-add curl
# fetch MKL library and wrapper
RUN URL='http://registrationcenter-download.intel.com/akdlm/irc_nas/tec/15816' && \
    MKL_VERSION='l_mkl_2019.5.281_online' && \
    mkdir /install_root/mkl /install_root/mkl_wrapper && \
    curl ${URL}/${MKL_VERSION}.tgz -o /install_root/mkl/${MKL_VERSION}.tgz && \
    tar -xvf /install_root/mkl/${MKL_VERSION}.tgz -C /install_root/mkl --strip-components=1 && \
    curl -L https://github.com/Intel-bigdata/mkl_wrapper_for_non_CDH/raw/master/mkl_wrapper.jar -o /install_root/mkl_wrapper/mkl_wrapper.jar && \
    curl -L https://github.com/Intel-bigdata/mkl_wrapper_for_non_CDH/raw/master/mkl_wrapper.so  -o /install_root/mkl_wrapper/mkl_wrapper.so


# Final Stage
FROM clearlinux/os-core:latest
LABEL maintainer=otc-swstacks@intel.com

COPY --from=apache-build /usr/local/bin/apache-hadoop /tmp/
COPY --from=apache-build /usr/local/bin/apache-spark /tmp/
COPY --from=build /install_root /

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

# Configure openjdk11
ENV JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Environment variables to point to Hadoop,
# Spark and YARN installation and configuration
ENV HADOOP_HOME=/usr
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV HADOOP_DEFAULT_LIBEXEC_DIR=$HADOOP_HOME/libexec
ENV HADOOP_IDENT_STRING=root
ENV HADOOP_LOG_DIR=/var/log/hadoop
ENV HADOOP_PID_DIR=/var/log/hadoop/pid
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"

ENV HDFS_DATANODE_USER=root
ENV HDFS_NAMENODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root

ENV SPARK_HOME=/usr/share/apache-spark
ENV SPARK_CONF_DIR=/etc/spark

ENV YARN_RESOURCEMANAGER_USER=root
ENV YARN_NODEMANAGER_USER=root

COPY dars.ld.so.conf /etc/ld.so.conf
COPY silent.cfg /mkl

RUN /mkl/install.sh -s /mkl/silent.cfg && \   
    ldconfig

RUN rm -rf /mkl_wrapper /mkl

COPY dars.ld.so.conf /etc/ld.so.conf
RUN ldconfig

RUN /tmp/* && \
    swupd bundle-remove cpio

CMD ["/bin/bash"]

