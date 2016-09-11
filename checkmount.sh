#!/bin/bash


checkdisk ()
{
      diskinfo=$(blkid |egrep -e  "94D067DFD067C5D8|8A84A84384A8339B|F8C24655C24617F0|0e5aade2-e65b-4305-8837-596c54dd2e77"|wc -l)
      #`l /dev/sda1 && l /dev/sda5 && l /dev/sda6  && l /dev/sda7`
      if [ "${diskinfo}" -eq 4 ]
      then
          count=`df -h |egrep 'OS|Tech|Ent|Data'|grep -v "/media/shentar"|wc -l`
          if [ "$count" -eq 4 ]
          then
                return 0
          else
		sh /opt/stopapp.sh
		umount UUID=8A84A84384A8339B
		umount UUID=94D067DFD067C5D8
		umount UUID=F8C24655C24617F0
		umount UUID=0e5aade2-e65b-4305-8837-596c54dd2e77
                mount -t ntfs UUID=8A84A84384A8339B /media/Ent -o rw,noexec,nosuid,nodev,iocharset=utf8,umask=000,nls=utf8,user
                mount -t ntfs UUID=94D067DFD067C5D8 /media/Data -o rw,noexec,nosuid,nodev,iocharset=utf8,umask=000,nls=utf8,user
                mount -t ntfs UUID=F8C24655C24617F0 /media/OS -o rw,noexec,nosuid,nodev,iocharset=utf8,umask=000,nls=utf8,user
                mount -t xfs UUID=0e5aade2-e65b-4305-8837-596c54dd2e77 /media/Tech 
                return 0
          fi
      else
          return 1
      fi
      
}     

#/dev/sda1: LABEL="OS" UUID="F8C24655C24617F0" TYPE="ntfs" PARTUUID="205cd921-01"
#/dev/sda5: LABEL="Data" UUID="94D067DFD067C5D8" TYPE="ntfs" PARTUUID="205cd921-05"
#/dev/sda6: LABEL="Ent" UUID="8A84A84384A8339B" TYPE="ntfs" PARTUUID="205cd921-06"
#/dev/sda7: UUID="0e5aade2-e65b-4305-8837-596c54dd2e77" TYPE="xfs" PARTUUID="205cd921-07"


#UUID=F8C24655C24617F0    /media/OS    ntfs    defaults,user,rw,iocharset=utf8,umask=000,nls=utf8    0    0
#UUID=94D067DFD067C5D8    /media/Data    ntfs    defaults,user,rw,iocharset=utf8,umask=000,nls=utf8    0    0
#UUID=8A84A84384A8339B    /media/Ent    ntfs    defaults,user,rw,iocharset=utf8,umask=000,nls=utf8    0    0
#UUID=0e5aade2-e65b-4305-8837-596c54dd2e77   /media/Tech    xfs    defaults    0    0

checkprocesses ()
{
    ret=1
#    processes="nginx php-fpm smbd vsftpd ETMDaemon vod_httpserver EmbedThunderManager oraysl oraynewph mysql btsync git"
    processes="btsync smbd"
    for proc in ${processes}
    do
        checkoneprocess "${proc}"
        ret=$((${ret}&&$?))
    done
    
    if [ ${ret} -eq 0 ]
    then
        echo "there are some processes error!"
        sh /opt/stopapp.sh
        sh /opt/startapp.sh
        echo "restart the app completed!"
    fi  

     checkoneprocess "java -Xms128M -Xmx512M -Xdebug -Xrunjdwp:transport=dt_socket,address=4321,server=y,suspend=n -Dorg.sqlite.lib.path=./ -Dorg.sqlite.lib.name=libsqlite.so -jar start.jar"
     if [ "$?" -eq 0 ]	
     then
        sh /media/Tech/jAlbum/distribute/jalbum_for_Raspberry3.sh restart
     fi
} 

checkoneprocess ()
{
        local processname="$1"
        if [ ! -z "${processname}" ]
        then
            result=$(ps aufx |grep "${processname}"|grep -v grep)
            if [ -z "${result}" ]
            then
                return 0
            fi    
        fi
        
        return 1
}

checkInitLevel ()
{
	checkoneprocess "/usr/sbin/lightdm"
	if [ $? -eq 1 ]
	then
		(init 3 &)
	fi
}

checkdisk
if [ $? -eq 0 ]
then
    checkprocesses
else
    echo "the disk is error!"
fi

checkInitLevel
