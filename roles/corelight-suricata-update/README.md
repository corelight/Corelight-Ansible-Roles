# Suricata-update Ansible Role

User provided information and variables are expected to be in the 'common' folder by default.  It simplifies using a single secrets file, inventory file, and vars file across all roles.  If a main.yml file exists in the vars folder for a specific role, it will automatically be included in that role only.  This includes Input Framework files and Custom Suricata Rules files.

The Suricata-update Role will install and configure Suricata-update on any Linux system, including the same system Corelight Software Sensor is running on.  This role will:

## Suricata-update Installation

- This role does not include the initial setup of the host OS.
- Install the Corelight-client on the localhost
- Install Suricata-update and it's dependencies
- Suricata-update will run as the Ansible User, **NOT as Root**

## Suricata-update Configuration

- Create Suricata-update config file (update.yaml)
- Detect Corelight-Suricata version information for all sensors in the inventory
- Run Suricata-update once for each version
- Copy the respective suricata.rules file to each enabled sensor

```yaml
suricata_update_enable: false           # false, local or remote
suricata_update_host:                   # host to run Suricata-update on
```

## Suricata-update Rules

- Create/Manage disable.conf
- Create/Manage enable.conf
- Create/Manage modify.conf
- Copy Custom Suricata Rules files to the update host
  - The Suricata Rule files to be copied to the update host need to be located in the 'common/files/suricata_custom_rules/' folder.
- Manage Suricata-update rule sources

```yaml
enable_suricata_secret_code_sources:        # rule sources that require secret codes
- name:        "rule_list_name"
  secret_code:  "xxxxxxxxxx"
enable_suricata_remote_sources:             # rule sources that do not require secret codes
 - 'sslbl/ssl-fp-blacklist'
 - 'et/open'
enable_suricata_custom_url_sources:         # rules sources not in the index
 - name: 'abuse.ch-URLhaus-IDS'
   url: 'https://urlhaus.abuse.ch/downloads/urlhaus_suricata.tar.gz'

disable_rules:                              # rules to disable
  - 2019401
  - re:heartbleed
  - group:emerging*
enable_rules:                               # rules to enable
  - 2019401
  - re:heartbleed
  - group:emerging*
modify_rules:                               # rules to modify
  - 2019401 "seconds \d+" "seconds 3600"
```

## Suricata_update address-groups

- modify the pre-defined Suricata address-groups
  - HTTP_SERVERS:
  - SMTP_SERVERS:
  - SQL_SERVERS:
  - DNS_SERVERS:
  - TELNET_SERVERS:
  - AIM_SERVERS:
  - DC_SERVERS:
  - DNP3_SERVER:
  - DNP3_CLIENT:
  - MODBUS_CLIENT:
  - MODBUS_SERVER:
  - ENIP_CLIENT:
  - ENIP_SERVER:

To receive the modified address-groups:

- Software Sensors need the variable 'suricata_enable: "true"'
- Physical Sensors need the variable 'suricata_update_enable: "remote"'

NOTE: suricata_address_groups must be a valid IP or CIDR or one of the following variables: $HOME_NET, $EXTERNAL_NET, any. You can use signs like ‘!’ and ‘[]’, e.g. ![255.255.255.255,0.0.0.0/16]. Heading/trailing whitespaces, whitespaces between list items, and whitespaces around the '!' symbol are allowed.

### Example main vars file entry

```yaml
suricata_address_groups:
  - name: AIM_SERVERS
    group: "[192.168.1.100,192.168.2.0/24]"
  - name: DNS_SERVERS
    group: "[192.168.1.7,192.168.1.8]"
```

## Cron Job host setup

- for localhost, nothing is cloned and no files are copied
- Running the cron job on a host other than localhost requires additional variables to be defined to ensure all of the required files are copied to the cron job host (if they are not in the default location)
- Add Ansible Repository
- Install Ansible and it's dependencies
- Install the Corelight-client and it's dependencies
- Clone this repo <https://github.com/corelight/Corelight-Ansible-Roles.git> to the cron job host to run the corelight-suricata-update-cron-job role
- Copy the Ansible config
- Copy the main-vars file
- Copy the inventory file
- Copy the Secrets file
- Copy the secrets password file
- The cron job host needs to be able to SSH to all the host in the inventory with keys

```yaml
secrets_path:      "../../../common/secrets.yml"   # path is relative to the task directory
inventory_path:    "../../../common/inventory.yml" # path is relative to the task directory
main_vars_path:    "../../../common/main-vars.yml" # path is relative to the task directory
secrets_pswd_file: "/secret file name in a secret location" # add to the secrets file
```

## Create a Cron Job to run Suricata-update daily

- Create a cron job on the localhost OR the selected Suricata-update Host
  - to run the cron job on the localhost, see the **Important Note** below
- Allow the user to select the hour and minute of the day to run

```yaml
enable_cron:     false      # true or false (setting to false will remove an existing cron job)
cron_job_hour:   "0"        # 0-23
cron_job_minute: "0"        # 0-59
cron_job_target: all        # name of the group or host sensor for Suricata-update
cron_job_host:   host1      # name of the a host **ONLY USE 'localhost' WHEN ANSIBLE AND SURICATA-UPDATE ARE ON SEPARATE HOSTS
```

**Important Note:**  ONLY USE 'localhost' as the 'cron_job_host' when Ansible and the cron job are on localhost and Suricata-update is on a remote host.  If Ansible, the cron job and Suricata-update are all on the same 'localhost', use the hosts name in the inventory file and add the following variable to the host:

```yaml
ansible_connection: local
```

```yaml
all:
  children:
    suricata_update_host:
      hosts:
        this_local_machines_name:
          suricata_update_enable: local
          ansible_connection: local
```

## Requirements

## Role Variables

- See defaults/main.yml for all of the default settings including Suricata-update settings.
- A secrets.yml file should contain the following variables:

```yaml
corelight_repo_url: xxxxxx.corelight.com
sensor_password: xxxxxxxxx  #physical or virtual sensors only.

enable_suricata_secret_code_sources:
 - name: "rule_list_name"
   secret_code: "xxxxxxxxxxxxxxx"
```

## Dependencies

- An inventory file with the minimum information from the example below.
  - ansible_user
  - additional information described above if different from the default settings
- All sensors need to be placed into groups
  - A parent group called 'sensors' with child groups for the different type of sensors
  - Software sensors should be placed in a child group called 'software_sensors'
- If using a stand-alone host for Suricata-update, the host should be placed in a parent group called 'suricata_update_host'.
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
        name: corelight-suricata-update
```

### Command to run the playbook

```none
ansible-playbook -i common/inventory.yml suricata-update.yml
```

The playbook will prompt for the name of the Software Sensor to be configured and if the name you provide is an individual host or a group of hosts.  Alternately, you can provide the sensor name with --extra-vars in the command line

```none
ansible-playbook -i common/inventory.yml suricata-update.yml --extra-vars '{"target":"all"}'
```

If all of the managed hosts use the same SSH password and sudo password, you can have Ansible prompt for each with the options ```--ask-pass --ask-become-pass```

If you are using the secrets file to supply SSH or sudo passwords, use --extra-vars to load the secrets file at the start of the playbook.

```none
ansible-playbook -i common/inventory.yml suricata-update.yml --extra-vars '{"target":"all"}' --extra-vars '@common/secrets.yml'
```

If the sensor host has been setup with SSH keys, you will not need to provide the 'ask-pass' or 'become password'.

## License

BSD

## Author Information

Corelight, Inc.
