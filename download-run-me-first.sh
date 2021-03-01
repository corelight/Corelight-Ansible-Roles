#!/bin/bash
# to download and run this script in one command, execute the following:
# source <( curl https://raw.githubusercontent.com/corelight/Corelight-Ansible-Roles/devel/download-run-me-first.sh)

export LANG=en_US.UTF-8

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS="$(lowercase "$(uname)")"
KERNEL="$(uname -r)"
MACH="$(uname -m)"

if [ "${OS}" == "windowsnt" ]; then
  OS=windows
elif [ "${OS}" == "darwin" ]; then
  OS=mac
else
  OS=$(uname)
  if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=$(uname -p)
    OSSTR="${OS} ${REV}(${ARCH} $(uname -v))"
  elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} $(oslevel) ($(oslevel -r))"
  elif [ "${OS}" = "Linux" ] ; then
    if [ -f /etc/redhat-release ] ; then
      DistroBasedOn='RedHat'
      DIST=$(sed s/\ release.*//  /etc/redhat-release)
      PSUEDONAME=$(sed s/.*\(// /etc/redhat-release | sed s/\)//)
      REV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*//)
      MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
    elif [ -f /etc/SuSE-release ] ; then
      DistroBasedOn='SuSe'
      PSUEDONAME=$(tr "\n" ' ' /etc/SuSE-release | sed s/VERSION.*//)
      REV=$(tr "\n" ' ' /etc/SuSE-release | sed s/.*=\ //)
      MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
    elif [ -f /etc/mandrake-release ] ; then
      DistroBasedOn='Mandrake'
      PSUEDONAME=$(sed s/.*\(// /etc/mandrake-release | sed s/\)//)
      REV=$( sed s/.*release\ // /etc/mandrake-release |sed s/\ .*//)
      MREV=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*// | sed s/\\..*//)
    elif [ -f /etc/debian_version ] ; then
      DistroBasedOn='Debian'
      if [ -f /etc/lsb-release ] ; then
              DIST=$(grep '^DISTRIB_ID' /etc/lsb-release | awk -F=  '{ print $2 }')
                    PSUEDONAME=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }')
                    REV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }')
                    MREV=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F. '{ print $1 }' | awk -F= '{ print $2 }')
                fi
    fi
    if [ -f /etc/UnitedLinux-release ] ; then
      DIST="${DIST}[$(tr "\n" ' ' /etc/UnitedLinux-release | sed s/VERSION.*//)]"
    fi
    OS=$(lowercase $OS)
    DistroBasedOn=$(lowercase $DistroBasedOn)
    readonly OS
    readonly DIST
    readonly DistroBasedOn
    readonly PSUEDONAME
    readonly REV
    readonly MREV
    readonly KERNEL
    readonly MACH
  fi

fi

echo -e "\033[0;33m";
echo "$DIST" "$REV"
echo "  "
echo "The script you are about to run will do the following:"
echo ""
echo "  Install or upgrade the following packages depending on the OS"
echo "  [ ] Python3-pip"
echo "  [ ] Python3-venv"
echo "  [ ] epel-release, libselinux-python dnf (RHEL7/CentOS7)"
echo "  [ ] Python3-pip, git"
echo "  [ ] libselinux-python3 (RHEL7/CentOS7)"
echo "  [ ] Upgrade pip3 to version 20.x or later"
echo "  [ ] create a Python3 virtual environment at /etc/corelight-env/"
echo "  [ ] Install Ansible in the /etc/corelight-env/ virtual environment"
echo "  "
read -p "Press any key to continue or CTRL-C to cancel ..."
echo -e "\033[0m"
echo ""


if [ "$DistroBasedOn" = "redhat" ]; then
        if [ "$MREV" = "7" ]; then
                echo "Installing epel-release libselinux-python and dnf"
                sudo yum install -y epel-release libselinux-python dnf
                echo "Installing Python3-pip and git"
                sudo dnf install -y -q python3-pip git
                echo "Installing libselinux-python3"
                sudo dnf install -y -q libselinux-python3
        else
                echo "Installing dnf"
                sudo yum install -y dnf
                echo "Installing Python3-pip and git"
                sudo dnf install -y -q python3-pip git
        fi
elif [ "$DistroBasedOn" = "debian" ]; then
        sudo apt-get update -y -q
        echo "Installing Python3-pip and git"
        sudo apt-get install -y -q --install-suggests python3-pip git
        echo "Installing Python3-venv"
        sudo apt-get install -y -q --install-suggests python3-venv
else
        echo "Not RedHat or Debian based"
        exit 1
fi

if ! [ -d /etc/corelight-env/ ] > /dev/null; then
        echo "Creating /etc/corelight-env directory"
        sudo mkdir /etc/corelight-env
        sudo chown "$USER"."$USER" /etc/corelight-env
fi

if ! [ -d /etc/ansible/ ] > /dev/null; then
        echo "Creating /etc/ansible directory"
        sudo mkdir /etc/ansible
        sudo chown "$USER"."$USER" /etc/ansible
        sudo chmod 755 /etc/ansible
fi


echo "Creating python3 virtual environment"
python3 -m venv /etc/corelight-env
source /etc/corelight-env/bin/activate
python3 -m pip install --upgrade pip wheel setuptools

echo "Installing Ansible"
python3 -m pip install --upgrade --upgrade-strategy eager ansible
ansible-galaxy collection install community.general -c

echo "Cloning Corelight-Ansible-Roles 2.0beta Branch"
cd /etc/corelight-env
git clone https://github.com/corelight/Corelight-Ansible-Roles.git
cd Corelight-Ansible-Roles/
git checkout devel

echo "Coping Ansible default config to /etc/ansible/ansible/cfg"
cp /etc/corelight-env/Corelight-Ansible-Roles/roles/ansible_install/files/default-ansible.cfg /etc/ansible/ansible.cfg


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
echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
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
