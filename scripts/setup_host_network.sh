#!/bin/bash
set -euo pipefail

# Configure host Ethernet for Livox Mid360 static IP connectivity.
# Usage: sudo ./scripts/setup_host_network.sh [interface] [host_ip] [lidar_ip]
# Example: sudo ./scripts/setup_host_network.sh eth0 192.168.1.5 192.168.1.12

IFACE="${1:-eth0}"
HOST_IP="${2:-${HOST_IP:-192.168.1.5}}"
LIDAR_IP="${3:-${LIDAR_IP:-192.168.1.12}}"

echo "[setup] IFACE=${IFACE} HOST_IP=${HOST_IP} LIDAR_IP=${LIDAR_IP}"

# Add static IP (idempotent)
if ip addr show "${IFACE}" | grep -q "${HOST_IP}/24"; then
  echo "[setup] ${HOST_IP}/24 already on ${IFACE}"
else
  echo "[setup] adding ${HOST_IP}/24 to ${IFACE}"
  ip addr add "${HOST_IP}/24" dev "${IFACE}" || true
  ip link set "${IFACE}" up
fi

# Increase UDP buffers for high-rate pointcloud
sysctl -w net.core.rmem_max=33554432 >/dev/null 2>&1 || true
sysctl -w net.core.rmem_default=33554432 >/dev/null 2>&1 || true

# Firewall (ufw)
if command -v ufw >/dev/null 2>&1 && ufw status | grep -q "Status: active"; then
  echo "[setup] opening UDP 56000-56500 via ufw"
  ufw allow 56000:56500/udp || true
fi

echo "[setup] pinging LiDAR ${LIDAR_IP} (5s)..."
if ping -c 3 -W 2 "${LIDAR_IP}" >/dev/null 2>&1; then
  echo "[setup] ✓ LiDAR reachable"
else
  echo "[setup] ✗ LiDAR NOT reachable — check cable/power/IP"
  echo "       Try: ip addr show ${IFACE} ; ping ${LIDAR_IP}"
  exit 1
fi

echo "[setup] done. You can now run: docker compose up"
