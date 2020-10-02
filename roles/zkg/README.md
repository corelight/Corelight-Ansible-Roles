# Corelight Zeek Package Manager Ansible Role

User provided information and variables are expected to be in the 'common' folder by default.  It simplifies using a single secrets file, inventory file, and vars file across all roles.  If a main.yml file exists in the vars folder for a specific role, it will automatically be included in that role only.  This includes Input Framework files and Custom Suricata Rules files.

The Software Sensor Role will install, configure and license the Corelight Software Sensor on any Linux system, including Raspberry Pis.  This role will:

## zkg Installation

- This role does not include the initial setup of the host OS.
- Install zkg with pip3 on the host running Ansible
- Install zkg dependencies on the host running Ansible

## corelight-client Installation

- Install the corelight-client on the host running Ansible

## Package Bundle Creation

- To install a package, add the name and path to 'zeek_packages' in the var file
- To automatically upgrade a package (if an upgrade is available when the role is ran), add 'auto_upgrade: yes' to the item in 'zeek_packages' in the var file
- To remove a package, simply remove the package from the 'zeek_packages' in the var file
- If a dependent package is installed, it will automatically be added to the item in the var file as 'dependency: <package name>' to prevent it from being automatically removed the next time the role is ran
- If a package changed, a new bundle will automatically be created to replace the old one
- Automatically upload the bundle to the selected physical or virtual sensors

## Bundle Upload to Sensors

- Currently, the role will upload the bundle to the selected sensors every time the role is ran

The following variables should be added to the inventory file for each host that is different from the default setting:

```yaml
# External Scripts to install or upgrade
# To remove a zeek package, simply remove it from the 'zeek_packages' list.
# To upgrade a zeek package, add 'auto_upgrade: yes' to the package.
# If a dependency is installed, the name of the script will automatically be listed.
zeek_packages:
- name: "script_name"
  path: "script_path"
  dependency: "dependent script name"
  auto_upgrade: yes
```

## Requirements

- **Python3 should already be installed on the host running Ansible**
  - zkg will be installed with python3
  - corelight-client will be installed with python3

## Dependencies

- All sensors need to be placed into groups
  - A parent group called 'sensors' with child groups for the different type of sensors
    - software_sensors
    - physical_sensors
    - virtual_sensors

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
- hosts:                  localhost
  gather_facts:           no
  become:                 yes
  vars_prompt:
  - name:                 target
    prompt:               Please enter the target host name or group name
    private:              no

  tasks:
    - include_role:
        name:             zkg
    - set_fact:
        target_system:    "{{ target }}"
      changed_when:       false

- hosts:                  all
  become:                 yes
  gather_facts:           no
  vars:
    - target:             "{{ hostvars['localhost']['target_system'] }}"

  tasks:
    - include_role:
        name:             zkg
      when:
        - ('physical_sensors' in group_names or 'virtual_sensors' in group_names)
        - (target == inventory_hostname or target == 'all')

```

### Command to run the playbook

```none
ansible-playbook -i common/inventory.yml zkg.yml
```

The playbook will prompt for the name of the Software Sensor to be configured and if the name you provide is an individual host or a group of hosts.  Alternately, you can provide the sensor name with --extra-vars in the command line

```none
ansible-playbook -i common/inventory.yml zkg.yml --extra-vars '{"target":"all"}'
```

If all of the managed hosts use the same SSH password and sudo password, you can have Ansible prompt for each with the options ```--ask-pass --ask-become-pass```

If you are using the secrets file to supply SSH or sudo passwords, use --extra-vars to load the secrets file at the start of the playbook.

```none
ansible-playbook -i common/inventory.yml zkg.yml --extra-vars '{"target":"all"}' --extra-vars '@common/secrets.yml'
```

If the sensor host has been setup with SSH keys, you will not need to provide the 'ask-pass' or 'become password'.

## License

BSD

## Author Information

Corelight, Inc.
