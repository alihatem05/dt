#!/bin/bash
# Run E3: Noise and Disturbance Rejection
# Sweep noise levels with baseline gains

cd ~/LineFollower_Success

KP=2.0
KI=0.1
KD=0.5
PATH=straight

for NOISE in 0.0 0.01 0.05 0.1 0.2
do
    LABEL=Kp${KP}_Ki${KI}_Kd${KD}_noise${NOISE}

    echo "=== Running E3: $LABEL ==="

    # Update controller
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
PYEOF

    # Update plant noise
    python3 - << PYEOF
with open('src/plant/plant.py', 'r') as f:
    c = f.read()
import re
c = re.sub(r"add_argument\('--noise'.*\)", f"add_argument('--noise', type=float, default=$NOISE)", c)
with open('src/plant/plant.py', 'w') as f:
    f.write(c)
PYEOF

    # Update visualizer
    python3 - << PYEOF
with open('src/visualizer/visualizer.py', 'r') as f:
    c = f.read()
import re
c = re.sub(r"add_argument\('--path'.*\)", f"add_argument('--path', default='$PATH', choices=['straight','curved'])", c)
with open('src/visualizer/visualizer.py', 'w') as f:
    f.write(c)
PYEOF

    LABEL=$LABEL vsiSim LineFollowingRobot.dt

    cp visualizer_log.csv e3_results_${LABEL}.csv
    cp trajectory_data.csv e3_traj_${LABEL}.csv

    echo "=== Done E3: $LABEL ==="
done

echo "=== E3 Noise Sweep Complete ==="