#!/bin/bash
# Open 4 terminals: Simulator + 3 Python clients
# Run this AFTER: source /data/tools/pave/innexis_home/vsi_2025.2/env_vsi.bash
cd ~/LineFollower_Success

echo "Starting VSI Simulator in background..."
vsiSim LineFollowingRobot.dt &
SIM_PID=$!
sleep 2

echo "Starting Plant..."
xterm -T "PLANT" -e "cd ~/LineFollower_Success && PYTHONPATH=. python3 src/plant/plant.py --domain=AF_INET --server-url=vsitlmfabricvpc-nlb-ab1b44869757eb6a.elb.us-west-2.amazonaws.com; bash" &

sleep 1
echo "Starting Controller..."
xterm -T "CONTROLLER" -e "cd ~/LineFollower_Success && PYTHONPATH=. python3 src/controller/controller.py --domain=AF_INET --server-url=vsitlmfabricvpc-nlb-ab1b44869757eb6a.elb.us-west-2.amazonaws.com; bash" &

sleep 1
echo "Starting Visualizer..."
xterm -T "VISUALIZER" -e "cd ~/LineFollower_Success && PYTHONPATH=. python3 src/visualizer/visualizer.py --domain=AF_INET --server-url=vsitlmfabricvpc-nlb-ab1b44869757eb6a.elb.us-west-2.amazonaws.com; bash" &

echo ""
echo "=== ALL PROCESSES STARTED ==="
echo "In the vsiSim window, type:  reset"
echo "Then type:                   run"
