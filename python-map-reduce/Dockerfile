FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    ca-certificates \
    curl \
    openjdk-11-jre-headless \
  && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN curl -O https://archive.apache.org/dist/hadoop/core/hadoop-3.3.6/hadoop-3.3.6.tar.gz \
    && tar -xvf hadoop-3.3.6.tar.gz \
    && mv hadoop-3.3.6 /usr/local/hadoop \
    && rm hadoop-3.3.6.tar.gz

ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$HADOOP_HOME/bin:$PATH

WORKDIR /app

COPY average_age.py /app/
COPY requirements.txt /app/

RUN pip3 install --no-cache-dir -r requirements.txt

ENTRYPOINT ["/bin/bash", "-c", "\
    python3 average_age.py \
      -r hadoop \
      --hadoop-tmp-dir hdfs://namenode:9000/mimic/tmp \
      --output-dir hdfs://namenode:9000/mimic/output \
      hdfs://namenode:9000/mimic/PATIENTS.csv \
    && tail -f /dev/null"]