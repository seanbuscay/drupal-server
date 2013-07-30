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

sudo apt-get ${APTGET_VERBOSE} install solr-tomcat tomcat6-admin

mkdir ~/solrconfig;
cd ~/solrconfig
wget drupalcode.org/project/search_api_solr.git/blob_plain/HEAD:/solr-conf/1.4/solrconfig.xml
wget drupalcode.org/project/search_api_solr.git/blob_plain/HEAD:/solr-conf/1.4/schema.xml
sudo cp -v *.xml /etc/solr/conf

# Fix bug for tomcat log location.
sudo rm -r /var/lib/tomcat6/logs
sudo mkdir /var/lib/tomcat6/logs

echo "
<tomcat-users>
  <role rolename='admin'/>
  <role rolename='manager'/>
  <user username='${TOMCAT_USER}' password='${TOMCAT_PASS}' roles='admin,manager'/>
</tomcat-users>" | sudo tee /etc/tomcat6/tomcat-users.xml > /dev/null

service tomcat restart
echo "$HELP"
