#!

sudo mkdir /etc/corelight-env
cd /etc/corelight-env
sudo chown $USER.$USER /etc/corelight-env
cd /etc/corelight-env
git clone https://github.com/corelight/Corelight-Ansible-Roles.git
cd Corelight-Ansible-Roles/
git checkout 2.0beta
cd scripts-initial-setup/
./initial_ansible_installation_venv.sh

# copy or create the following files and put them in '/etc/corelight/Corelight-Ansible-Roles/common/'
# secrets.yml
# variable files ( .yml)  You can have multiple

# copy or create the following files and put them in '/etc/corelight/Corelight-Ansible-Roles/common/inventory/'
# inventory files ( .yml)  You can have multiple

# copy or create vault password file
# edit /etc/ansible/ansible.cfg and uncomment the following line and point to your vault password file.
#vault_password_file = /path/to/vault_password_file

# Note: If you need a password for sudo, add 'ansible_become_pass: '{{centos7_sudo}}' to the inventory file.
# In this example,  add a variable called 'centos7_sudo' to your secrets.yml with the real password.
# If you need if for localhost, make sure you also add it to the 'default-localhost.yml' inventory file or create an entry for localhost in your inventory file.

# Note: Run the next commands after Ansible has been configured as noted above.
# source /etc/corelight-env/bin/activate
# cd /etc/corelight-env/Corelight-Ansible-Roles/scripts-initial-setup/
# ssh-keygen
# ansible-playbook -i ../common/inventory/ ./ssh-copy-id-to-all.yml  --extra-vars '@../common/secrets.yml'
# cd /etc/corelight-env/Corelight-Ansible-Roles/scripts/
# ansible-playbook -i ../common/inventory/ ../install-config-all-main-host.yml  --extra-vars '@../common/secrets.yml'
