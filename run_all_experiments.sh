#!/bin/bash

run_exp() {
    KP=$1; KI=$2; KD=$3; LABEL=$4
    echo "=== Running $LABEL ==="
    
    python3 - << PYEOF
with open('src/controller/controller.py', 'r') as f:
    c = f.read()
import re
c = re.sub(r"add_argument\('--Kp'.*\)", f"add_argument('--Kp', type=float, default=$KP)", c)
c = re.sub(r"add_argument\('--Ki'.*\)", f"add_argument('--Ki', type=float, default=$KI)", c)
c = re.sub(r"add_argument\('--Kd'.*\)", f"add_argument('--Kd', type=float, default=$KD)", c)
with open('src/controller/controller.py', 'w') as f:
    f.write(c)
print("Gains set: Kp=$KP Ki=$KI Kd=$KD")
PYEOF

    LABEL=$LABEL vsiSim LineFollowingRobot.dt
    
    cp visualizer_log.csv  e1_results_${LABEL}.csv
    cp trajectory_data.csv e1_traj_${LABEL}.csv
    echo "=== Done $LABEL ==="
}

# Gain Set 1 - already done, skip
# run_exp 2.0 0.1 0.5 Kp2.0_Ki0.1_Kd0.5

# Gain Set 2 - aggressive
run_exp 5.0 0.5 1.0 Kp5.0_Ki0.5_Kd1.0

# Gain Set 3 - weak
run_exp 0.5 0.05 0.1 Kp0.5_Ki0.05_Kd0.1

# Gain Set 4 - very aggressive
run_exp 10.0 1.0 2.0 Kp10.0_Ki1.0_Kd2.0

# Gain Set 5 - balanced
run_exp 3.0 0.2 0.8 Kp3.0_Ki0.2_Kd0.8

echo "=== ALL EXPERIMENTS DONE ==="
