#!/bin/bash
set -e

if [ -n "${ROS_DISTRO}" ] && [ -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]; then
  source "/opt/ros/${ROS_DISTRO}/setup.bash"
fi
if [ -f "/ws/install/setup.bash" ]; then
  source "/ws/install/setup.bash"
fi

export RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION:-rmw_zenoh_cpp}

# Wait for livox topics if requested
if [ "${WAIT_FOR_LIDAR}" = "1" ]; then
  echo "[entrypoint-rko] waiting for /livox/lidar ..."
  for i in $(seq 1 60); do
    if ros2 topic list 2>/dev/null | grep -q "livox"; then
      echo "[entrypoint-rko] lidar topic detected"
      break
    fi
    sleep 1
  done
fi

exec "$@"
