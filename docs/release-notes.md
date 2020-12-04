# Corelight-Ansible-Roles Release Notes

v1.1.0

## zkg Role

- New role to automate installation, upgrading and/or removing Zeek Packages.
  - To install a package, add the name and path to 'zeek_packages' in the var file
  - To automatically upgrade a package (if an upgrade is available when the role is ran), add 'auto_upgrade: yes' to the item in 'zeek_packages' in the var file
  - To remove a package, simply remove the package from the 'zeek_packages' in the var file
- Automatically create a new bundle (if a package changed)
- Automatically upload the bundle to the selected physical or virtual sensors

## Software Sensor Role

- Simplified Zeek Package management to match the zkg Role

## Scripts

- Added an example script for the zkg role

v1.0.0

## Common

- Combined all roles into a single repository
- Added 'common' fold to store all user provided variables, including the following:
  - Input Framework files (if any)
  - Suricata custom rule files (if any)
  - inventory.yml file
  - main-vars.yml file
  - secrets.yml file

## Scripts

- Added an optional scripts folder with example commands to run the playbooks
- The Scripts can be ran 'AS IS' directly from the scripts folder
- Any modified scripts should be renamed to start with ansible so they are not replaced on the next 'git pull'

## Software Sensor Role

- Manage all Software Sensor settings
- Manage all Corelight and Open Source packages
- Manage custom Input Framework files
- Added all default Input Framework files that are included on the physical sensors

## Suricata

- Manage custom Suricata rules files (if Suricata-update is not enabled)
- Added support for modifying Suricata address groups on both physical and software sensors (via Suricata-update role)

## Suricata-update Role

- Suricata-update runs as the local defined user, NOT as root
- Manage all Suricata rule sources, including custom rules files
- Collect Corelight-Suricata version information from all sensors in the inventory
- Run Suricata-update once for each version
- Create a Cron Job to run Suricata-update daily (can run locally or on a designated host)

## Suricata-update-cron-job Role

- Simplified Suricata-update role that only runs Suricata-update, it will not modify any sources or install any software updates
- Primary use is for the daily cron job
