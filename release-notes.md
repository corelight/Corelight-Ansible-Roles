# 2.0 Changes

Table of Contents

- [2.0 Changes](#20-changes)
  - [Role Changes](#role-changes)
  - [Default Settings Changes](#default-settings-changes)
    - [Changed defaults](#changed-defaults)
    - [Removed defaults - (no longer needed)](#removed-defaults---no-longer-needed)
    - [New defaults](#new-defaults)
  - [Variable Changes](#variable-changes)
  - [File Structure Changes](#file-structure-changes)

**NOTE:** Ansible Collections cannot have '-' in the role names.  All role names have been renamed to replace '-' with '_'.  In addition to renaming, install, config, and run have been split on all roles.

## Role Changes

| Role Names:     ||
| ---------------------------------: | :-------------------------------------------------- |
|      ```corelight-software-sensor```     | > ```software_sensor_install```                           |
|                                    | > ```software_sensor_config```                            |
|                                    |                                                     |
|      ```corelight-suricata-update```     | > ```suricata_update_install```                           |
|                                    | > ```suricata_update_config```                            |
|                                    | > ```suricata_update_run```                               |
|                                    |                                                     |
|                         ```common```     | This role creates some dynamic groups and runs some dependency fact checking before a config or run playbook will execute.                     |
|                     ```venv_setup```     | This role does basic install of Python3 (and other dependencies) and creates a (/etc/corelight-env by default) virtual environment.           |
|       ```corelight_client_install```     | Installs Corelight-client in the virtual environment created with venv_setup.                                                                   |
|                ```ansible_install```     | Installs Ansible in the virtual environment created with venv_setup.                                                                           |
|                    ```zkg_install```     | Installs ZKG in the virtual environment created with venv_setup.                                                                                |
|       ```suricata_config_cron_job```     | This role is used to configure or reconfigure a Suricata-update cron job to run on the local controller or a remote Suricata-update host.  |
|                ```suricata_groups```     | This role manages Suricata address and port groups on physical sensors.                                                                          |
|                            ```zkg```     | This role manages Zeek packages on all sensors (currently only manages the zkg bundle for Fleet managed sensor).                          |
|            ```intel``` (coming soon)     | This role manages Intel Framework files for all sensors.  It can automatically merge a directory of files into a single intel file and upload it to any sensor. (currently will not remove files from sensors)                           |
|            ```input``` (coming soon)     | This role manages Input Framework files for all sensors types.  (currently will not remove files from sensors)                             |
|                                    |                                                     |
| ```corelight-suricata-update-cron-job``` | **removed**                                         |
|                                    |                                                     |

**NOTE:** Splitting the roles into different functions removes duplication throughout the roles.  It also allows a function to be configured or executed without the concern for undesired upgrades occurring.

## Default Settings Changes

**NOTE:** As a general rule, changes were made in an attempt to use application default settings where possible.  Other applications depending on those settings will be adjusted.  For example:

- Suricata-update will use Suricata-update default settings
- A Software Sensor with Suricata-update installed will look for Suricata rules in the Suricata-update default location ```/var/lib/suricata/rules```.
- A Software Sensor without Suricata-update installed will look for Suricata rules in the Software Sensor default location ```/etc/corelight/rules```.

### Changed defaults

```yaml
# The directory where corelight-suricata looks for rulesets
suricata_rule_path:
# renamed to
suricata_rule_dir:

# Path to custom Suricata rules for Suricata-update (see New defaults below)
suricata_custom_rules_path: /etc/corelight/suricata-update/custom-rules
# Path to Suricata-update config and rule files (see New defaults below)
suricata_update_path: /etc/corelight/suricata-update
```

### Removed defaults - (no longer needed)

```yaml
# settings for coping the files to a remote cron job host
secrets_path: "../../../common/secrets.yml"
inventory_path: "../../../common/inventory.yml"
main_vars_path: "../../../common/main-vars.yml"

# true or false, if set to false, address_groups or port_groups tasks will be skipped
process_suricata_port_groups: false
process_suricata_address_groups: false
```

### New defaults

```yaml
virtual_env_dir: /etc/corelight-env                 # The default Python environment created for all installations
validate_certs: yes                                 # Enable/Disable cert validation for yum and dnf installs

suricata_dir: /usr/local/etc/suricata               # The default directory for corelight-suricata config files
suricata_update_dir: /etc/suricata                  # The default directory where suricata-update looks for config files
suricata_update_output_dir: /var/lib/suricata/rules # The default directory where suricata-update puts suricata.rules
suricata_rules_dir: /var/lib/suricata/rules         # The directory where corelight-suricata looks for rulesets
suricata_custom_rules_dir: /etc/suricata/rules      # The directory where suricata-update looks for local rules
```

## Variable Changes



## File Structure Changes

- Files folders renamed
  - input_files > ```common/files/input-files```
    - default input files > ```common/files/input_files/default-input-files```
  - suricata_custom_rules > ```common/files/suricata-custom-rules```
  - zkg_bundles are still > ```common/files/zkg_bundles```

- Inventory moved to ```common/inventory/```  **Note:** All inventory files in this directory get loaded.

- Variable files are still in ```common/```   **Note:** All files ending with ```*-vars.yml``` get loaded.

- All playbooks should be executed from the base directory.  The playbooks in ```plybooks-additional/``` need to be copied up one directory to be used.

- The example scripts in the ```scripts/``` folder contain the full command line to execute a given playbook without moving it.
- The ```scripts/``` folder also contains a script to initially configure ansible on any linux OS ```initial_ansible_installation_venv.sh``` and a script with the command to activate the python virtual environment if needed ```activate_venv.sh```.  The activate script is only needed to manually interact with a configured host.  The roles already account for it.
