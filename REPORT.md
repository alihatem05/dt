# Line-Following Robot with PID Control - Project Report

## Overview
This project implements a three-client architecture for simulating and controlling a differential-drive robot tracking a predefined path using PID control. The system communicates over the Innexis Virtual System Interconnect (IVSI) backplane.

## System Architecture
- **Plant (Simulator)**: Models unicycle kinematics with sensor noise
- **Controller**: PID controller minimizing lateral error
- **Visualizer**: Logs data and generates performance plots

## Kinematics Model
The robot follows unicycle dynamics:
```
dx/dt = v * cos(θ)
dy/dt = v * sin(θ)
dθ/dt = ω
```
With constant forward velocity v = 1.0 m/s and steering rate ω from controller.

## Control Design
PID controller on lateral error:
```
ω = Kp * e + Ki * ∫e dt + Kd * de/dt
```
where e = y - y_ref(x)

## Path Definitions
- **Straight**: y_ref(x) = 0
- **Curved**: y_ref(x) = 0.5 * sin(0.1 * x)

## Experiments

### E1: PID Gain Sweep
Tested 5 gain sets on straight path with random initial conditions.

### E2: Curved Path Robustness
Best E1 controller on curved path.

### E3: Noise Rejection
Baseline gains with noise levels σ ∈ [0, 0.01, 0.05, 0.1, 0.2] m/s.

### E4: PD vs PID
Ki=0 vs Ki=0.1 on curved path with noise.

## Results
[To be filled after running experiments]

## Conclusion
[Analysis of controller performance, robustness, etc.]