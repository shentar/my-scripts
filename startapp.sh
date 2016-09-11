#!/bin/bash

#(/opt/xunlei/portal &)

#(/usr/bin/vncserver :1 -geometry 1650x1080 -depth 24 &)

#/etc/init.d/vsftpd start 
#(/usr/sbin/vsftpd /etc/vsftpd.conf &)

(smbd &)


(cd /media/Ent/sync; /opt/sync/btsync --webui.listen 0.0.0.0:8888 &)

ifconfig wlan0 down
 
#(oraynewph start &)

#(/etc/init.d/mysql start &)

#(/etc/init.d/nginx start &)

#(/etc/init.d/php7.0-fpm start &)

#(git daemon --base-path=/media/Tech/gitcore/ --export-all --user=root --enable=upload-pack --enable=upload-archive --enable=receive-pack --informative-errors /media/Tech/gitcore &)


