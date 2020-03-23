FROM ubuntu:16.04
MAINTAINER marek@wajdzik.eu

# -- Install all needed packages
ADD /scripts/bbb-build.sh /root/bbb-build.sh
RUN chmod +x /root/bbb-build.sh && /root/bbb-build.sh

# -- Add entrypoint script
ADD scripts/startup.sh /root/
RUN chmod +x /root/startup.sh
CMD ['/root/startup.sh']