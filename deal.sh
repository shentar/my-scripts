#!/bin/bash

inputdir="/media/"
outputdir="/media/Ent/yaoyao"
suffix="mp4"


find "${inputdir}" "*.mp4" > result.txt

while read line 
do


datestr=$(ffprobe -v quiet -print_format json -show_format -show_streams "${line}"|grep "creation_time"|grep -o "[^ ]\+\( \+[^ ]\+\)*"|uniq|awk -F ': ' '{print $2}'|awk -F '"' '{print $2}'|awk -F ' ' '{print $1}')
if [ ! -z "${datestr}" ]
then
    read y m d < <(echo "${datestr}"|awk -F '-' '{print($1,$2,$3)}')	 
    vdir="${outputdir}/${y}/${m}/${d}"
    if [ ! -d "${vdir}" ]
    then
	mkdir -p "${vdir}"
    fi	
    
    linkname=$(date +%s%N)    
    ln -s "${line}"  "${vdir}/${linkname}.${suffix}"
    echo "${vdir}/${linkname}.${suffix}"
fi

done < result.txt

