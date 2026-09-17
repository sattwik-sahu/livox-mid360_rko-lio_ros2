# syntax=docker/dockerfile:1.6
# Livox Mid360 ROS2 Driver — multi-arch, multi-distro (jazzy/kilted/lyrical)
ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-base AS base

ARG ROS_DISTRO
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    RMW_IMPLEMENTATION=rmw_zenoh_cpp \
    ROS_DISTRO=${ROS_DISTRO}

# System deps (minimal — ROS deps come via rosdep, matching upstream Livox docs)
# Upstream Livox SDK2 only needs cmake + gcc; livox_ros_driver2 deps are resolved via rosdep
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    libpcl-dev \
    libapr1-dev \
    libaprutil1-dev \
    python3-colcon-common-extensions \
    python3-rosdep \
    && rm -rf /var/lib/apt/lists/* \
 && (apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rmw-zenoh-cpp \
    ros-${ROS_DISTRO}-pcl-conversions \
    ros-${ROS_DISTRO}-pcl-msgs \
    ros-${ROS_DISTRO}-ament-cmake-auto \
    ros-${ROS_DISTRO}-rosidl-default-generators \
    ros-${ROS_DISTRO}-rclcpp-components \
    || echo "some ros packages not available for ${ROS_DISTRO}, will rely on rosdep") \
 && rm -rf /var/lib/apt/lists/*

# --- Build Livox SDK2 ---
COPY sdk/livox_sdk /tmp/livox_sdk
RUN cmake -S /tmp/livox_sdk -B /tmp/livox_build -DCMAKE_BUILD_TYPE=Release \
 && cmake --build /tmp/livox_build -j$(nproc) \
 && cmake --install /tmp/livox_build \
 && rm -rf /tmp/livox_build /tmp/livox_sdk

# --- Build livox_ros_driver2 ---
WORKDIR /ws
COPY src/livox_ros /ws/src/livox_ros

# Ensure package.xml matches ROS2 (handled by build.sh logic, but we do it explicitly)
RUN if [ -f /ws/src/livox_ros/package_ROS2.xml ]; then cp /ws/src/livox_ros/package_ROS2.xml /ws/src/livox_ros/package.xml; fi

# Resolve rosdep + colcon build
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
 && rosdep update || true \
 && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} || echo "rosdep install had issues (non-fatal)" \
 && colcon build --cmake-args -DROS_EDITION=ROS2 -DDISTRO_ROS=${ROS_DISTRO} -DCMAKE_BUILD_TYPE=Release

# Runtime env
COPY docker/entrypoint-livox.sh /entrypoint-livox.sh
RUN chmod +x /entrypoint-livox.sh

ENV WS=/ws
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc \
 && echo "source /ws/install/setup.bash" >> /root/.bashrc

ENTRYPOINT ["/entrypoint-livox.sh"]
CMD ["ros2", "launch", "livox_ros_driver2", "msg_MID360_launch.py"]
