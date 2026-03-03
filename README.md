# Wi-Fi 6 (IEEE 802.11ax) Multinode Network Simulation in MATLAB

## Project Overview
This repository contains a custom system-level simulation of a WLAN network based on the **IEEE 802.11ax (Wi-Fi 6)** standard. The project was developed entirely from scratch in MATLAB to model the performance and behavior of a multinode environment (1 Access Point and 2 Stations). 

Instead of relying on heavy waveform-level (bit-by-bit) processing, this simulation utilizes **PHY abstraction** and mathematical modeling to evaluate network performance based on spatial distribution. It provides real-time calculation and visualization of network metrics such as Throughput, Packet Loss, and Latency.

## Key Features
* **Procedural Custom GUI:** A fully programmatic graphical interface built without App Designer, ensuring complete control over rendering, axes management, and real-time updates.
* **CSMA/CA State Visualization:** A dynamic Gantt chart that probabilistically models MAC layer states, providing a visual representation of time-sharing in a shared wireless medium. The visualized states include:
  * **Transmission:** (green) Active data transmission. 
  * **Idle:** (white) Node is resting/channel is free.
  * **Contention:** (yellow) Backoff period (CSMA/CA collision avoidance).
  * **Reception (destined):** (blue) Successful reception of a targeted packet.
  * **Reception (overhearing):** (beige) Node detects a busy medium and defers transmission.
  * **Failure:** (red) Packet loss due to distance or interference.
* **Distance-Based Performance Degradation:** Accurate algorithmic simulation of how physical distance impacts network speed and reliability.

## Mathematical Models Implemented
The core logic of the simulation relies on mathematical approximations to model signal degradation over distance ($d$), calculated using the Euclidean distance between the AP and each Station:

1. **Throughput (Exponential Decay):** Speed decreases exponentially as the station moves further from the AP.
   `Th = 10 * exp(-d / 70)` *(Max speed is 10 Mbps at 0m, dropping to ~3.6 Mbps at 70m).*
2. **Packet Loss (Threshold Logic):** Losses are forced to 0% up to a safe distance of 50 meters, after which they increase linearly.
   `Loss = (d - 50) / 40` *(for d > 50m).*
3. **Latency (Propagation Delay):** Calculated using a base processing time (0.2s) plus a distance-dependent delay.
   `Latency = 0.2 + (d / 500)`
