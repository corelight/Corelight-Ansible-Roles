# Corelight-Ansible-Roles

User provided information and variables are expected to be in the 'common' folder by default.  It simplifies using a single secrets file, inventory file, and vars file across all roles.  If a main.yml file exists in the vars folder for a specific role, it will automatically be included in that role only.  This includes Input Framework files and Custom Suricata Rules files.

## corelight-software-sensor Role

The Software Sensor Role will install, configure and license the Corelight Software Sensor on any Linux system, including Raspberry Pis.  This role will:

```none
- These roles do not include the initial setup of the host OS.
- Manage the Software Sensor configuration, to include:
    - HEC (HTTP Even Collector) Configuration
    - Kafka Configuration
    - JSON over TCP Configuration
    - JSON over TCP Syslog Configuration
    - Redis Configuration
    - Batch Log Configuration
    - File Extraction Configuration
    - Metrics Configuration (prometheus)
- Manage the Corelight Proprietary Packages
- Manage the Pre-bundled Open Source Zeek Packages
- Manage External Zeek Packages with ZKG
- Manage Input Framework files
- If Suricata is enabled and Suricata-update is disabled, the custom Suricata rule files to be copied to the Software Sensor in the /etc/corelight/rules folder by default.
- If Suricata is enabled and Suricata-update is also enabled (local or remote), the custom Suricata rules files will not be copied to the Software Sensor.  They will be managed by Suricata-update.
```

- For a complete list of Software Sensor configuration options, see corelight-software-sensor/templates/corelight.cfg.j2
- For a complete list of variables, see corelight-software-sensor/defaults/main.yml
- For more details, see corelight-software-sensor/README.md

## corelight-suricata-update Role

The Suricata-update Role will install, configure and manage rule sources for ALL Suricata enabled Corelight Sensors, including Enterprise Sensors.  It can also modify any of the predefined Suricata address-groups on both the software sensor and Enterprise Sensors.  Additionally, this role can create, modify, enable or disable a cron job to update Suricata rules daily.  This role will:

```none
- configure Suricata-update rule sources
- modify predefined Suricata address-groups on both the Software Sensor and Enterprise Sensors
- detect the Corelight-Suricata version in use on all sensors and run Suricata-update for each unique version
- setup and manage a Cron Job, on any Linux system, to update the Suricata rules daily
- **run Suricata-update as the Ansible User, NOT as Root**
```

- For a complete list of variables, see corelight-suricata-update/defaults/main.yml
- For more details, see corelight-suricata-update/README.md

## Corelight-suricata-update-cron-job Role

This role only executes Suricata-update and does not configure or manage it.  It is used to run Suricata-update via Ansible and a Cron Job on a daily bases.  All configuration and setup should be performed with the corelight-suricata-update Ansible Role.

```none
- detect the Corelight-Suricata version in use on all sensors and run Suricata-update for each unique version
- **run Suricata-update as the Ansible User, NOT as Root**
```

## zkg Role

This role automates the installation, upgrading and/or removing Zeek Packages on physical or virtual sensors.  Software Sensors packages are managed with the corelight-software-sensor Role.

```none
- To install a package, add the name and path to 'zeek_packages' in the var file
- To automatically upgrade a package (if an upgrade is available when the role is ran), add 'auto_upgrade: yes' to the item in 'zeek_packages' in the var file
- To remove a package, simply remove the package from the 'zeek_packages' in the var file
- If a dependent package is installed, it will automatically be added to the item in the var file as 'dependency: <package name>'
- Automatically create a new bundle (if a package changed)
- Automatically upload the bundle to the selected physical or virtual sensors
```

## Requirements

- [ ] **To receive the link to the Corelight Repository, the Corelight EULA or Eval Agreement must be accepted**
- [ ] main-vars.yml file
- [ ] inventory file
- [ ] secrets file
- [ ] secrets file Password file (required for cron job)
- [ ] Configure Ansible with path to secrets file (required for cron job other than localhost)
- [ ] Generate SSH keys on Ansible Controller (including the Cron Job Host) ```ssh-keygen```
- [ ] Copy the SSH keys from the Ansible Controller to the sensor hosts ```ssh-copy-id user@host_address```
- If the cron job is configured to run on a host other than localhost, it will run as the {{ ansible_user }} for that host, make sure the SSH keys are generated for that user and copied to all of the software sensors.

## Dependencies

## Example Inventory file - (this is just one of several possible inventory file formats)

```yaml
all:
  children:
    suricata_update_host:
      hosts:
        host1:
          ansible_host: ip.address
          ansible_user: username
          suricata_update_enable: local
    sensors:
      children:
        software_sensors:
          hosts:
            swsensor1:
              ansible_host: ip.address
              ansible_user: username
              sniff_interfaces: ens192
              suricata_enable: true
              suricata_update_enable: remote
            swsensor2:
              ansible_host: ip.address
              ansible_user: username
        physical_sensors:
          hosts:
            AP200:
              ansible_host: ip.address
              sensor_username: username
            AP200-2:
              ansible_host: ip.address
              suricata_update_enable: remote
              UID:
        virtual_sensors:
          hosts:
            vSensor1:
              ansible_host: ip.address
              sensor_username: username
  vars:
    fleet_ip:
```

## Included Playbooks

- The corelight.yml playbook will include both the corelight-software-sensor and corelight-suricata-update roles.  If you have software sensors in your inventory, this is the recommended playbook to run.
- The sw-sensor-install.yml playbook will include the corelight-software-sensor role.  It will install and configure the Software Sensor.
- The sw-sensor-update.yml playbook will also include the corelight-software-sensor role.  However, it will only update the Software Sensor config.  It will not install anything.
- The suricata-update.yml playbook will include the corelight-suricata-update role.  It will install, configure and run Suricata-update.
- The suricata-update-cron-job.yml will include the corelight-suricata-update-cron-job role.  It will only run Suricata-update.  It will not install anything or modify Suricata-update sources.

### corelight.yml playbook

```yaml
---
- hosts: all
  gather_facts: no
  become: yes
  vars_prompt:
  - name: target
    prompt: Please enter the target host name or group name
    private: no


  tasks:
    - include_role:
        name: corelight-software-sensor
      when:
        - "'software_sensors' in group_names"
        - (target == inventory_hostname or target == 'all')

    - include_role:
        name: corelight-suricata-update
```

### Command to run the playbook

```none
ansible-playbook -i common/inventory.yml playbooks/corelight.yml
```

The playbook will prompt for the name of the Software Sensor to be configured and if the name you provide is an individual host or a group of hosts.  Alternately, you can provide the sensor name with --extra-vars in the command line

```none
ansible-playbook -i common/inventory.yml playbooks/corelight.yml --extra-vars '{"target":"all"}'
```

If all of the managed hosts use the same SSH password and sudo password, you can have Ansible prompt for each with the options ```--ask-pass --ask-become-pass```

If you are using the secrets file to supply SSH or sudo passwords, use --extra-vars to load the secrets file at the start of the playbook.

```none
ansible-playbook -i common/inventory.yml playbooks/corelight.yml --extra-vars '{"target":"all"}' --extra-vars '@common/secrets.yml'
```

If the sensor host has been setup with SSH keys, you will not need to provide the 'ask-pass' or 'become password'.

### Example scripts have also been included to simplify the commands to run the playbooks

- The scripts are setup to run from the scripts directory.
- If you modify the scripts, rename them to start with ansible* so they are not overwritten on the next 'git pull'.

## License

BSD

## Author Information

Corelight, Inc.
