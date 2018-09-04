FROM ubuntu:16.04
MAINTAINER Ruslan Gainutdinov <ruslanfg@gmail.com>

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables && \
    apt-get upgrade -y
    
# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# JDK version info from 
# http://www.oracle.com/technetwork/java/javase/downloads/index.html
ENV DEBIAN_FRONTEND noninteractive
ENV VERSION 8
ENV UPDATE 181
ENV BUILD 13
ENV SIG 96a7b8442fe848ef90c96a2fad6ed6d1
ENV JAVA_HOME /usr/lib/jvm/java-${VERSION}-oracle
ENV JRE_HOME ${JAVA_HOME}/jre

RUN apt-get update && apt-get install locales ca-certificates curl unzip netcat wget git \
	-y --no-install-recommends && \
	locale-gen en_US.UTF-8 && \
	localedef -i en_US -c -f UTF-8 en_US.UTF-8 && \
	curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
	--header "Cookie: oraclelicense=accept-securebackup-cookie;" \
	http://download.oracle.com/otn-pub/java/jdk/"${VERSION}"u"${UPDATE}"-b"${BUILD}"/"${SIG}"/jdk-"${VERSION}"u"${UPDATE}"-linux-x64.tar.gz \
	| tar xz -C /tmp && \
	mkdir -p /usr/lib/jvm && mv /tmp/jdk1.${VERSION}.0_${UPDATE} "${JAVA_HOME}" 

RUN apt-get autoclean && apt-get --purge -y autoremove && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN update-alternatives --install "/usr/bin/java" "java" "${JRE_HOME}/bin/java" 1 && \
	update-alternatives --install "/usr/bin/javaws" "javaws" "${JRE_HOME}/bin/javaws" 1 && \
	update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
	update-alternatives --set java "${JRE_HOME}/bin/java" && \
	update-alternatives --set javaws "${JRE_HOME}/bin/javaws" && \
    update-alternatives --set javac "${JAVA_HOME}/bin/javac"

# Install the magic wrapper.
ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker
CMD ["wrapdocker"]
