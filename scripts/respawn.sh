#!/bin/bash

# respawn timeout is 3 seconds
TIMEOUT=3
# execute command
${@}
# if exits with non-zero status, restart after $TIMEOUT seconds has elapsed
while [ $? -ne 0 ]; do
  echo "${@} died. Respawning after ${TIMEOUT} seconds...";
  sleep ${TIMEOUT}
  ${@};
done
