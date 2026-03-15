#!/bin/bash
# Usage: ./run_experiment.sh <Kp> <Ki> <Kd> <label>
KP=$1
KI=$2
KD=$3
LABEL=$4

cd ~/LineFollower_Success

echo "=== Running experiment: Kp=$KP Ki=$KI Kd=$KD ==="

# Update controller gains
sed -i "s/p.add_argument('--Kp'.*/p.add_argument('--Kp', type=float, default=$KP)/" src/controller/controller.py
sed -i "s/p.add_argument('--Ki'.*/p.add_argument('--Ki', type=float, default=$KI)/" src/controller/controller.py
sed -i "s/p.add_argument('--Kd'.*/p.add_argument('--Kd', type=float, default=$KD)/" src/controller/controller.py

# Run simulation
vsiSim LineFollowingRobot.dt

# Save results
cp visualizer_log.csv results_${LABEL}.csv
cp trajectory_data.csv trajectory_${LABEL}.csv

echo "=== Done: results saved as results_${LABEL}.csv ==="
