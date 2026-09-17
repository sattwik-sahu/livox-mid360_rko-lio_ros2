# syntax=docker/dockerfile:1.6
# RKO-LIO — multi-arch, multi-distro (jazzy/kilted/lyrical)
ARG ROS_DISTRO=jazzy
FROM ros:${ROS_DISTRO}-ros-base

ARG ROS_DISTRO
ENV DEBIAN_FRONTEND=noninteractive \
    RMW_IMPLEMENTATION=rmw_zenoh_cpp \
    ROS_DISTRO=${ROS_DISTRO}

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-rmw-zenoh-cpp \
    ros-${ROS_DISTRO}-pcl-conversions \
    ros-${ROS_DISTRO}-tf2-ros \
    ros-${ROS_DISTRO}-nav-msgs \
    ros-${ROS_DISTRO}-geometry-msgs \
    ros-${ROS_DISTRO}-sensor-msgs \
    python3-colcon-common-extensions \
    git \
    cmake \
    build-essential \
    libpcl-dev \
    libeigen3-dev \
    libomp-dev \
    && rm -rf /var/lib/apt/lists/*

# Try binary install first; fallback to source if not available (e.g. lyrical early)
WORKDIR /ws
RUN apt-get update \
 && (apt-get install -y ros-${ROS_DISTRO}-rko-lio && rm -rf /var/lib/apt/lists/* && echo "rko_lio installed from apt") \
 || (echo "apt package ros-${ROS_DISTRO}-rko-lio not found — building from source" \
     && mkdir -p /ws/src \
     && git clone --depth 1 https://github.com/PRBonn/rko_lio.git /ws/src/rko_lio \
     && . /opt/ros/${ROS_DISTRO}/setup.sh \
     && rosdep update || true \
     && rosdep install --from-paths src --ignore-src -r -y --rosdistro ${ROS_DISTRO} || true \
     && colcon build --packages-select rko_lio --cmake-args -DRKO_LIO_FETCH_CONTENT_DEPS=ON -DCMAKE_BUILD_TYPE=Release \
     && rm -rf /var/lib/apt/lists/*)

# Copy optional local overrides (params, launch) — upstream rko_lio uses `ros2 launch rko_lio odometry.launch.py` autodetect by default, config_file is optional
COPY config/rko_lio/params.yaml /ws/config/rko_lio/params.yaml

COPY docker/entrypoint-rko.sh /entrypoint-rko.sh
RUN chmod +x /entrypoint-rko.sh

RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /root/.bashrc \
 && echo "if [ -f /ws/install/setup.bash ]; then source /ws/install/setup.bash; fi" >> /root/.bashrc

ENTRYPOINT ["/entrypoint-rko.sh"]
CMD ["ros2", "launch", "rko_lio", "odometry.launch.py"]
