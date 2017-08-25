#!/bin/bash

BASE=$(readlink -f $(cd "$( dirname "${BASH_SOURCE[0]}"  )"/.. && pwd))

export QHOME=${BASE}/kx
export PATH=${PATH}:${QHOME}
export KDB_HOME=${BASE}/code/kdb
export C_HOME=${BASE}/code/c
