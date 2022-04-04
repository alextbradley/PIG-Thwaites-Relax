#!/bin/bash

JOBNO=008

# move to run directory
cd ../run

# make target directory
W_HOMEDIR=$W_HOMEROOT/INVREL_${JOBNO}/run
ssh $W_HOMEHOST "mkdir -p $W_HOMEDIR"

rsync -avzL *.nc $W_HOMEHOST:$W_HOMEDIR

