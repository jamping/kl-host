#!/bin/bash

# This is a quick remake of bbb-install.sh :)

main() {
  # Setup apt to deal with non-interactive mode
  export DEBIAN_FRONTEND=noninteractive

  # Perfrom initial apt update
  apt update

  # Check if build host runs x64 architecture
  need_x64

  # Accept mscorefonts license
  echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections

  # Install needed packages 
  need_pkg curl software-properties-common openjdk-8-jre apt-transport-https haveged build-essential certbot supervisor python3 python3-requests 

  # Install node exporter for monitoring / stats
  curl -sL https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz | tar zxvf - node_exporter-0.18.1.linux-amd64/node_exporter --strip-components 1 -C /usr/bin/
  chmod +x /usr/bin/node_exporter
  
  # Add PPA
  need_ppa bigbluebutton-ubuntu-support-xenial.list ppa:bigbluebutton/support E95B94BC # Latest version of ffmpeg
  need_ppa rmescandon-ubuntu-yq-xenial.list ppa:rmescandon/yq                 CC86BB64 # Edit yaml files with yq

  # Add NodeJS 8.x
  curl -sL https://deb.nodesource.com/setup_8.x | bash -

  # Add MongoDB 3.4
  curl -sL https://www.mongodb.org/static/pgp/server-3.4.asc | apt-key add -
  echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list

  # Add BigBlueButton repo
  curl -sL https://ubuntu.bigbluebutton.org/repo/bigbluebutton.asc | apt-key add -
  echo "deb https://ubuntu.bigbluebutton.org/xenial-220 bigbluebutton-xenial main" > /etc/apt/sources.list.d/bigbluebutton.list

  # Run full upgrade
  apt-get update
  apt-get dist-upgrade -yq

  # Install required software from external repositories
  need_pkg nodejs mongodb-org yq

  # Install bigbluebutton itself
  need_pkg bigbluebutton
  need_pkg bbb-html5

  # Clean APT
  apt-get auto-remove -y
  apt-get clean
}

# Error handler
err() {
  echo "$1" >&2
  exit 1
}

# Check if host is x64 one
need_x64() {
  UNAME=`uname -m`
  if [ "$UNAME" != "x86_64" ]; then err "You must run this command on a 64-bit server."; fi
}

# Wrapper to install apt packages
need_pkg() {
  if ! dpkg -s ${@:1} >/dev/null 2>&1; then
    LC_CTYPE=C.UTF-8 apt-get install -yq ${@:1}
  fi
}

# Wrapper to add PPA repository
need_ppa() {
  if [ ! -f /etc/apt/sources.list.d/$1 ]; then
    LC_CTYPE=C.UTF-8 add-apt-repository -y $2 
  fi
  if ! apt-key list $3 | grep -q -E "1024|4096"; then  # Let's try it a second time
    LC_CTYPE=C.UTF-8 add-apt-repository $2 -y
    if ! apt-key list $3 | grep -q -E "1024|4096"; then
      err "Unable to setup PPA for $2"
    fi
  fi
}

# Execute main function
main "$@" || exit 1