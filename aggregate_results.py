#!/usr/bin/env python3
"""
Aggregate results from experiments and print KPIs
"""
import csv
import os
import glob

def compute_kpis(csv_file):
    times, xs, ys, thetas, omegas, errors = [], [], [], [], [], []
    with open(csv_file) as f:
        for row in csv.DictReader(f):
            times.append(float(row['time_ns']) * 1e-9)
            xs.append(float(row['x']))
            ys.append(float(row['y']))
            thetas.append(float(row['theta']))
            omegas.append(float(row['omega']))
            errors.append(float(row['lateral_error']))

    max_overshoot = max(abs(e) for e in errors)
    final_error = abs(errors[-1])
    steady_start = 5.0
    steady_errors = [abs(e) for t, e in zip(times, errors) if t > steady_start]
    sse = sum(steady_errors) / len(steady_errors) if steady_errors else 0

    # Settling time
    threshold = 0.05
    settling_time = times[-1]
    for i, (t, e) in enumerate(zip(times, errors)):
        if all(abs(err) < threshold for err in errors[i:]):
            settling_time = t
            break

    return {
        'max_overshoot': max_overshoot,
        'final_error': final_error,
        'steady_state_error': sse,
        'settling_time': settling_time,
        'duration': times[-1]
    }

def main():
    experiments = {
        'E1': 'e1_results_*.csv',
        'E2': 'e2_results_*.csv',
        'E3': 'e3_results_*.csv',
        'E4': 'e4_results_*.csv'
    }

    for exp, pattern in experiments.items():
        files = glob.glob(pattern)
        if not files:
            continue
        print(f"\n=== {exp} Results ===")
        for f in sorted(files):
            label = os.path.basename(f).replace('e1_results_', '').replace('e2_results_', '').replace('e3_results_', '').replace('e4_results_', '').replace('.csv', '')
            kpis = compute_kpis(f)
            print(f"{label}: Overshoot={kpis['max_overshoot']:.4f}, SSE={kpis['steady_state_error']:.4f}, Settling={kpis['settling_time']:.1f}s")

if __name__ == '__main__':
    main()