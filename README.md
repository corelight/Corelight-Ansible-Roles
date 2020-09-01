# Corelight-Ansible-Roles

Common user provided information and variables are expected to be in the folder 'common-user-provided-info'.  It simplifies using a single secrets file, inventory file, and vars file across all roles.  If a main.yml file exists in the vars folder for a specific role, it will automatically be included in that role only.

## corelight-software-sensor Role

The Software Sensor Role will install, configure and license the Corelight Software Sensor on any Linux system, including Raspberry Pis.

    - For a complete list of Software Sensor configuration options, see corelight-software-sensor/templates/corelight.cfg.j2
    - For a complete list of variables, see corelight-software-sensor/defaults/main.yml
    - If Suricata is enabled and Suricata-update is not used, the custom Suricata rule files to be used (if any) need to be located in the 'files/suricata_custom_rules/' folder.
    - For more details, see corelight-software-sensor/README.md

## corelight-suricata-update Role

The Suricata-update Role will install, configure and manage rule sources for ALL Suricata enabled Corelight Sensors, including Enterprise Sensors.

    - This role will detect the Corelight-Suricata version in use on all sensors and run Suricata-update for each unique version
    - This role will also setup and manage a Cron Job, on any Linux system, to update the Suricata rules daily
    - **Suricata-update will run as the Ansible User, NOT as Root**
    - For a complete list of variables, see corelight-suricata-update/defaults/main.yml
    - For more details, see corelight-suricata-update/README.md

## Corelight-suricata-update-cron-job

This role only executes Suricata-update and does not configure or manage it.  It is only used to run Suricata-update via Ansible and a Cron Job on a daily bases.  All configuration and setup should be performed with the corelight-suricata-update Ansible Role.

## Requirements

- These roles do not include the initial setup of the host OS.
- [ ] **To receive the link to the Corelight Repository, the Corelight EULA or Eval Agreement must be accepted**
- [ ] main-vars.yml file
- [ ] inventory file
- [ ] secrets file
- [ ] secrets file Password file (required for cron job)
- [ ] Configure Ansible with path to secrets file (required for cron job other than localhost)
- [ ] Generate SSH keys on Ansible Controller (including the Cron Job Host) ```ssh-keygen```
- [ ] Copy the SSH keys from the Ansible Controller to the sensor hosts ```ssh-copy-id user@host_address```
- If the cron job is configured to run on a host other than localhost, it will run as the {{ ansible_user }} for that host, make sure the SSH keys are generated for that user and copied to all of the software sensors.

### Primary Software Sensor Variables

```yaml
sniff_interfaces:                       eth0
```

#### Corelight Proprietary Packages to enable

```yaml
corelight_packages:
- cert-hygiene
- ssh-inference
- ConnViz
- datared
- CommunityID
```

#### Included Packages to enable

To get the current list of included packages type the following command:  'corelight -p'

```yaml
included_packages:
- bro-long-connections
- conn-burst
- log-add-vlan-everywhere
- credit-card-exposure
- ssn-exposure
- unknown-mime-type-discovery
- bro-simple-scan
- hassh
- ja3
```

#### Custom Scripts to install

Each package should have a name & path

```yaml
zeek_packages:
- name:                               "script_name"
  path:                               "script_path"
```

#### Custom Scripts to remove

```yaml
remove_packages:
- name:                               "script_name"
```

#### Custom Scripts to upgrade

```yaml
upgrade_packages:
- name:                               "script_name"
```

### Primary Suricata-update Variables

```yaml
suricata_update_enable: disabled
suricata_update_host:                  # host to run Suricata-update on
enable_suricata_secret_code_sources:   # rule sources that require secret codes
- name:        "rule_list_name"
  secret_code:  "xxxxxxxxxx"
enable_suricata_remote_sources:        # rule sources that do not require secret codes
 - 'sslbl/ssl-fp-blacklist'
 - 'et/open'
enable_suricata_custom_url_sources:
 - name: 'abuse.ch-URLhaus-IDS'
   url: 'https://urlhaus.abuse.ch/downloads/urlhaus_suricata.tar.gz'
disable_rules:
  - 2019401
  - re:heartbleed
  - group:emerging*
enable_rules:
  - 2019401
  - re:heartbleed
  - group:emerging*
modify_rules:
  - 2019401 "seconds \d+" "seconds 3600"
```

### Primary Cron Job Variables

```yaml
enable_cron:              false     # true or false
cron_job_hour:            "0"       # 0-23
cron_job_minute:          "0"       # 0-59
cron_job_target:          all       # name of the group or host sensor for Suricata-update
cron_job_host:            localhost # name of the a host **ONLY USE 'localhost' WHEN ANSIBLE AND SURICATA-UPDATE ARE ON SEPARATE HOSTS
```

## Dependencies

- Software Sensor required inventory variables

```yaml
ansible_user:               # username for SSH login
suricata_update_enable:     # local, remote, or disabled
suricata_enable:            # T or F
sniff_interfaces:           # Software Sensor capture interface
```

- Physical or Virtual Sensor required inventory variables

```yaml
ansible_user:               # username for SSH login
suricata_update_enable:     # local, remote, or disabled
UID:                        # for Fleet managed Sensors
```

- A secrets.yml file with a minimum of the following variables:

```yaml
corelight_license:                      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
corelight_repo_url:                     xxxxxx.corelight.com
sensor_password:                        xxxxxxxxx  #physical or virtual sensors only.
enable_suricata_secret_code_sources:
 - name: "rule_list_name"
   secret_code: "xxxxxxxxxxxxxxx"
```

- An inventory file with the minimum information from the example below.  Variables that use the default values do not need to be listed.

- All sensors need to be placed into groups.
  - A parent group called 'sensors' with child groups for the different type of sensors. (software_sensors, physical_sensors, virtual_sensors)
  - If using a stand-alone host for Suricata-update, the host should be placed in a parent group called 'suricata_update_host'.


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
              suricata_enable: T
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

## Included Example Playbooks

- The corelight.yml playbook will include both the corelight-software-sensor and corelight-suricata-update roles.  If you have software sensors in your inventory, this is the recommended playbook to run.
- The sw-sensor.yml playbook will only include the corelight-software-sensor role.
- The suricata-update.yml playbook will only include the corelight-suricata-update role.

### Example corelight.yml playbook

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

```ansible-playbook -i common-user-provided-info/inventory.yml corelight.yml```

The playbook will prompt for the name of the Software Sensor to be configured and if the name you provide is an individual host or a group of hosts.  Alternately, you can provide the sensor name with --extra-vars in the command line

```ansible-playbook -i common-user-provided-info/inventory.yml corelight.yml --extra-vars '{"target":"all"}'```

If all of the managed hosts use the same SSH password and sudo password, you can have Ansible prompt for each with the options ```--ask-pass --ask-become-pass```

If you are using the secrets file to supply SSH or sudo passwords, use --extra-vars to load the secrets file at the start of the playbook.

```ansible-playbook -i common-user-provided-info/inventory.yml corelight.yml --extra-vars '{"target":"all"}' --extra-vars '@common-user-provided-info/secrets.yml'```

If the sensor host has been setup with SSH keys, you will not need to provide the 'ask-pass' or 'become password'.

## License

BSD

## Author Information

Corelight, Inc.
