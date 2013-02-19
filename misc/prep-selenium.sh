#!/bin/bash
set -e
source "${DPATH}"/config.ini

sudo aptitude install xvfb          # virtual display
sudo aptitude install x11-apps      # installs xclock (to test things are working), and xwd (for taking screenshots)
sudo aptitude install imagemagick   # for converting screenshots
sudo aptitude install firefox
