# ProxmoxMaster
Central repository for Proxmox configuration scripts, LXC service installation scripts, etc.

## Usage

```shell
# Using wget
bash -c "$(wget -qO- https://tylerdotrar.github.io/ProxmoxMaster)"

# Using curl
bash -c "$(curl -sL https://tylerdotrar.github.io/ProxmoxMaster)"
```

![image](https://github.com/user-attachments/assets/a232df7e-63ab-4c20-9c8d-dffae335fca4)
_(Note: `menu.sh` is being hosted via Github Pages as `index.html` in a separate branch)_

## Current Goals & Rules:

**Goals:**
- Create a centralized repository that can automate the install of self-hosted services in a minimal lab environment, providing customizable configuration options.
- On top of this, ``the code should be visually pleasing and easily readable (even to novices).``

**Rules:**
- Services have to be built *without* using/relying on Docker.
- Web-based services have to be able to support HTTPS/SSL certificates.
- Services should have straightforward configuration options before being installed.

## Services & Management:

### Management Scripts

```
# Manual Execution (ignoring the master menu):
bash -c "$(wget -qO- https://github.com/tylerdotrar/ProxmoxMaster/raw/main/management/<FUNCTION_NAME>.sh)"
```

These scripts are intended to be ran on the Proxmox server/node itself.
- These may need to be re-ran after each PVE update.
- All scripts create backups of the target files prior to modification (original filename + `.bak`)

| Script | Description |
| --- | --- |
| ``add_cpu_temp_readings.sh`` | Add CPU temperature readings to the Node summary page. |
| ``fix_enterprise_repositories.sh`` | Fix repositories for personal / non-enterprise use. |
| ``remove_subscription_message.sh`` | Remove the 'No valid subscription' login message. |

_(Below is an example of the `add_cpu_temp_readings.sh` script.)_

![CPU Temps CLI](https://github.com/tylerdotrar/ProxmoxMaster/assets/69973771/5506d5d3-c704-4204-9117-c2d19abdc9d7)
![CPU Temps GUI](https://github.com/tylerdotrar/ProxmoxMaster/assets/69973771/173c0380-c81e-4579-8a12-0463e889010d)

### Supported Services

```bash
# Manual Execution (ignoring the master menu):
bash -c "$(wget -qO- https://github.com/tylerdotrar/ProxmoxMaster/raw/main/services/<SERVICE_NAME>.sh)"
```

These scripts are intended to be ran on fresh LXC's/VM's, NOT the Proxmox server/node itself.
- Service scripts have been tested on tested on both a minimal install Ubuntu Server 22.04 LTS VM and Ubuntu Server 22.04 LXC.
- These scripts are custom service installations that provide a moderate level of user input/customization prior to install.

| Script | Status |
| --- | --- |
| ``wireguard_server.sh`` | Pushed |
| ``minecraft_server.sh`` | Pushed |
| ``filegator.sh`` | Pushed |
| ``homer.sh`` | Pushed |
| ``wikijs.sh``| Pushed |
| ``nextcloud.sh`` | WIP |
| ``organizr.sh`` | WIP |
| ``passbolt.sh`` | WIP |
| ``pihole.sh`` | WIP |
| ``samba.sh`` | WIP |
