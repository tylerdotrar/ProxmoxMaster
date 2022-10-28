# ProxmoxMaster
Central repository for Proxmox configuration scripts, LXC service installation scripts, etc.

## Syntax:
```bash
bash -c "$(wget -qO- https://raw.githubusercontent.com/tylerdotrar/ProxmoxMaster/master/services/install_<SERVICE>.sh)"
```
``Note: scripts are being teested on both minimal install Ubuntu Server 22.04 LTS VM and Ubuntu Server 22.04 standard CT.``

## Current Goals & Rules:
### Goal
Create a centralized repository that can automate the install of self-hosted services in a minimal lab environment, providing customizable configuration options.
On top of this, ``the code should be visually pleasing and easily readable (even to novices).``

I eventually plan on creating a PVE master script that dynamically pulls and displays all available services as they're added, and allow users to select their desired service or PVE configuration, all from a singular script/URL.

### Rules
- Services have to be built *without* using/relying on Docker.
- Scripts and services have to be able to support HTTPS/SSL certificates.

## Supported Services:
- Wiki.js
- FileGator ``(WIP)``
- Homer ``(WIP)``
- Organizr ``(WIP)``
- PiHole ``(WIP)``
- Passbolt ``(WIP)``

## Example
![Wiki.js Installation](https://cdn.discordapp.com/attachments/620986290317426698/1035667618956329070/unknown.png)
```
- This was ran on a fresh Ubuntu 22.04 LXC.
- SSH was enabled, and an SSL certificate/key from my local OPNsense CA was SCP'd into '/etc/ssl/wikijs/'
- No other changes were made or updated.
- Immediately after this script:
  --> I was able to access the initial administration page on HTTP/3000.
  --> After initial administration configuration, I could navigate to HTTPS/3443.
```
