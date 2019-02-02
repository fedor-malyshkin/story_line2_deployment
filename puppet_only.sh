#!/bin/sh

PUPPET_ENV='development'
PUPPET_BIN='/opt/puppetlabs/bin/puppet'

# Ставим необходимые пакеты для старта
#apt-get update &&  apt-get -y install rsync git mc htop apt-transport-https nano wget lsb-release apt-utils curl python

# Первоначально осуществляем установку `puppet-agent`
# if [ ! -d /etc/puppetlabs ]; then
#   	rm *.deb.* *.deb # possible trash
# 	wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && dpkg -i puppetlabs-release-pc1-xenial.deb
# 	apt-get update && apt-get -y install puppet-agent
# fi

# Определяем тип `environment`
/opt/puppetlabs/bin/puppet config set environment $PUPPET_ENV
if [ ! -d /etc/puppetlabs/code/environments/$PUPPET_ENV ]; then
  cp -r /etc/puppetlabs/code/environments/production /etc/puppetlabs/code/environments/$PUPPET_ENV
fi

# Install puppet modules
# $PUPPET_BIN module install puppetlabs-ntp
# $PUPPET_BIN module install puppetlabs-java
# $PUPPET_BIN module install puppetlabs-firewall
# $PUPPET_BIN module install saz-ssh
# $PUPPET_BIN module install saz-sudo
# $PUPPET_BIN module install saz-limits
# $PUPPET_BIN module install thias-sysctl
# $PUPPET_BIN module install yo61-logrotate
# $PUPPET_BIN module install puppetlabs-apt
# $PUPPET_BIN module install puppet-archive
# $PUPPET_BIN module install puppetlabs-mysql

# git pull "deployment" project and go in it only if POVISION_NO_GIT_CLONE set to "true"
# if [ ${POVISION_NO_GIT_CLONE:-"false"} = "true" ];
# then
# 	echo "do nothing"
# else
# 	LOCAL_REV=""
# 	if [ -f local_latest.sha1 ]; then
# 	  LOCAL_REV=`cat local_latest.sha1`
# 	fi
# 	REMOTE_REV=`git ls-remote --tags | grep "latest" | awk '{print $1}'`
# 	if [ $LOCAL_REV = $REMOTE_REV ]; then
# 	 exit 0
# 	fi
# 	 git fetch --all --tags --prune
# 	 git checkout -f tags/latest
# fi

# replace puppet configs
cp puppet_config/hiera.yaml  /etc/puppetlabs/code/environments/$PUPPET_ENV/

# replace hiera db
rm /etc/puppetlabs/code/environments/$PUPPET_ENV/hieradata/*
cp -r $PUPPET_ENV/hieradata/*  /etc/puppetlabs/code/environments/$PUPPET_ENV/hieradata

# replace storyline_* modules
rm -r /etc/puppetlabs/code/environments/$PUPPET_ENV/modules/storyline_*
cp -r modules/*  /etc/puppetlabs/code/environments/$PUPPET_ENV/modules

# copy site.pp
cp $PUPPET_ENV/site.pp /etc/puppetlabs/code/environments/$PUPPET_ENV/manifests/site.pp

#echo "hostname:"
#hostname
$PUPPET_BIN apply /etc/puppetlabs/code/environments/$PUPPET_ENV/manifests/site.pp

