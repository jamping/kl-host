FROM ubuntu:16.04
MAINTAINER klasa@lokalni.pl

# Setup APT to deal with non-interactive mode
ENV DEBIAN_FRONTEND noninteractive
ENV LC_CTYPE=C.UTF-8 

# Build apt cache
RUN apt-get update

#Mscore fonts will be needed for openoffice later
RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

#Install misc. dependencies
RUN apt-get install -yq curl software-properties-common openjdk-8-jre apt-transport-https haveged build-essential certbot supervisor python3 python3-requests

# Add PPAs for BBB support packages and yq 
RUN add-apt-repository ppa:bigbluebutton/support -y && \
    add-apt-repository ppa:rmescandon/yq

# Add NodeJS 8.x
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -

# Add MongoDB 3.4
RUN curl -sL https://www.mongodb.org/static/pgp/server-3.4.asc | apt-key add - && \
    echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

# Add BigBlueButton repo
RUN curl -sL https://ubuntu.bigbluebutton.org/repo/bigbluebutton.asc | apt-key add - && \
    echo "deb https://ubuntu.bigbluebutton.org/xenial-220 bigbluebutton-xenial main" > /etc/apt/sources.list.d/bigbluebutton.list

# Run full ubuntu upgrade
RUN apt-get update && apt-get dist-upgrade -yq

# Install required software from external repositories
RUN apt-get install -yq nodejs mongodb-org yq

# Install bigbluebutton itself
RUN apt-get install -yq bigbluebutton bbb-html5

# Cleanup
RUN apt-get auto-remove -y && apt-get clean

# -- Add entrypoint script
ADD scripts/startup.sh /root/
RUN chmod +x /root/startup.sh
CMD ['/root/startup.sh']