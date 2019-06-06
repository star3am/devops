FROM httpd:2.4

ARG FQDN
ENV ENV_FQDN $FQDN
RUN echo $ENV_FQDN

# use google dns
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf

ENV LANG en_US.UTF-8

# see scripts/puppet.sh
# add the puppet ppa and install puppet, knockd
#RUN wget https://apt.puppetlabs.com/puppetlabs-release-pc1-trusty.deb \
#  && dpkg -i puppetlabs-release-pc1-trusty.deb \
#  && apt-get update \
#  && apt-get -y install puppet-agent knockd

#COPY scripts/puppet.sh /root/puppet.sh
#RUN chmod 0755 /root/puppet.sh
#RUN bash /root/puppet.sh

COPY html /var/www/html

EXPOSE 80
