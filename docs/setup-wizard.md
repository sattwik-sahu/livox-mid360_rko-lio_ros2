---
layout: default
title: Setup Wizard
nav_order: 3
permalink: /setup-wizard/
---

# Setup Wizard

Pick your **OS**, **architecture**, and **ROS 2 distro** — commands below update live. Copy-paste to get running.

<div id="wizard" style="border:1px solid #ddd; border-radius:8px; padding:16px; margin:16px 0; background:#fafafa">
  <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(180px,1fr)); gap:12px; margin-bottom:16px">
    <label>OS
      <select id="os" style="width:100%; padding:6px; margin-top:4px">
        <option value="linux">Linux (Ubuntu 22.04/24.04)</option>
        <option value="mac">macOS (Mac Mini osx-arm64)</option>
      </select>
    </label>
    <label>Arch
      <select id="arch" style="width:100%; padding:6px; margin-top:4px">
        <option value="amd64">amd64 (x86_64)</option>
        <option value="arm64">arm64 (aarch64) — Mac Mini default</option>
      </select>
    </label>
    <label>ROS 2 Distro
      <select id="distro" style="width:100%; padding:6px; margin-top:4px">
        <option value="jazzy">jazzy (LTS, recommended)</option>
        <option value="kilted">kilted</option>
        <option value="lyrical">lyrical</option>
      </select>
    </label>
  </div>
  <div style="display:flex; gap:8px; margin-bottom:12px">
    <label>Host NIC <input id="iface" value="eth0" style="padding:6px; width:110px" placeholder="eth0"/></label>
    <label>Host IP <input id="hostip" value="192.168.1.5" style="padding:6px; width:130px"/></label>
    <label>LiDAR IP <input id="lidarip" value="192.168.1.12" style="padding:6px; width:130px"/></label>
  </div>
  <div id="warn" style="padding:8px 12px; border-radius:6px; margin-bottom:12px; display:none"></div>
  <button id="copyAll" style="padding:8px 16px; cursor:pointer">Copy all commands</button>
  <span id="copyStatus" style="margin-left:8px; color:#1a7f37"></span>
</div>

## 1. Install prerequisites

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step1" class="highlight"></pre></div></div>

## 2. Clone & configure

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step2" class="highlight"></pre></div></div>

## 3. Host network

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step3" class="highlight"></pre></div></div>

## 4. Pull or build images

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step4" class="highlight"></pre></div></div>

## 5. Launch

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step5" class="highlight"></pre></div></div>

## 6. Verify

<div class="language-bash highlighter-rouge"><div class="highlight"><pre id="step6" class="highlight"></pre></div></div>

