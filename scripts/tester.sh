#!/bin/bash

RESPAWN="scripts/respawn.sh"
SESSION="TEST"
Q="q32"

tmux kill-server

source env.sh

echo "launching logger..."
tmux new-session -d -c ${BASE} -s ${SESSION} -n "LOGGER"      "${RESPAWN} ${Q} code/kdb/procs/logger/logger_init.q -config config/examples/logger.cfg"
echo "launching rdbdisk..."
tmux new-window  -d -c ${BASE} -t ${SESSION} -n "RDBDISK"     "${RESPAWN} ${Q} code/kdb/procs/rdbdisk/rdbdisk_init.q -config config/examples/rdbdisk.cfg"
echo "launching publisher..."
tmux new-window  -d -c ${BASE} -t ${SESSION} -n "PUBLISHER"   "${RESPAWN} ${Q} code/kdb/test/publisher.q -p 5001"
echo "launching book builder..."
tmux new-window  -d -c ${BASE} -t ${SESSION} -n "BOOKBUILDER" "${RESPAWN} ${Q} code/kdb/procs/bookbuilder/bookbuilder_init.q -config config/examples/bookbuilder.cfg"