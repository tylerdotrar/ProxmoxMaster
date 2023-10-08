# ProxmoxMaster
Central repository for Proxmox configuration scripts, LXC service installation scripts, etc.


## Current Goals & Rules:

Create a centralized repository that can automate the install of self-hosted services in a minimal lab environment, providing customizable configuration options.
- On top of this, ``the code should be visually pleasing and easily readable (even to novices).``

I eventually plan on creating a PVE master script that dynamically pulls and displays all available services as they're added, and allow users to select their desired service or PVE configuration, all from a singular script/URL.

### Rules
- Services have to be built *without* using/relying on Docker.
- Scripts and services have to be able to support HTTPS/SSL certificates.

## Services & Management:

### Syntax:
```bash
# Service Scripts:
bash -c "$(wget -qO- https://github.com/tylerdotrar/ProxmoxMaster/raw/main/services/<SERVICE>.sh)"

# Management Scripts:
bash -c "$(wget -qO- https://github.com/tylerdotrar/ProxmoxMaster/raw/main/management/<SERVICE>.sh)"
```
- ``Note(s):``
  - Service scripts have been tested on tested on both minimal install Ubuntu Server 22.04 LTS VM and Ubuntu Server 22.04 LXC.
  - Management scripts have been tested on my personal hypervisor; read the code and use at your own risk.

### Supported Services

These scripts are custom service installations that provide a moderate level of user input/customization.
- These have been tested on tested on both minimal install Ubuntu Server 22.04 LTS VM and Ubuntu Server 22.04 LXC.

| Script | Status |
| --- | --- |
| ``filegator.sh`` | Pushed |
| ``homer.sh`` | Pushed |
| ``minecraft_server.sh`` | Pushed |
| ``wikijs.sh``| Pushed |
| ``organizr.sh`` | WIP |
| ``passbolt.sh`` | WIP |
| ``pihole.sh`` | WIP |

![Wiki.js Installation](https://cdn.discordapp.com/attachments/620986290317426698/1035667618956329070/unknown.png)
- SSH was enabled, and an SSL certificate/key from my local OPNsense CA was SCP'd into '/etc/ssl/wikijs/'
- Immediately after this screenshot...
  - I was able to access the initial administration page on ``HTTP/3000``.
  - I could navigate to HTTPS/3443 following initial administration configuration.

### Management

These scripts are intended to be ran on the server/node itself.
- These may need to be re-ran after each PVE update.
- All scripts create backups of the target files prior to modification.

| Script | Description |
| --- | --- |
| ``add_cpu_temp_readings.sh`` | Add CPU temperature readings to the Node summary page. |
| ``fix_enterprise_repositories.sh`` | Fix repositories for personal / non-enterprise use. |
| ``remove_subscription_message.sh`` | Remove the 'No valid subscription' login message. |

![Summary](https://cdn.discordapp.com/attachments/855920119292362802/1160693073924345887/image.png?ex=653596a9&is=652321a9&hm=b7462e4f472236279dba49219642db92c69673bbbe5a8a0b94b86cbfa85fa2e4&)

