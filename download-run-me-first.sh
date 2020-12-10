#!/bin/bash
# to download and run this script in one command, execute the following:
# source <( curl https://raw.githubusercontent.com/corelight/Corelight-Ansible-Roles/2.0beta/download-run-me-first.sh)

sudo mkdir /etc/corelight-env
cd /etc/corelight-env
sudo chown $USER.$USER /etc/corelight-env
cd /etc/corelight-env
git clone https://github.com/corelight/Corelight-Ansible-Roles.git
cd Corelight-Ansible-Roles/
git checkout 2.0beta
cd scripts-initial-setup/
./initial_ansible_installation_venv.sh


echo -e "\033[1;32m";
clear
echo "                               ";
echo "    ((((                       ";
echo "  ((                           ";
echo " ((       |                    ";
echo " ((       |    ))              ";
echo " ((            ))              ";
echo "  (((        )))               ";
echo "     (((())))                  ";
echo "";
echo " Step 1 Complete";
echo "";
read -p "Press any key to continue ..."
clear
echo "                               ";
echo "    ((((                       ";
echo "  ((     _                     ";
echo " ((      _|                    ";
echo " ((     |_     ))              ";
echo " ((            ))              ";
echo "  (((        )))               ";
echo "     (((())))                  ";
echo "";
echo " Step 2 is manual";
echo -e "\033[0;33m";
echo "";
echo -e "\033[0;33m The following steps must be completed:";
echo -e "\033[0m [ ] copy or create a secrets.yml file";
echo -e "\033[0m [ ] copy or create one or more variable files";
echo -e "\033[0;33m      - variable files (including secrets files will automatically be loaded from";
echo -e "\033[0;32m        /etc/corelight-env/Corelight-Ansible-Roles/common/";
echo -e "\033[0m [ ] copy or create one or more yaml inventory files";
echo -e "\033[0;33m      - inventory files will automatically be loaded from";
echo -e "\033[0;32m        /etc/corelight-env/Corelight-Ansible-Roles/common/inventory/";
echo -e "\033[0m [ ] If you are using ansible-vault to encrypt your secrets file, copy or create a vault password file.";
echo -e "\033[0;33m      - Edit /etc/ansible/ansible.cfg and edit the following line:";
echo -e "\033[0;32m      #  vault_password_file = /path/to/vault_password_file";
echo "";
echo "";
echo -e "\033[0;33m The following steps are optional:";
echo -e "\033[0m [ ] generate ssh keys with the following command: 'ssh-keygen'";
echo -e "\033[0m [ ] copy the ssh public key to all the remote hosts in the inventory with the following commands:";
echo "";
echo -e "\033[1;32m     source /etc/corelight-env/bin/activate";
echo -e "\033[1;32m     cd /etc/corelight-env/Corelight-Ansible-Roles/scripts-initial-setup/";
echo -e "\033[1;32m     ansible-playbook -i ../common/inventory/ ./ssh-copy-id-to-all.yml  --extra-vars '@../common/secrets.yml'";
echo -e "\033[0;33m";
read -p "Press any key for more options ..."
clear
echo "                               ";
echo "    ((((                       ";
echo "  ((     _                     ";
echo " ((      _|                    ";
echo " ((      _|    ))              ";
echo " ((            ))              ";
echo "  (((        )))               ";
echo "     (((())))                  ";
echo "";

echo -e "\033[1;32m Step 3";
echo -e "\033[1;32m Install, Configure or Run something";
echo "";
echo -e "\033[0;33m    NOTE: Make sure you activate the python environment first:";
echo -e "\033[1;32m      source /etc/corelight-env/bin/activate";
echo "";
echo -e "\033[0;33m    From the /etc/corelight-env/Corelight-Ansible-Roles/scripts directory";
echo "";
echo -e "\033[0m [ ]  Install and configure Suricata-update on the main host with:";
echo -e "\033[1;32m        ./example-ansible-install-config-all-host.sh";
echo -e "\033[0m         or";
echo -e "\033[1;32m        ansible-playbook -i ../common/inventory/ ../install-config-all-main-host.yml  --extra-vars '@../common/secrets.yml'";
echo "";
echo -e "\033[0m [ ]  Reconfigure Suricata-update on the main host with:";
echo -e "\033[1;32m        ./example-ansible-suricata-update-reconfig-host.sh";
echo -e "\033[0m         or";
echo -e "\033[1;32m        ansible-playbook -i ../common/inventory/ ../install-config-all-main-host.yml  --extra-vars '@../common/secrets.yml'";
echo "";
echo -e "\033[0m [ ]  Run Suricata-update on the main host with:";
echo -e "\033[1;32m        ./example-ansible-suricata-update-run-host.sh";
echo -e "\033[0m         or";
echo -e "\033[1;32m        ansible-playbook -i ../common/inventory/ ../suricata-update-run-host.yml  --extra-vars '@../common/secrets.yml'";
echo "";
echo -e "\033[0m [ ]  Install and configure ALL Software Sensors in inventory with:";
echo -e "\033[1;32m        ./example-ansible-sw-sensor-install-all.sh";
echo -e "\033[0m         or";
echo -e "\033[1;32m        ansible-playbook -i ../common/inventory/ ../install-config-all-software-sensor.yml  --extra-vars '@../common/secrets.yml'";
echo "";
echo -e "\033[0m";



# Note: If you need a password for sudo, add 'ansible_become_pass: '{{centos7_sudo}}' to the inventory file.
# In this example,  add a variable called 'centos7_sudo' to your secrets.yml with the real password.
# If you need if for localhost, make sure you also add it to the 'default-localhost.yml' inventory file or create an entry for localhost in your inventory file.
