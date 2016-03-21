#!/bin/bash
export RAILS_ENV='production'
DIRNAME=`dirname $0`
cd $DIRNAME
/home/darammg/.rvm/rubies/ruby-1.9.3-p547/bin/ruby "$@"
