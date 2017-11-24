#!/bin/bash

origin=$(pwd)

cd $(readlink -f $(cd "$( dirname "${BASH_SOURCE[0]}"  )"/.. && pwd))

RESPAWN="scripts/respawn.sh"
SESSION="BITSTAMP"
Q="q32"

tmux kill-server > /dev/null 2>&1

source scripts/env.sh

echo "launching logger..."
tmux new  -d  -c ${BASE} -s ${SESSION} -n "LOGGER"      "${RESPAWN} ${Q} code/kdb/procs/logger/logger_init.q -config config/prod/logger.cfg"
echo "launching rdbdisk..."
tmux neww -ad -c ${BASE} -t ${SESSION} -n "RDBDISK"     "${RESPAWN} ${Q} code/kdb/procs/rdbdisk/rdbdisk_init.q -config config/prod/rdbdisk.cfg"
echo "launching book builder..."
tmux neww -ad -c ${BASE} -t ${SESSION} -n "BOOKBUILDER" "${RESPAWN} ${Q} code/kdb/procs/bookbuilder/bookbuilder_init.q -config config/prod/bookbuilder.cfg"
echo "launching bitstamp gateway..."
tmux neww -ad -c ${BASE} -t ${SESSION} -n "BITSTAMP"    "${RESPAWN} ${Q} code/kdb/procs/stp/stp_init.q -config config/prod/bitstamp.cfg"
echo "launching analytics..."
tmux neww -ad -c ${BASE} -t ${SESSION} -n "ANALYTICS"   "${RESPAWN} ${Q} code/kdb/procs/analytics/analytics_init.q -p 5005"

cd ${origin}