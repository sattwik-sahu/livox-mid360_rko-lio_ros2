---
layout: default
title: References
nav_order: 6
permalink: /references/
---

# References

## Livox Mid360

- **Specs & datasheet**: [livoxtech.com/mid-360/specs](https://www.livoxtech.com/mid-360/specs) — 40 m @10 %, 200 kpts/s, 360°×59° FOV, built-in ICM40609 IMU.
- **User manual & quick start**: [livoxtech.com/mid-360/downloads](https://www.livoxtech.com/mid-360/downloads) — wiring, static IP `192.168.1.1XX`.
- **Communication protocol**: [livox_wiki_en — Mid360](https://github.com/Livox-SDK/livox_wiki_en/blob/master/source/tutorials/new_product/mid360/livox_eth_protocol_mid360.md) — UDP ports `56100` cmd, `56200` push, `56300` pointcloud, `56400` imu, `56500` log.
- **Livox SDK2**: [Livox-SDK/Livox-SDK2](https://github.com/Livox-SDK/Livox-SDK2) — build `cmake .. && make && sudo make install`.
- **livox_ros_driver2**: [Livox-SDK/livox_ros_driver2](https://github.com/Livox-SDK/livox_ros_driver2) — ROS/ROS2 driver, `config/MID360_config.json`, launch `msg_MID360_launch.py` (`xfer_format`, `publish_freq`), Rviz configs.
- **Docker example (Jetson)**: [patrick-darbin-orica/Livox-mid360-docker](https://github.com/patrick-darbin-orica/Livox-mid360-docker) — static IP + `ufw allow 56100:56500/udp`.

## RKO-LIO

- **Repo & paper**: [PRBonn/rko_lio](https://github.com/PRBonn/rko_lio) — *A Robust Approach for LiDAR-Inertial Odometry Without Sensor-Specific Modelling* (RA-L 2026). MIT.
- **ROS install**: `sudo apt install ros-$ROS_DISTRO-rko-lio` or source `colcon build --cmake-args -DRKO_LIO_FETCH_CONTENT_DEPS=ON`; launch `ros2 launch rko_lio odometry.launch.py`.
- **Docs**: [prbonn.github.io/rko_lio](https://prbonn.github.io/rko_lio/) — parameter tuning, autodetect topics.

## ROS 2 & Zenoh

- **ROS 2 distros**: [docs.ros.org — Releases](https://docs.ros.org/en/jazzy/Releases.html), [REP-2000](https://www.ros.org/reps/rep-2000.html) — Jazzy (LTS, Noble), Kilted (Noble), Lyrical (Resolute).
- **Docker images**: [osrf/ros](https://hub.docker.com/r/osrf/ros), [library/ros](https://hub.docker.com/_/ros) — `ros:jazzy-ros-base` etc. multi-arch.
- **Zenoh RMW**: [ros2/rmw_zenoh](https://github.com/ros2/rmw_zenoh), [Working with Zenoh (Kilted)](https://docs.ros.org/en/kilted/Installation/RMW-Implementations/Non-DDS-Implementations/Working-with-Zenoh.html) — `ros-$DISTRO-rmw-zenoh-cpp`, `RMW_IMPLEMENTATION=rmw_zenoh_cpp`, `ros2 run rmw_zenoh_cpp rmw_zenohd`.
- **Running ROS 2 in Docker**: [docs.ros.org — Community guide](https://docs.ros.org/en/kilted/How-To-Guides/Run-2-nodes-in-single-or-separate-docker-containers.html), [Docker — ROS2 guide](https://docs.docker.com/guides/ros2.md).

## Networking & Multi-arch

- **Docker host networking**: [docs.docker.com — Network host](https://docs.docker.com/engine/network/drivers/host/) — LiDAR UDP requires host mode on Linux; Docker Desktop macOS limitation.
- **OrbStack / Colima**: [orbstack.dev](https://orbstack.dev), [abiosoft/colima](https://github.com/abiosoft/colima) — macOS host-network alternatives.
- **Buildx multi-platform**: [docs.docker.com — Buildx](https://docs.docker.com/build/building/multi-platform/) — `docker buildx build --platform linux/amd64,linux/arm64`.

## Jekyll & GitHub Pages

- **Just the Docs**: [just-the-docs.github.io](https://just-the-docs.github.io/just-the-docs/) — theme used for this site.
- **GitHub Pages + Jekyll**: [docs.github.com — Pages](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll).
