#!/bin/bash
set -e

# Source ROS
if [ -n "${ROS_DISTRO}" ] && [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi
if [ -f "/ws/install/setup.bash" ]; then
  source "/ws/install/setup.bash"
fi

# Allow HOST_IP / LIDAR_IP env substitution into MID360_config.json if present
CONFIG_SRC="/ws/src/livox_ros/config/MID360_config.json"
CONFIG_DST="/ws/install/livox_ros_driver2/share/livox_ros_driver2/config/MID360_config.json"

# Also check mounted config
if [ -n "${HOST_IP}" ] && [ -f "${CONFIG_SRC}" ]; then
  echo "[entrypoint-livox] HOST_IP=${HOST_IP} LIDAR_IP=${LIDAR_IP:-192.168.1.12} -> patching config"
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<PY
import json, os, pathlib
src = pathlib.Path("${CONFIG_SRC}")
hosts = ["${CONFIG_SRC}", "${CONFIG_DST}", "/ws/config/MID360_config.json"]
host_ip = os.environ.get("HOST_IP")
lidar_ip = os.environ.get("LIDAR_IP", "192.168.1.12")
for p in hosts:
    try:
        fp = pathlib.Path(p)
        if not fp.exists():
            continue
        data = json.loads(fp.read_text())
        if "MID360" in data and "host_net_info" in data["MID360"]:
            h = data["MID360"]["host_net_info"]
            for k in ["cmd_data_ip","push_msg_ip","point_data_ip","imu_data_ip"]:
                if k in h:
                    h[k] = host_ip
        if "lidar_configs" in data:
            for c in data["lidar_configs"]:
                if "ip" in c:
                    c["ip"] = lidar_ip
        fp.write_text(json.dumps(data, indent=2))
        print(f"patched {p}")
    except Exception as e:
        print(f"warn patch {p}: {e}")
PY
  fi
fi

# Zenoh env
export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_zenoh_cpp}
if [ -n "${ZENOH_ROUTER_CHECK}" ]; then
  echo "[entrypoint-livox] waiting for zenoh router..."
  for i in $(seq 1 30); do
    if ros2 node list >/dev/null 2>&1; then break; fi
    sleep 1
  done
fi

exec "$@"
