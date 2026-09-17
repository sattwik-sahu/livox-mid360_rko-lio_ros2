---
layout: default
title: Tutorial
nav_order: 4
permalink: /tutorial/
---

# Full Tutorial — Hardware → Networking → Zenoh → Tuning

{: .important }
> Generate exact commands for your machine first: [**Setup Wizard →**](../setup-wizard/). This page explains *why* each step is needed.

## 1. Hardware

- **Mid360**: 65×65×60 mm, 265 g, 6.5 W (peak 14 W in self-heating < 0 °C), 9–27 V DC over the 3-in-1 cable (power + Ethernet). Range 40 m @10 %, FOV 360°×59° (-7° to 52°), 200 kpts/s.
- **Wiring**: Red/Black → 12 V, Ethernet → host NIC (use CAT6, avoid USB-Ethernet dongles without static IP support).
- **Default IP**: `192.168.1.1XX` where `XX` = last two digits of serial (often `192.168.1.12`), netmask `255.255.255.0`, gateway `192.168.1.1`. Static only — no DHCP.

## 2. Host network (the critical step)

The Livox SDK2 opens **UDP server sockets on the host**. The LiDAR pushes to `host_net_info` ports; those must be bound on an interface in the same subnet.

**Linux (host networking)**

```bash
ip addr                          # find NIC, e.g. eth0 / enp0s31f6
sudo ./scripts/setup_host_network.sh eth0 192.168.1.5 192.168.1.12
# helper does: ip addr add 192.168.1.5/24 dev eth0, sysctl rmem_max, ufw allow 56000:56500/udp
ping 192.168.1.12                 # must be <2 ms
sudo ufw allow 56100:56500/udp   # if ufw active
```

**macOS**

1. System Settings → Network → Ethernet → Details → TCP/IP → Configure IPv4 **Manually**, `192.168.1.5 / 255.255.255.0`.
2. Both Linux and macOS use `network_mode: host` — Docker on macOS now supports `--net host`. No extra `docker-compose.mac.yml` overlay is needed. Just run `docker compose up -d` on either OS.

{: .warning }
> If `ping` fails, nothing else will work. Check cable, power LED, and `ip addr` — not Docker.

## 3. Zenoh RMW

This stack uses **Zenoh** (`rmw_zenoh_cpp`). A Zenoh router is started **outside** this compose — e.g. via your `pixi` project (`pixi run zenoh-router` or `ros2 run rmw_zenoh_cpp rmw_zenohd`).

- Every container just sets `RMW_IMPLEMENTATION=rmw_zenoh_cpp` and `ROS_DOMAIN_ID` (same value) and connects to the external router. No extra Docker networking is needed.
- Start the router **before** `docker compose up` and verify `ros2 node list` shows it.
- Keep `RMW_IMPLEMENTATION` consistent across host, `livox-driver`, and `rko-lio`.

## 4. Build vs pull

```bash
# Pull prebuilt multi-arch (Linux built, Mac pulls linux/arm64)
docker compose pull
docker compose up -d

# Or build for your distro
ROS_DISTRO=kilted docker compose build
ROS_DISTRO=kilted docker compose up -d
```

Multi-platform push (maintainer): `docker buildx build --platform linux/amd64,linux/arm64 -f docker/livox.Dockerfile --build-arg ROS_DISTRO=jazzy -t ghcr.io/.../livox-driver:jazzy --push .`

## 5. Running

```bash
docker compose up -d
docker compose logs -f livox-driver     # expect: "Data Handle Init Succ"
docker compose logs -f rko-lio
docker compose exec livox-driver ros2 topic list
# /livox/lidar /livox/imu /tf
docker compose exec livox-driver ros2 topic hz /livox/lidar   # ~10 Hz
```

RKO-LIO autodetects `lidar_topic`/`imu_topic` and frames; override via `config/rko_lio/params.yaml`.

## 6. Recording

```bash
docker compose exec rko-lio ros2 bag record -o /tmp/mid360 /livox/lidar /livox/imu /odom /tf
# or on host (with same RMW+DOMAIN_ID):
RMW_IMPLEMENTATION=rmw_zenoh_cpp ROS_DOMAIN_ID=0 ros2 bag record /livox/lidar /livox/imu
```

## 7. Troubleshooting

| Symptom | Fix |
|---------|-----|
| `ping` fails | Re-run `setup_host_network.sh`, check subnet, cable, firewall |
| Driver starts but no points | IPs mismatch in `config/livox/MID360_config.json` vs `.env`; `HOST_IP` must equal `ip addr` value |
| `ros2 topic list` empty across containers | Zenoh router not running (start your `pixi` Zenoh router) or `ROS_DOMAIN_ID` mismatch |
| `rviz` no display | Need `xhost +local:docker` + `DISPLAY`/`XAUTHORITY` mounts; or use Foxglove `ros2 bag` playback |

Next: [Configuration →](../configuration/) for every tunable.
