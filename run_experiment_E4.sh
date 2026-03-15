#!/bin/bash
# Run E4: PD vs PID Ablation
# Compare PD (Ki=0) vs PID on curved path under noise

cd ~/LineFollower_Success

PATH=curved
NOISE=0.05  # some noise

for KI in 0.0 0.1
do
    KP=2.0
    KD=0.5
    LABEL=Kp${KP}_Ki${KI}_Kd${KD}_curved_noise${NOISE}

    echo "=== Running E4: $LABEL ==="

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

    # Update plant
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

    cp visualizer_log.csv e4_results_${LABEL}.csv
    cp trajectory_data.csv e4_traj_${LABEL}.csv

    echo "=== Done E4: $LABEL ==="
done

echo "=== E4 PD vs PID Complete ==="