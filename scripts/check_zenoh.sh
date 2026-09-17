#!/bin/bash
set -e
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
echo "[zenoh] checking router..."
if docker ps --format '{{.Names}}' | grep -q zenoh-router; then
  echo "[zenoh] zenoh-router container running"
else
  echo "[zenoh] zenoh-router NOT running — run: docker compose up -d zenoh-router"
  exit 1
fi
echo "[zenoh] listing nodes (should include rmw_zenohd)..."
timeout 5 ros2 node list || echo "[zenoh] ros2 node list timed out — check RMW_IMPLEMENTATION"
echo "[zenoh] topics:"
timeout 5 ros2 topic list || true
