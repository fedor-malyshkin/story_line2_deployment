#!/bin/sh

PUPPET_ENV='development'
export PUPPET_ENV

POVISION_NO_GIT_CLONE='true'
export POVISION_NO_GIT_CLONE

. ./provision_common.sh
