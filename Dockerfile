from debian:jessie

RUN apt-get update && apt-get -y install apt-transport-https ca-certificates curl nmap
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
ADD docker.list /etc/apt/sources.list.d/

RUN apt-get update && apt-get -y install netcat-openbsd socat jq docker-engine

ADD proxy.sh /
