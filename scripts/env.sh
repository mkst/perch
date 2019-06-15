#!/bin/bash

BASE=$(readlink -f $(dirname "${BASH_SOURCE[0]}")/..)

echo "BASE is $BASE"

export QHOME=${BASE}/kx
export PATH=${PATH}:${QHOME}
export KDB_HOME=${BASE}/code/kdb
export WEB_HOME=${BASE}/code/web
export CFG_HOME=${BASE}/config
export C_HOME=${BASE}/code/c
