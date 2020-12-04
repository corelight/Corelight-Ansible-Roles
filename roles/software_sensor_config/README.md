# Corelight Software Sensor Ansible Role

User provided information and variables are expected to be in the 'common' folder by default.  It simplifies using a single secrets file, inventory file, and vars file across all roles.  If a main.yml file exists in the vars folder for a specific role, it will automatically be included in that role only.  This includes Input Framework files and Custom Suricata Rules files.

The Software Sensor Role will install, configure and license the Corelight Software Sensor on any Linux system, including Raspberry Pis.  This role will:

## Software Sensor Installation

- This role does not include the initial setup of the host OS.
- Add the Corelight Repository Keys
- Add the Corelight Repository source
- Install the Corelight Software Sensor
- Customize the Software Sensor's configuration
  - See templates/corelight-softsensor.conf.j2 for all of the Software Sensor configurable variables.
- License the Software Sensor (License must be added to secrets)

The following variables should be added to the inventory file for each host that is different from the default setting:

```yaml
sniff_interfaces: eth0
```

## Input Framework Management

- Copy Input Framework files to the Software Sensor
  - The files to be copied to the sensor Input Framework need to be located in the 'common/files/input_files/' folder.

## Script Package Management

- Install Zeek Package Manager (zkg) and add a configuration file to store scripts in /etc/corelight
- Install, Upgrade, Remove Zeek Scripts

```yaml
corelight_packages:
- cert-hygiene
- ssh-inference
- ConnViz
- datared
- CommunityID
```

```yaml
# To get the current list of included packages type the following command:  'corelight -p'
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

```yaml
# External Scripts to install or upgrade
# To remove a zeek package, simply remove it from the 'zeek_packages' list.
zeek_packages:
- name: "script_name"
  path: "script_path"
  auto_upgrade: yes
```

## Suricata and Suricata-update

- Enable/Disable Suricata  (disabled by default)
- Enable/Disable Suricata-update (disabled by default)
  - disabled = This sensor will not use Suricata-update
  - local = This sensor will run Suricata-update locally
  - remote = This sensor will use Suricata-update running on another host
- The Suricata Rule files to be copied to the sensor need to be located in the 'common/files/suricata_custom_rules/' folder.

The following variables should be added to the inventory file for each host that is different from the default setting:

```yaml
suricata_enable: false                  # true or false
suricata_update_enable: disabled        # disabled, local or remote
```

## Requirements

- **A Corelight Software Sensor License is required (not included here)**
- **To receive the link to the Corelight Repository, the Corelight EULA or Eval Agreement must be accepted**

## Role Variables

- See defaults/main.yml for all of the default settings including Software Sensor settings.
- A secrets.yml file should contain the following variables:

```yaml
corelight_license: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
corelight_repo_url: xxxxxx.corelight.com
sensor_password: "xxxxxxxxx"  #physical or virtual sensors only.
```

## Dependencies

- An inventory file with the minimum information from the example below.
  - ansible_user
  - additional information described above if different from the default settings
- All sensors need to be placed into groups
  - A parent group called 'sensors' with child groups for the different type of sensors
    - Software sensors should be placed in a child group called 'software_sensors'
- A secrets.yml file with the information described above

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

## Example Playbook

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
```

### Command to run the playbook

```none
ansible-playbook -i common/vars/inventory.yml sw-sensor.yml
```

The playbook will prompt for the name of the Software Sensor to be configured and if the name you provide is an individual host or a group of hosts.  Alternately, you can provide the sensor name with --extra-vars in the command line

```none
ansible-playbook -i common/vars/inventory.yml sw-sensor.yml --extra-vars '{"target":"all"}'
```

If all of the managed hosts use the same SSH password and sudo password, you can have Ansible prompt for each with the options ```--ask-pass --ask-become-pass```

If you are using the secrets file to supply SSH or sudo passwords, use --extra-vars to load the secrets file at the start of the playbook.

```none
ansible-playbook -i common/vars/inventory.yml sw-sensor.yml --extra-vars '{"target":"all"}' --extra-vars '@common/vars/secrets.yml'
```

If the sensor host has been setup with SSH keys, you will not need to provide the 'ask-pass' or 'become password'.

## License

BSD

## Author Information

Corelight, Inc.
