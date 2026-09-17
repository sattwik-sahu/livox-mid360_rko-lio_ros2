#!/bin/bash
set -e
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
export ROS_DOMAIN_ID=${ROS_DOMAIN_ID:-0}
echo "[zenoh] checking external router (started via your pixi project)..."
echo "[zenoh] RMW_IMPLEMENTATION=$RMW_IMPLEMENTATION ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
echo "[zenoh] listing nodes (should include external rmw_zenohd)..."
timeout 5 ros2 node list || echo "[zenoh] ros2 node list timed out — check RMW_IMPLEMENTATION and that pixi Zenoh router is running"
echo "[zenoh] topics:"
timeout 5 ros2 topic list || true
echo "[zenoh] hint: start router externally, e.g. pixi run zenoh-router  or  ros2 run rmw_zenoh_cpp rmw_zenohd"
