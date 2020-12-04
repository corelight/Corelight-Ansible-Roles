#!/bin/bash

lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS=`lowercase \`uname\``
KERNEL=`uname -r`
MACH=`uname -m`

if [ "${OS}" == "windowsnt" ]; then
  OS=windows
elif [ "${OS}" == "darwin" ]; then
  OS=mac
else
  OS=`uname`
  if [ "${OS}" = "SunOS" ] ; then
    OS=Solaris
    ARCH=`uname -p`
    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
  elif [ "${OS}" = "AIX" ] ; then
    OSSTR="${OS} `oslevel` (`oslevel -r`)"
  elif [ "${OS}" = "Linux" ] ; then
    if [ -f /etc/redhat-release ] ; then
      DistroBasedOn='RedHat'
      DIST=`cat /etc/redhat-release |sed s/\ release.*//`
      PSUEDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
      REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
      MREV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*// | sed s/\\..*//`
    elif [ -f /etc/SuSE-release ] ; then
      DistroBasedOn='SuSe'
      PSUEDONAME=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
      REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
      MREV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*// | sed s/\\..*//`
    elif [ -f /etc/mandrake-release ] ; then
      DistroBasedOn='Mandrake'
      PSUEDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
      REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
      MREV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*// | sed s/\\..*//`
    elif [ -f /etc/debian_version ] ; then
      DistroBasedOn='Debian'
      if [ -f /etc/lsb-release ] ; then
              DIST=`cat /etc/lsb-release | grep '^DISTRIB_ID' | awk -F=  '{ print $2 }'`
                    PSUEDONAME=`cat /etc/lsb-release | grep '^DISTRIB_CODENAME' | awk -F=  '{ print $2 }'`
                    REV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F=  '{ print $2 }'`
                    MREV=`cat /etc/lsb-release | grep '^DISTRIB_RELEASE' | awk -F. '{ print $1 }' | awk -F= '{ print $2 }'`
                fi
    fi
    if [ -f /etc/UnitedLinux-release ] ; then
      DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
    fi
    OS=`lowercase $OS`
    DistroBasedOn=`lowercase $DistroBasedOn`
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

echo $DIST $REV

if [ $DistroBasedOn = "redhat" ]; then
        if [ $MREV = "7" ]; then
                echo "Installing Python3-pip and other dependencies"
                sudo yum install -y epel-release libselinux-python dnf
                sudo dnf install -y -q python3-pip git
        else
                echo "Installing Python3-pip and other dependencies"
                sudo yum install -y dnf
                sudo dnf install -y -q python3-pip git
        fi
elif [ $DistroBasedOn = "debian" ]; then
        sudo apt-get update -y -q
        sudo apt-get install -y -q --install-suggests python3-pip git
        sudo apt-get install -y -q --install-suggests python3-venv
else
        echo "Not RedHat or Debian based"
        exit 1
fi


if ! [ -d /etc/corelight-env/ ] > /dev/null; then
        echo "Creating /etc/corelight-env directory"
        sudo mkdir /etc/corelight-env
        sudo chown $USER.$USER /etc/corelight-env
fi

if ! [ -d /etc/corelight-env/ ] > /dev/null; then
        echo "Creating /etc/ansible directory"
        sudo mkdir /etc/ansible
        sudo chown $USER.$USER /etc/ansible
        sudo chmod 755 /etc/ansible
fi

echo "Creating python3 virtual environment"
python3 -m venv /etc/corelight-env
source /etc/corelight-env/bin/activate
python3 -m pip install --upgrade pip wheel setuptools

echo "Installing Ansible"
python3 -m pip install --upgrade --upgrade-strategy eager ansible
ansible-galaxy collection install community.general

echo "Coping Ansible default config to /etc/ansible/ansible/cfg"
cp ./default-ansible.cfg /etc/ansible/ansible.cfg
