#! /bin/sh

LOGFILE=./log/neuron.sinatra.log

PORT_FILE=port_for_rund
PORT=`cat $PORT_FILE`

nohup /usr/local/bin/ruby ./neuron.rb -p $PORT >> $LOGFILE 2>&1 &

