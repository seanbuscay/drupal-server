Drupal Server Setup Scripts
===========================

Shell scripts to set up a Ubuntu server to test Drupal.

Options to install:

-Apache
-Apache Tomcat
-Apache Solr
-PHP
-MySQL
-Drush
-Xdebug
-XHProf
-Upload Progress
-An Email Catcher
-Jenkins
-Memcached

## Install

Note: This will install/re-install php/mysql/apache and other tools used in Drupal development.

Edit the config.ini file to choose your install options.

The target install environment is Ubuntu 12.04 LTS, desktop or server edition.

Install will likely work on Ubuntu 12.10 and other Debian-based Linux distributions.  

Run:

    cd ~
    sudo apt-get -y install git-core wget curl
    git clone git@github.com:seanbuscay/drupal-server.git drupal-server

Edit the config file at: `~/drupal-server/config.ini`

Run:

    bash ~/drupal-server/install.sh
	
If you are installing on a VirtualBox, you will be asked on question mid-way through the install.  
Choose the capitol Y option "Y".

## Background

These scripts are an upgrade to my previous projects:

https://github.com/seanbuscay/drupal-quickstart
https://github.com/seanbuscay/qs

Those projects were minor forks of the Drupal QuickStart project (http://drupal.org/project/quickstart) which I contributed to for a short time.  

This latest set of scripts has been de-coupled from the Drupal QuickStart project.

These scripts start from the Drupal Pro project, http://drupal.org/project/drupalpro, which also started as fork of the QuickStart project and used the configuration concepts from my QS project.

This code is an adaption on the work Mike Stewart http://drupal.org/user/30158 did for DrupalPro.