FROM debian:wheezy

MAINTAINER Ilya Kogan

ADD openmediavault.list /etc/apt/sources.list.d/
ADD omv-startup /usr/sbin/omv-startup

ENV DEBIAN_FRONTEND noninteractive

RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections
RUN apt-get update -y; apt-get install openmediavault-keyring postfix locales -y --force-yes
RUN apt-get update -y; apt-get install openmediavault -y
RUN chmod +x /usr/sbin/omv-startup

RUN apt-get install apt-transport-https; wget http://omv-extras.org/openmediavault-omvextrasorg_latest_all.deb -O /tmp/omv-extras.deb; dpkg -i /tmp/omv-extras.deb; rm /tmp/omv-extras.deb; apt-get update

EXPOSE 80 443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
