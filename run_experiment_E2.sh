#!/bin/bash
# Run E2: Curved Path Robustness
# Test best controller from E1 on curved path

cd ~/LineFollower_Success

# Best from E1: Kp2.0 Ki0.1 Kd0.5 (baseline)
KP=2.0
KI=0.1
KD=0.5
PATH=curved
LABEL=Kp${KP}_Ki${KI}_Kd${KD}_curved

echo "=== Running E2: $LABEL ==="

# Update controller gains
python3 - << PYEOF
with open('src/controller/controller.py', 'r') as f:
    c = f.read()
import re
c = re.sub(r"add_argument\('--Kp'.*\)", f"add_argument('--Kp', type=float, default=$KP)", c)
c = re.sub(r"add_argument\('--Ki'.*\)", f"add_argument('--Ki', type=float, default=$KI)", c)
c = re.sub(r"add_argument\('--Kd'.*\)", f"add_argument('--Kd', type=float, default=$KD)", c)
c = re.sub(r"add_argument\('--path'.*\)", f"add_argument('--path', default='$PATH', choices=['straight','curved'])", c)
with open('src/controller/controller.py', 'w') as f:
    f.write(c)
print("Gains set: Kp=$KP Ki=$KI Kd=$KD Path=$PATH")
PYEOF

# Update visualizer path
python3 - << PYEOF
with open('src/visualizer/visualizer.py', 'r') as f:
    c = f.read()
import re
c = re.sub(r"add_argument\('--path'.*\)", f"add_argument('--path', default='$PATH', choices=['straight','curved'])", c)
with open('src/visualizer/visualizer.py', 'w') as f:
    f.write(c)
print("Visualizer path set to $PATH")
PYEOF

# Run simulation
LABEL=$LABEL vsiSim LineFollowingRobot.dt

# Save results
cp visualizer_log.csv e2_results_${LABEL}.csv
cp trajectory_data.csv e2_traj_${LABEL}.csv

echo "=== Done E2: results saved as e2_results_${LABEL}.csv ==="