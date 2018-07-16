#!/bin/bash
#
# minimize (aka remove spaces) in all the test records
#
# by: Max Novelli
#     man8@pitt.edu
#     2018/06/26
#  

for file in `ls ../expanded/record?.max.json`; do 
  file2=`echo $file | sed "s/\.max//g;s/expanded/minimized/"`
  cat ${file} | jq -c . > ${file2}
done

