#!/bin/sh

PUPPET_ENV='development'
PUPPET_BIN='/opt/puppetlabs/bin/puppet'

# # Ставим необходимые пакеты для старта
# apt-get update &&  apt-get -y install git mc htop apt-transport-https nano wget
#
# # Первоначально осуществляем установку `puppet-agent`
# rm *.deb.* # possible trash
# wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb && dpkg -i puppetlabs-release-pc1-xenial.deb
# apt-get update && apt-get -y install puppet-agent
#
# # Определяем тип `environment`
# /opt/puppetlabs/bin/puppet config set environment $PUPPET_ENV
# if [ ! -d /etc/puppetlabs/code/environments/$PUPPET_ENV ]; then
#   cp -r /etc/puppetlabs/code/environments/production /etc/puppetlabs/code/environments/$PUPPET_ENV
# fi

# Install puppet modules
# $PUPPET_BIN module install puppetlabs-ntp
# $PUPPET_BIN module install aco-oracle_java
# $PUPPET_BIN module install puppetlabs-firewall
# $PUPPET_BIN module install saz-ssh

# git clone "development" project and go in it

# replace puppet configs
cp puppet_config/hiera.yaml  /etc/puppetlabs/puppet/

# replace hiera db
rm -r /etc/puppetlabs/code/environments/$PUPPET_ENV/hieradata/*
cp -r $PUPPET_ENV/hieradata/*  /etc/puppetlabs/code/environments/$PUPPET_ENV/hieradata

# replace storyline_* modules
rm -r /etc/puppetlabs/code/environments/$PUPPET_ENV/modules/storyline_*
cp -r modules/*  /etc/puppetlabs/code/environments/$PUPPET_ENV/modules

# copy site.pp
cp $PUPPET_ENV/site.pp /etc/puppetlabs/code/environments/$PUPPET_ENV/manifests/site.pp
$PUPPET_BIN apply /etc/puppetlabs/code/environments/$PUPPET_ENV/manifests/site.pp
