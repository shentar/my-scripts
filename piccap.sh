#!/bin/bash

mkdir /root/pics >/dev/null 2>&1
mkdir /var/piccap >/dev/null 2>&1
touch /var/piccap/lastbtime
sleeptime=60
busyinterval=3
normalinterval=30
sleepcount=0

capPic ()
{
    timestr=$(date +%Y%m%d%H%M%S)
        raspistill -t 5000 -o /root/pics/image_${timestr}.jpg -q 100 -n -rot 180 
}

checkAndUpload ()
{
        lastbtime=$(cat /var/piccap/lastbtime)
        nowtime=$(date +%Y%m%d)
        if [ -z "${lastbtime}" -o "${lastbtime}" != "${nowtime}" ]
        then
                umount /mnt/homenas
                mount -t cifs -o username=User,password=Password //22.22.22.3/share /mnt/homenas/
                if [ $? -eq 0 ] 
                then
                        for i in $(ls /root/pics/image_*.jpg)
                        do  
                                mv $i /mnt/homenas/piccap
                        done
                        umount /mnt/homenas
                        echo ${nowtime} > /var/piccap/lastbtime
                fi    
        fi    
}


while :
do
    checkAndUpload
	
    hour=$(date +%H)
    min=$(date +%M)    
    
    if [ ${hour} -eq 5 -a ${min} -gt 30 ] || [ ${hour} -ge 17 -a ${hour} -le 19 -o ${hour} -ge 6 -a ${hour} -le 8 ] 
    then
        # 上午5点半～9点，晚上5点至8点，每隔3分钟拍摄一张。
        [ ${sleepcount} -eq 0 ] && capPic
        [ ${sleepcount} -eq ${busyinterval} ] && capPic && sleepcount=0
    elif [ ${hour} -ge 0 -a ${hour} -le 4 ]
    then
        # 凌晨0点到4点不抓取照片。
        sleepcount=0
    else
        # 其他时间段每隔30分钟抓取一张。
        [ ${sleepcount} -eq 0 ] && capPic
        [ ${sleepcount} -eq ${normalinterval} ] && capPic && sleepcount=0
    fi
    
    sleepcount=$(expr ${sleepcount} + 1)
    sleep ${sleeptime}
done



