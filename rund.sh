#! /bin/sh

LOGFILE=./log/neuron.sinatra.log

nohup /usr/local/bin/ruby ./neuron.rb >> $LOGFILE 2>&1 &

