#!/bin/bash
#
# Copyright (c) 2019 Mondoo, Inc.
# License: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# The Mondoo agent installation script installs the mondoo agent on supported
# Linux distros using its native package manager

# define colors
end="\033[0m"
red="\033[0;31m"
redb="\033[1;31m"
blue="\033[0;34m"
blueb="\033[1;34m"
lightblue="\033[0;36m"
lightblueb="\033[1;36m"
green="\033[0;32m"
greenb="\033[1;32m"
purple="\033[0;35m"
purpleb="\033[1;35m"

function red { echo -e "${red}${1}${end}"; }
function red_bold { echo -e "${redb}${1}${end}"; }
function green { echo -e "${green}${1}${end}"; }
function green_bold { echo -e "${greenb}${1}${end}"; }
function lightblue {  echo -e "${lightblue}${1}${end}"; }
function lightblue_bold { echo -e "${lightblueb}${1}${end}"; }
function purple { echo -e "${purple}${1}${end}"; }
function purple_bold { echo -e "${purpleb}${1}${end}"; }

function on_error() {
  red "It looks like you hit an issue when trying to install Mondoo. The 
Mondoo Community is available at: https://spectrum.chat/mondoo"
  exit 1;
}

# register a trap for error signals
trap on_error ERR

purple_bold "Mondoo Install Script"
purple "
  __  __                 _             
 |  \/  |               | |            
 | \  / | ___  _ __   __| | ___   ___  
 | |\/| |/ _ \| \'_ \ / _\` |/ _ \ / _ \ 
 | |  | | (_) | | | | (_| | (_) | (_) |
 |_|  |_|\___/|_| |_|\__,_|\___/ \___/ 
"
                 
echo -e "\nWelcome to the Mondoo Install Script. It tries to auto-detect your 
operating system and determines the appropriate package manager. If you are 
experiencing any issues, please do not hesitate to reach out: 

  * Mondoo Community https://spectrum.chat/mondoo

This script source is available at: https://github.com/mondoolabs/mondoo
"

# detection of operating system distribution
# Trywe try lsb_release, then /etc/issue then uname command
KNOWN_DISTRIBUTION="(RedHat|CentOS|Debian|Ubuntu|openSUSE|Amazon|SUSE)"
DISTRIBUTION=$(lsb_release -d 2>/dev/null | grep -Eo $KNOWN_DISTRIBUTION  || grep -Eo $KNOWN_DISTRIBUTION /etc/issue 2>/dev/null || grep -Eo $KNOWN_DISTRIBUTION /etc/Eos-release 2>/dev/null || grep -m1 -Eo $KNOWN_DISTRIBUTION /etc/os-release 2>/dev/null || uname -s)

if [ $DISTRIBUTION = "Darwin" ]; then
  OS="macOS"
elif [ -f /etc/debian_version -o "$DISTRIBUTION" == "Debian" -o "$DISTRIBUTION" == "Ubuntu" ]; then
  OS="Debian"
elif [ -f /etc/redhat-release -o "$DISTRIBUTION" == "RedHat" -o "$DISTRIBUTION" == "CentOS" -o "$DISTRIBUTION" == "Amazon" ]; then
  OS="RedHat"
# Some newer distros like Amazon may not have a redhat-release file
elif [ -f /etc/system-release -o "$DISTRIBUTION" == "Amazon" ]; then
  OS="RedHat"
# openSUSE and SUSE use /etc/SuSE-release
elif [ -f /etc/SuSE-release -o "$DISTRIBUTION" == "SUSE" -o "$DISTRIBUTION" == "openSUSE" ]; then
  OS="Suse"
fi

# determine if we need sudo
if [ $(echo "$UID") = "0" ]; then
  sudo_cmd=''
else
  sudo_cmd='sudo'
fi

# Install the necessary package sources
if [ $OS = "RedHat" ]; then
  purple_bold "\n* Installing YUM sources for Mondoo"
  curl --silent --location https://releases.mondoo.io/rpm/mondoo.repo | $sudo_cmd tee /etc/yum.repos.d/mondoo.repo

  purple_bold "\n* Installing the Mondoo agent package"
  $sudo_cmd yum install -y mondoo
elif [ $OS = "Debian" ]; then
  purple_bold "\n* Installing apt-transport-https"
  $sudo_cmd apt-get install -y apt-transport-https ca-certificates gnupg

  purple_bold "\n* Installing APT package sources for Mondoo"
  curl -sS https://releases.mondoo.io/debian/pubkey.gpg | $sudo_cmd apt-key add - 
  echo "deb https://releases.mondoo.io/debian/ stable main" | $sudo_cmd tee /etc/apt/sources.list.d/mondoo.list

  purple_bold "\n* Installing the Mondoo agent package"
  $sudo_cmd apt-get update -y && $sudo_cmd apt-get install -y mondoo
elif [ $OS = "Suse" ]; then
  purple_bold "\n* Installing ZYPPER sources for Mondoo"
  curl --silent --location https://releases.mondoo.io/rpm/mondoo.repo | $sudo_cmd tee /etc/zypp/repos.d/mondoo.repo

  purple_bold "\n* Installing the Mondoo agent package"
  $sudo_cmd zypper -n --gpg-auto-import-keys install mondoo
elif [ $OS = "macOS" ]; then
  red "macOS is not supported yet. Please reach out at Mondoo Community:

  * https://spectrum.chat/mondoo
"
  exit 1;
els
  red "Your operating system is not supported yet. Please reach out at 
Mondoo Community:

  * https://spectrum.chat/mondoo
"
  exit 1;
fi

# Display final message
purple "
Mondoo installation was successful. To activate the service run:
systemctl enable mondoo.timer
systemctl start mondoo.timer
systemctl daemon-reload.

If you have any questions, please reach out at Mondoo Community:

  * https://spectrum.chat/mondoo
"

purple_bold "Thank you for installing Mondoo!"