<script>
(function(){
  const $ = id => document.getElementById(id);
  const els = {os:$('os'), arch:$('arch'), distro:$('distro'), iface:$('iface'), hostip:$('hostip'), lidarip:$('lidarip'), warn:$('warn')};
  const out = {s1:$('step1'), s2:$('step2'), s3:$('step3'), s4:$('step4'), s5:$('step5'), s6:$('step6')};
  function render(){
    const os = els.os.value, arch = els.arch.value, distro = els.distro.value;
    const iface = els.iface.value.trim()||'eth0', hostip=els.hostip.value.trim()||'192.168.1.5', lidarip=els.lidarip.value.trim()||'192.168.1.12';
    const isMac = os==='mac';
    const composeFile = isMac ? 'docker compose -f docker-compose.yml -f docker-compose.mac.yml' : 'docker compose';
    // warnings
    let w=''; let bg='#fff3cd', border='#ffe69c', color='#664d03';
    if(isMac){
      w = '<strong>macOS note:</strong> Docker Desktop has no <code>host</code> networking. This wizard uses <code>docker-compose.mac.yml</code> (bridge + explicit UDP ports). Multicast discovery (56000) is best-effort — prefer <a href="https://orbstack.dev">OrbStack</a> or <a href="https://github.com/abiosoft/colima">Colima</a> with host networking for reliable operation.';
    } else if(arch==='arm64'){
      w = 'You selected <strong>Linux arm64</strong> — images are multi-arch, <code>docker pull</code> selects the correct variant automatically. Build with <code>buildx</code> if cross-compiling.';
    }
    if(w){ els.warn.innerHTML=w; els.warn.style.display='block'; els.warn.style.background=bg; els.warn.style.border='1px solid '+border; els.warn.style.color=color; } else { els.warn.style.display='none'; }

    out.s1.textContent = isMac
      ? '# macOS — install Docker Desktop (or OrbStack) + git\n# https://docs.docker.com/desktop/setup/install/mac-install/  or  brew install --cask orbstack\nbrew install git  # if needed\ndocker --version && docker compose version'
      : '# Ubuntu — Docker Engine + Compose v2\nsudo apt-get update && sudo apt-get install -y docker.io docker-compose-plugin git\nsudo usermod -aG docker $USER  # re-login after\ndocker --version && docker compose version';

    out.s2.textContent =
`git clone https://github.com/sattwik-sahu/livox-mid360_rko-lio_ros2.git
cd livox-mid360_rko-lio_ros2
cp .env.example .env
# Edit .env — set these three:
# ROS_DISTRO=${distro}
# HOST_IP=${hostip}
# LIDAR_IP=${lidarip}
printf "ROS_DISTRO=${distro}\\nHOST_IP=${hostip}\\nLIDAR_IP=${lidarip}\\nROS_DOMAIN_ID=0\\n" > .env
cat .env`;

    out.s3.textContent = isMac
      ? `# macOS: set static IP via System Settings → Network → Ethernet → Details → TCP/IP → Manual\n# IP: ${hostip}  Netmask: 255.255.255.0  (leave Router empty)\n# Verify LiDAR reachable:\nping -c 3 ${lidarip}\n# If using OrbStack/Colima with host networking, you can also run the Linux helper:\n# sudo ./scripts/setup_host_network.sh ${iface} ${hostip} ${lidarip}`
      : `sudo ./scripts/setup_host_network.sh ${iface} ${hostip} ${lidarip}
ping -c 3 ${lidarip}
ip addr show ${iface} | grep ${hostip}`;

    const ghcrLivox = `ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/livox-driver:${distro}`;
    const ghcrRko   = `ghcr.io/sattwik-sahu/livox-mid360_rko-lio_ros2/rko-lio:${distro}`;
    out.s4.textContent =
`# Option A — prebuilt multi-arch from GHCR (recommended, ~30s)
docker pull ${ghcrLivox}
docker pull ${ghcrRko}
# (compose will also pull automatically)
${composeFile} pull

# Option B — build locally (multi-arch manifest)
# docker buildx create --use   # first time only
# docker buildx build --platform linux/${arch} -f Dockerfile.livox --build-arg ROS_DISTRO=${distro} -t ${ghcrLivox} --load .
# docker buildx build --platform linux/${arch} -f Dockerfile.rko-lio --build-arg ROS_DISTRO=${distro} -t ${ghcrRko} --load .
${composeFile} build`;

    out.s5.textContent =
`${composeFile} up -d
${composeFile} logs -f
# In another terminal:
${composeFile} ps`;

    out.s6.textContent =
`${composeFile} exec livox-driver ros2 topic list | grep -E "livox|point"
${composeFile} exec livox-driver ros2 topic hz /livox/lidar --window 5
${composeFile} exec rko-lio ros2 topic echo /odom --once
./scripts/check_zenoh.sh
# RViz (Linux with X11):
# xhost +local:docker
# docker compose exec livox-driver ros2 launch livox_ros_driver2 rviz_MID360_launch.py  # if image has rviz
`;
  }
  ['change','input'].forEach(ev=>{
    ['os','arch','distro','iface','hostip','lidarip'].forEach(id=>{
      const e=$(id); e.addEventListener(ev, render);
    });
  });
  $('copyAll').addEventListener('click', ()=>{
    const all = [out.s1,out.s2,out.s3,out.s4,out.s5,out.s6].map(e=>e.textContent).join('\n\n');
    navigator.clipboard.writeText(all).then(()=>{
      const s=$('copyStatus'); s.textContent='Copied!'; setTimeout(()=>s.textContent='',1500);
    });
  });
  render();
})();
</script>

{: .note }
> After the wizard, see the [Tutorial](tutorial/) for networking deep-dives and [Configuration](configuration/) for every tunable.

