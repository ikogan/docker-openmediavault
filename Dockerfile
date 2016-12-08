FROM debian:wheezy

MAINTAINER Ilya Kogan <ikogan@flarecode.com>

# Add the OpenMediaVault repository
COPY openmediavault.list /etc/apt/sources.list.d/

ENV DEBIAN_FRONTEND noninteractive

# Fix resolvconf issues with Docker
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

# Install OpenMediaVault packages and dependencies
RUN apt-get update -y; apt-get install openmediavault-keyring postfix locales -y --force-yes
RUN apt-get update -y; apt-get install openmediavault -y

# We need to make sure rrdcached uses /data for it's data
COPY defaults/rrdcached /etc/default

# Add our startup script last because we don't want changes
# to it to require a full container rebuild
COPY omv-startup /usr/sbin/omv-startup
RUN chmod +x /usr/sbin/omv-startup

EXPOSE 8080 8443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
