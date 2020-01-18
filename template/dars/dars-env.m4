###################### dars-env template ######################
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
