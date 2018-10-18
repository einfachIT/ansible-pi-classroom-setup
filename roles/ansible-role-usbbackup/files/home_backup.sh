#!/bin/bash

datetime=`date "+%Y_%m_%d_%H"`;
hostname=`hostname`;
tar czvf ${2}/${hostname}_${datetime}.tar.gz --exclude-from=${1}/.excludelist ${1};
exit 0;
