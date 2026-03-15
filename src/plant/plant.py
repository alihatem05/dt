#!/usr/bin/env python3
"""
Line-Following Robot - Plant (Component 0, Port 50101)
Kinematics: unicycle model  dx=v*cos(θ)  dy=v*sin(θ)  dθ=ω
SENDS   : x (CAN 20), y (CAN 21), theta (CAN 22)
RECEIVES: omega (CAN 23)
"""
from __future__ import print_function
import struct, sys, argparse, math, csv, random

sys.path.append('pythonGateways/')
import VsiCommonPythonApi  as vsiCommonPythonApi
import VsiCanPythonGateway as vsiCanPythonGateway

# ── CAN bus IDs ──────────────────────────────────────────────
CAN_X, CAN_Y, CAN_THETA, CAN_OMEGA = 20, 21, 22, 23

# ── Robot constants ──────────────────────────────────────────
V   = 1.0    # m/s  forward speed (constant)
DT  = 0.001  # s

class Plant:
    def __init__(self, args):
        self.componentId = 0
        self.localHost   = args.server_url
        self.domain      = args.domain
        self.portNum     = 50101
        self.noise_std   = args.noise

        # Robot state  (start off the line so the controller has work to do)
        self.x     =  0.0
        self.y     =  0.5   # 0.5 m lateral offset
        self.theta =  0.1   # slight heading error
        self.omega =  0.0   # control input (received from controller)

        self.simulationStep      = 0
        self.totalSimulationTime = 0

    # ── helpers ──────────────────────────────────────────────
    def _pack(self, v):
        return struct.pack('=d', v)

    def _unpack(self, data):
        return struct.unpack('=d', data[:8])[0]

    def sendSignal(self, can_id, value):
        vsiCanPythonGateway.setCanId(can_id)
        vsiCanPythonGateway.setDataLengthInBits(64)
        vsiCanPythonGateway.setCanPayloadBits(self._pack(value), 0, 64)
        vsiCanPythonGateway.sendCanPacket()

    def recvSignal(self, can_id):
        data = vsiCanPythonGateway.recvVariableFromCanPacket(8, 0, 64, can_id)
        return self._unpack(data)

    def updateInternalVariables(self):
        self.totalSimulationTime = vsiCommonPythonApi.getTotalSimulationTime()
        self.simulationStep      = vsiCommonPythonApi.getSimulationStep()

    def updateKinematics(self):
        noise = random.gauss(0, self.noise_std) if self.noise_std > 0 else 0.0
        self.x     += V * math.cos(self.theta) * DT
        self.y     += (V * math.sin(self.theta) + noise) * DT
        self.theta += self.omega * DT
        self.theta  = math.atan2(math.sin(self.theta), math.cos(self.theta))  # wrap

    # ── main simulation loop ──────────────────────────────────
    def mainThread(self):
        dSession = vsiCommonPythonApi.connectToServer(
            self.localHost, self.domain, self.portNum, self.componentId)
        vsiCanPythonGateway.initialize(dSession, self.componentId)

        with open('trajectory_data.csv', 'w', newline='') as f:
            w = csv.writer(f)
            w.writerow(['time_ns','x','y','theta','omega'])

            try:
                vsiCommonPythonApi.waitForReset()
                self.updateInternalVariables()
                if self.totalSimulationTime == 0:
                    self.totalSimulationTime = 10_000_000_000  # 60 s fallback

                nextExpectedTime = vsiCommonPythonApi.getSimulationTimeInNs()

                while vsiCommonPythonApi.getSimulationTimeInNs() < self.totalSimulationTime:
                    self.updateInternalVariables()
                    if vsiCommonPythonApi.isStopRequested():
                        raise Exception("stopRequested")

                    # 1) SEND current state to fabric
                    self.sendSignal(CAN_X,     self.x)
                    self.sendSignal(CAN_Y,     self.y)
                    self.sendSignal(CAN_THETA, self.theta)

                    # 2) RECEIVE control command from controller
                    self.omega = self.recvSignal(CAN_OMEGA)

                    # 3) UPDATE kinematics
                    self.updateKinematics()

                    # 4) LOG
                    t = vsiCommonPythonApi.getSimulationTimeInNs()
                    w.writerow([t, self.x, self.y, self.theta, self.omega])
                    print(f"[PLANT] t={t}ns  x={self.x:.3f}  y={self.y:.4f}"
                          f"  θ={self.theta:.4f}  ω={self.omega:.4f}")

                    # 5) ADVANCE simulation clock
                    self.updateInternalVariables()
                    if vsiCommonPythonApi.isStopRequested():
                        raise Exception("stopRequested")
                    nextExpectedTime += self.simulationStep
                    now = vsiCommonPythonApi.getSimulationTimeInNs()
                    if now >= nextExpectedTime:
                        continue
                    if nextExpectedTime > self.totalSimulationTime:
                        vsiCommonPythonApi.advanceSimulation(
                            self.totalSimulationTime - now)
                        break
                    vsiCommonPythonApi.advanceSimulation(nextExpectedTime - now)

            except Exception as e:
                if str(e) == "stopRequested":
                    print("[PLANT] Stop requested — shutting down.")
                    vsiCommonPythonApi.advanceSimulation(self.simulationStep + 1)
                else:
                    print(f"[PLANT] ERROR: {e}")
                    raise
            except:
                vsiCommonPythonApi.advanceSimulation(self.simulationStep + 1)

        print("[PLANT] Finished. trajectory_data.csv written.")


def main():
    p = argparse.ArgumentParser("Plant")
    p.add_argument('--domain',     default='AF_UNIX')
    p.add_argument('--server-url', default='localhost')
    p.add_argument('--noise', type=float, default=0.0,
                   help='Gaussian noise std-dev on y-velocity (m/s)')
    p.add_argument('--path', default='straight',
                   choices=['straight','curved'])
    Plant(p.parse_args()).mainThread()

if __name__ == '__main__':
    main()
