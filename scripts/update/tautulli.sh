#!/bin/bash

if [[ ! -f /install/.plexpy.lock ]]; then
  # only update if plexpy is installed, otherwise use the app built-in updater
  exit 0
fi

# backup plexpy config and remove it
systemctl stop plexpy
cp -a /opt/plexpy/config.ini /tmp/config.ini.tautulli_bak &>/dev/null
cp -a /opt/plexpy/plexpy.db /tmp/tautulli.db.tautulli_bak &>/dev/null
cp -a /opt/plexpy/tautulli.db /tmp/tautulli.db.tautulli_bak &>/dev/null

systemctl stop plexpy
systemctl disable plexpy
rm -rf /opt/plexpy
rm /install/.plexpy.lock
rm -f /etc/nginx/apps/plexpy.conf
service nginx reload
rm /etc/systemd/system/plexpy.service


# install tautulli instead
source /usr/local/bin/swizzin/install/tautulli.sh &>/dev/null
systemctl stop tautulli

# restore backups
mv  /tmp/config.ini.tautulli_bak /opt/tautulli/config.ini &>/dev/null
mv  /tmp/tautulli.db.tautulli_bak /opt/tautulli/tautulli.db &>/dev/null

sed -i  's#/opt/plexpy#/opt/tautulli#g' /opt/tautulli/config.ini
sed -i "s/http_root.*/http_root = \"tautulli\"/g" /opt/tautulli/config.ini
chown -R tautulli:nogroup /opt/tautulli
systemctl start tautulli
