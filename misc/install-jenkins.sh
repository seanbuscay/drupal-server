#!/bin/bash
set -e
source "${DPATH}"/config.ini
# ################################################################################ Jenkins

# README:
#
# This script will install Jenkins on port 8081
#
HELP="

Jenkins Installation complete.

Jenkins is a continious integration server.  Jenkins is running on port 8081.

To restart Jenkins:  sudo /etc/init.d/jenkins restart

To admin Jenkins: http://localhost:8081/
- You will need to restart Ubuntu before accessing this URL for the first time.

For details on using Jenkins with Drupal, see here: http://groups.drupal.org/node/96289
"

cd ~

# Get the package signer key

wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install package

sudo apt-get ${APTGET_VERBOSE} --fix-missing update
sudo apt-get ${APTGET_VERBOSE} install jenkins

# Fix any dependencies
sudo apt-get -y install -f

# Configure
sudo /etc/init.d/jenkins stop
sudo sed -i 's/JENKINS_USER=jenkins/JENKINS_USER='"${USER}"'/g'           /etc/default/jenkins
sudo sed -i 's/HTTP_PORT=8080/HTTP_PORT=8081/g'                       /etc/default/jenkins
mkdir "${JENKINS_HOME}"
sudo chown -R $USER:www-data "${JENKINS_HOME}"
sudo sed -i 's/JENKINS_HOME=\/var\/lib\/jenkins/JENKINS_HOME=\/home\/'${USER}'\/jenkins/g'       /etc/default/jenkins
sudo sed -i 's/--webroot=\/var\/cache\/jenkins\/war/ /g'       /etc/default/jenkins

sudo /etc/init.d/jenkins start

echo "$HELP"
