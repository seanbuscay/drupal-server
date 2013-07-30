#!/bin/bash
set -e
source "${DPATH}"/config.ini
#======================================| Apache SOLR - 183mb

# README:
#
# This script will install apache tomcat (a java app web server) and apache solr (a java search server)
#
HELP="

Solr Installation complete.

Apache Solr is a java web application.
It is running inside the Apache Tomcat java webapp server on port 8080.

To restart tomcat (and solr):  sudo /etc/init.d/tomcat6 restart

To admin tomcat: http://localhost:8080/manager/html
To admin solr:  http://localhost:8080/solr/admin/

Tomcat has been configured with a user 'admin' with password 'admin'

For details on using solr with Drupal, see here: http://drupal.org/project/apachesolr
"

cd ~
sudo apt-get ${APTGET_VERBOSE} update
sudo apt-get ${APTGET_VERBOSE} install openjdk-6-jre icedtea6-plugin

sudo apt-get ${APTGET_VERBOSE} install tomcat6

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  FIX TOMCAT BUGS                             **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}

# Fix bug for tomcat log location.
sudo rm -r /var/lib/tomcat6/logs
sudo mkdir /var/lib/tomcat6/logs

# Fix missing enviroment variables
echo "
CATALINA_HOME=/usr/share/tomcat6
CATALINA_BASE=/var/lib/tomcat6
" | sudo tee -a /etc/environment > /dev/null

source /etc/environment

# Fix lib symlink

cd /var/lib/tomcat6
sudo ln -s /usr/share/java lib

sudo apt-get ${APTGET_VERBOSE} install solr-common solr-tomcat
sudo apt-get ${APTGET_VERBOSE} install tomcat6-admin tomcat6-common tomcat6-user tomcat6-docs tomcat6-examples

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  SOLR TOMCAT INSTALL COMPLETE                **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}

#echo "**************************************************" | tee -a ${DLOGFILE}
#echo "**  CONFIGURE search_api_solr                   **" | tee -a ${DLOGFILE}
#echo "**************************************************" | tee -a ${DLOGFILE}

#mkdir ~/solrconfig;
#cd ~/solrconfig
#wget drupalcode.org/project/search_api_solr.git/blob_plain/HEAD:/solr-conf/1.4/solrconfig.xml
#wget drupalcode.org/project/search_api_solr.git/blob_plain/HEAD:/solr-conf/1.4/schema.xml
#sudo cp -v *.xml /etc/solr/conf


echo "
<tomcat-users>
  <role rolename='admin'/>
  <role rolename='manager'/>
  <user username='${TOMCAT_USER}' password='${TOMCAT_PASS}' roles='admin,manager'/>
</tomcat-users>" | sudo tee /etc/tomcat6/tomcat-users.xml > /dev/null

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  RESTART TOMCAT                              **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}

sudo /etc/init.d/tomcat6 restart
echo "$HELP"
