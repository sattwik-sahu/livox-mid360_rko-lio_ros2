---
layout: default
title: Quick Start
nav_order: 2
permalink: /quickstart/
---

# Quick Start (5 minutes)

{: .note }
> For tailored commands (OS / Arch / ROS distro), use the [**Setup Wizard →**](../setup-wizard/) — it generates the exact `git clone` / `docker pull` / `docker compose` lines for your machine.

## Prerequisites

- Docker Engine ≥ 24 + Compose v2, `git`
- Livox Mid360 powered (9–27 V) and Ethernet-connected
- Choose a ROS 2 distro: `jazzy` (default), `kilted`, or `lyrical`

## 1. Clone & configure

```bash
git clone https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2.git
cd livox-mid360_rko-lio_ros2
cp .env.example .env
# Edit .env: set ROS_DISTRO, HOST_IP (your NIC), LIDAR_IP (printed on Mid360, default 192.168.1.12)
nano .env
```

Find your LiDAR IP on the device label or via Livox Viewer 2. Host IP must be same `/24` subnet (e.g. LiDAR `192.168.1.12` → host `192.168.1.5`).

## 2. Host network (Linux)

```bash
# eth0 / enp0s31f6 — replace with your NIC name (ip addr)
sudo ./scripts/setup_host_network.sh eth0 192.168.1.5 192.168.1.12
ping 192.168.1.12   # must succeed before continuing
```

macOS: set static IP in **System Settings → Network → Ethernet → Details → TCP/IP → Manual** (`192.168.1.5/255.255.255.0`), then use the `docker-compose.mac.yml` overlay (see Tutorial).

## 3. Launch

```bash
# Option A — prebuilt GHCR (no build, ~30s)
docker compose pull
docker compose up -d
# Option B — build locally
docker compose build
docker compose up -d
docker compose logs -f
```

## 4. Verify

```bash
docker compose exec livox-driver ros2 topic list | grep livox
# /livox/lidar /livox/imu
docker compose exec livox-driver ros2 topic hz /livox/lidar
docker compose exec rko-lio ros2 topic echo /odom --once
./scripts/check_zenoh.sh
```

Stop: `docker compose down`

## Next steps

- **Full walkthrough** with networking, Zenoh debugging, RViz: [Tutorial →](../tutorial/)
- **Every config knob** explained: [Configuration →](../configuration/)
- **Tailored commands**: [Setup Wizard →](../setup-wizard/)
