#!/bin/sh

PUPPET_ENV='production'
export PUPPET_ENV

# at this moment
POVISION_NO_GIT_CLONE='true'
export POVISION_NO_GIT_CLONE

. ./provision_common.sh
