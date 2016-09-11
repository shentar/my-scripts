#!/bin/bash

killoneprocess ()
{
        local processname="$1"
        if [ ! -z ${processname} ]
        then
            result=$(ps aufx |grep "${processname}"|grep -v grep |awk '{print $2}')
            if [ ! -z "${result}" ]
            then
                echo "$result" |xargs kill -9
            fi    
        fi
}

killoneprocess nginx
killoneprocess php-fpm
#killoneprocess smbd
killoneprocess vsftpd
killoneprocess ETMDaemon  
killoneprocess vod_httpserver    
killoneprocess EmbedThunderManager 
killoneprocess oraysl 
killoneprocess oraynewph    
killoneprocess mysql
killoneprocess btsync
killoneprocess git

