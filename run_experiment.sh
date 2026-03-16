#!/bin/bash
set -euo pipefail

# Usage: ./run_experiment.sh <Kp> <Ki> <Kd> <label> [path] [noise] [domain] [server]
KP=${1:?Missing Kp}
KI=${2:?Missing Ki}
KD=${3:?Missing Kd}
LABEL=${4:?Missing label}
PATH_TYPE=${5:-straight}
NOISE=${6:-0.0}
DOMAIN=${7:-AF_INET}
SERVER=${8:-localhost}

cd ~/LineFollower_Success

echo "=== Running: $LABEL (Kp=$KP Ki=$KI Kd=$KD path=$PATH_TYPE noise=$NOISE) ==="

# Clear previous outputs and stale FIFOs from crashed runs.
rm -f visualizer_log.csv trajectory_data.csv
rm -f vsiInputFifo vsiInterruptFifo vsiOutputFifo

DOMAIN="$DOMAIN" \
SERVER="$SERVER" \
KP="$KP" KI="$KI" KD="$KD" \
PATH_TYPE="$PATH_TYPE" \
NOISE="$NOISE" \
LABEL="$LABEL" \
vsiSim LineFollowingRobot.dt --run

if [[ ! -f visualizer_log.csv || ! -f trajectory_data.csv ]]; then
	echo "ERROR: Simulation completed but expected CSV outputs were not generated."
	exit 1
fi

cp visualizer_log.csv "results_${LABEL}.csv"
cp trajectory_data.csv "trajectory_${LABEL}.csv"

echo "=== Done: results_${LABEL}.csv and trajectory_${LABEL}.csv ==="
