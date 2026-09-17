---
layout: default
title: Home
nav_order: 1
description: Livox Mid360 + RKO-LIO ROS2 Docker — Jazzy/Kilted/Lyrical, Zenoh, Linux & macOS arm64
permalink: /
---

![Livox LIO banner](rko-lio-banner.png)

# Livox Mid360 + RKO-LIO on ROS 2

{: .fs-6 .fw-300 }

Dockerized autonomy stack for the **Livox Mid360** — driver + LiDAR-inertial odometry — on **ROS 2 Jazzy / Kilted / Lyrical** with **Zenoh** RMW. Multi-arch (`amd64` + `arm64`) via GHCR. Build on Linux, pull on Mac Mini `osx-arm64`.

[![CI](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/actions/workflows/ci.yml/badge.svg)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/actions/workflows/ci.yml)
[![Docs](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/actions/workflows/docs.yml/badge.svg)](https://sattwik-sahu.github.io/livox-mid360_rko-lio_ros2/)
[![GHCR livox-driver:jazzy](https://img.shields.io/badge/ghcr-livox--driver%3Ajazzy-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Flivox-driver)
[![GHCR livox-driver:kilted](https://img.shields.io/badge/ghcr-livox--driver%3Akilted-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Flivox-driver)
[![GHCR livox-driver:lyrical](https://img.shields.io/badge/ghcr-livox--driver%3Alyrical-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Flivox-driver)
[![GHCR rko-lio:jazzy](https://img.shields.io/badge/ghcr-rko--lio%3Ajazzy-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Frko-lio)
[![GHCR rko-lio:kilted](https://img.shields.io/badge/ghcr-rko--lio%3Akilted-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Frko-lio)
[![GHCR rko-lio:lyrical](https://img.shields.io/badge/ghcr-rko--lio%3Alyrical-blue?logo=docker)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/pkgs/container/livox-mid360_rko-lio_ros2%2Frko-lio)

{: .important }
> **New here?** Use the interactive [**Setup Wizard →**](setup-wizard/) to pick your **OS / Arch / ROS 2 distro** and get copy-paste commands. Then follow the [Quick Start](quickstart/) (5 min) or [Tutorial](tutorial/) (full).

## At a glance

```mermaid
flowchart LR
  LIDAR[(Livox Mid360<br/>192.168.1.12)] -->|UDP 56xxx| DRIVER[livox-driver<br/>livox_ros_driver2]
  DRIVER -->|/livox/lidar /livox/imu<br/>Zenoh| RKO[rko-lio]
  RKO -->|/odom /tf /map| VIZ[(RViz / Foxglove)]
```

| Service | Image | Publishes / Subscribes |
|---------|-------|------------------------|
| `livox-driver` | `ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/livox-driver:{distro}` | `/livox/lidar` (`PointCloud2` or `CustomMsg`), `/livox/imu` |
| `rko-lio` | `ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/rko-lio:{distro}` | subscribes lidar+imu, publishes `/odom`, `/tf` |

> **Zenoh:** An external Zenoh router (your `pixi` project) is expected — e.g. `pixi run zenoh-router`. Containers just set `RMW_IMPLEMENTATION=rmw_zenoh_cpp`.

## Choose your path

| I want to… | Go to |
|------------|-------|
| Get running in 5 minutes | [Quick Start](quickstart/) |
| Generate exact commands for my machine | [**Setup Wizard**](setup-wizard/) |
| Understand networking, Zenoh, every config knob | [Tutorial](tutorial/) + [Configuration](configuration/) |
| Look up datasheets & protocol docs | [References](references/) |

## Supported matrix

| ROS 2 | Ubuntu | GHCR tag | CI status |
|-------|--------|----------|-----------|
| `jazzy` (LTS, default) | 24.04 Noble | `livox-driver:jazzy` / `rko-lio:jazzy` | [![CI](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/actions/workflows/ci.yml/badge.svg?event=push)](https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2/actions/workflows/ci.yml) |
| `kilted` | 24.04 Noble | `livox-driver:kilted` / `rko-lio:kilted` | same workflow — matrix job `kilted` |
| `lyrical` | Resolute | `livox-driver:lyrical` / `rko-lio:lyrical` | same workflow — matrix job `lyrical` |

All images: `linux/amd64` + `linux/arm64`. See **CI** matrix (6 jobs: `livox-driver` × `jazzy`/`kilted`/`lyrical` + `rko-lio` × `jazzy`/`kilted`/`lyrical`).

Pull examples:

```bash
docker pull ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/livox-driver:jazzy
docker pull ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/rko-lio:kilted
docker pull ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/livox-driver:lyrical
```
