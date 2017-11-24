#!/bin/bash

BASE=$(readlink -f $(cd "$( dirname "${BASH_SOURCE[0]}"  )"/.. && pwd))

export QHOME=${BASE}/kx
export PATH=${PATH}:${QHOME}
export KDB_HOME=${BASE}/code/kdb
export WEB_HOME=${BASE}/code/web
export CFG_HOME=${BASE}/config
export C_HOME=${BASE}/code/c
