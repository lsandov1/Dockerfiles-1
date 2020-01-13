FROM clearlinux/stacks-clearlinux:30960 as apache-build

RUN swupd bundle-add java11-basic curl patch R-basic R-extras time-server-basic machine-learning-pytorch \
    devpkg-openssl kde-frameworks5-dev --no-boot-update

RUN mkdir -p /root/.m2/ /usr/local/bin/apache-spark/ /usr/local/bin/apache-hadoop/ /opt/
WORKDIR /home

# Install Maven
RUN curl -o /opt/apache-maven.tar.gz --silent http://mirror.reverse.net/pub/apache/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz
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
