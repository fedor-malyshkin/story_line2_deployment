#!/bin/sh

. /provision/provision_\$1.sh
monit -I
