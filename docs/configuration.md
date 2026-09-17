---
layout: default
title: Configuration
nav_order: 5
permalink: /configuration/
---

# Configuration Reference

{: .note }
> Files marked **(template)** are patched at container start from `.env` (`HOST_IP`, `LIDAR_IP`). Edit `.env` and restart — no rebuild needed.

## Files to edit

| File | When to edit |
|------|--------------|
| `.env` | Switch `ROS_DISTRO` (`jazzy`/`kilted`/`lyrical`), `HOST_IP`, `LIDAR_IP`, `ROS_DOMAIN_ID` |
| `config/livox/MID360_config.json` **(template)** | LiDAR network, point format, scan pattern, extrinsics |
| `src/livox_ros/launch_ROS2/msg_MID360_launch.py` | `xfer_format`, `publish_freq`, `multi_topic`, `frame_id` |
| `config/rko_lio/params.yaml` | Voxel size, map range, topic remaps for RKO-LIO |
| `docker-compose.yml` | Add `privileged`, extra mounts, change `command` |

## `config/livox/MID360_config.json`

Source: Livox SDK2 comm protocol (`livox_wiki_en/.../mid360/livox_eth_protocol_mid360.md`). Ports are fixed per product.

| Field | Default | Effect |
|-------|---------|--------|
| `lidar_summary_info.lidar_type` | `8` | Protocol index — **do not change** |
| `MID360.lidar_net_info.{cmd,push,point,imu,log}_data_port` | `56100,56200,56300,56400,56500` | LiDAR-side ports (**do not change**) |
| `MID360.host_net_info.{cmd,push,point,imu}_data_ip` | `192.168.1.5` | Must equal host NIC static IP — patched from `HOST_IP`. Mismatch → no data |
| `MID360.host_net_info.{cmd,push,point,imu}_data_port` | `56101,56201,56301,56401` | Host-side ports (default) |
| `lidar_configs[0].ip` | `192.168.1.12` | LiDAR IP (label on device). Single entry for one Mid360; add more for multi-lidar |
| `lidar_configs[0].pcl_data_type` | `1` | `1`=Cartesian 32-bit, `2`=Cartesian 16-bit, `3`=Spherical. `1` recommended for RKO-LIO |
| `lidar_configs[0].pattern_mode` | `0` | `0`=non-repeating (dense over time), `1`=repeating, `2`=repeating low-rate |
| `lidar_configs[0].extrinsic_parameter.{roll,pitch,yaw,x,y,z}` | `0` | Mount pose (rad for rpy, cm for xyz if driver expects int — keep `0` and calibrate in RKO-LIO `base_frame`) |

Multi-lidar: duplicate objects in `lidar_configs` and ensure distinct host ports if needed (`docs` in `livox_ros_driver2/README.md` mixed config).

## `launch_ROS2/msg_MID360_launch.py` (ROS params)

| Param | Default | Effect |
|-------|---------|--------|
| `xfer_format` | `1` | `0`=PointCloud2 (`PointXYZRTLT`: x,y,z,intensity,tag,line,timestamp), `1`=CustomMsg (`livox_ros_driver2/msg/CustomMsg`), `2`=PCL `PointXYZI` (ROS1 only). Use `0` for RKO-LIO/Fast-LIO compatibility, `1` for Livox viewer |
| `multi_topic` | `0` | `0`=all lidars on one topic, `1`=one topic per lidar |
| `publish_freq` | `10.0` | Publish rate Hz. Higher → lower latency, more CPU/bandwidth. Common: 10, 20, 50, max 100 |
| `output_type` | `0` | `0`=standard, `1`=LVX file output |
| `frame_id` | `livox_frame` | TF frame for pointcloud. Should match RKO-LIO `base_frame` or provide static TF |
| `user_config_path` | `../config/livox/MID360_config.json` | Path inside container — mount overrides via `volumes` |
| `data_src` | `0` | `0`=live lidar, else LVX playback |

## `config/rko_lio/params.yaml`

| Param | Default | Effect |
|-------|---------|--------|
| `lidar_topic` / `imu_topic` | `/livox/lidar`, `/livox/imu` | Leave empty for autodetect; set explicitly if multiple topics |
| `voxel_size` | `0.3` | Downsample leaf (m). ↓0.1 denser map, slower; ↑0.5 faster, sparser |
| `max_range` / `min_range` | `100` / `0.3` | Clip points outside; reduce max in cluttered indoor |
| `deskew` | `true` | Motion compensation via IMU — keep true for moving platforms |
| `publish_map` / `map_publish_period` | `true` / `0.5` | Dense map publish — lower period for frequent RViz updates |

## `docker-compose.yml`

| Field | Why |
|-------|-----|
| `network_mode: host` | Required for Livox UDP (now works on both Linux and macOS) |
| `RMW_IMPLEMENTATION=rmw_zenoh_cpp` | Must match external Zenoh router and across containers |
| `ROS_DOMAIN_ID` | Isolate fleets; all services same ID |
| `volumes: ./config/livox/MID360_config.json:ro` | Live config without rebuild (upstream just edits this JSON) |
| `healthcheck: ros2 topic list \| grep livox` | `rko-lio` waits for `livox-driver` healthy |

## Zenoh

An external Zenoh router is expected (your `pixi` project). Containers only set `RMW_IMPLEMENTATION=rmw_zenoh_cpp` — no extra Docker setup.

Upstream per `Livox-SDK2` ( `cmake .. && make -j && sudo make install`) and `livox_ros_driver2` (`./build.sh humble` → `colcon build`) is kept simple; our Dockerfiles just wrap those same 4 lines. RKO-LIO follows upstream `sudo apt install ros-$ROS_DISTRO-rko-lio` or `ros2 launch rko_lio odometry.launch.py` (autodetect topics/frames — no extra params needed).

## Choosing values

- **Indoor / slow**: `pattern_mode 0` (non-repeating, denser), `publish_freq 10`, `voxel_size 0.2`.
- **Outdoor / fast**: `pcl_data_type 1`, `publish_freq 20`, `max_range 70` (Mid360 40 m @10 % reflectivity, 70 m @80 %).
- **Multi-lidar**: `multi_topic 1`, distinct `ports` per unit, `frame_id` per lidar with extrinsics.
