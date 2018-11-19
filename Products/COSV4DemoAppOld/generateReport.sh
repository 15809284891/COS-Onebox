#!/bin/bash

# 入参 path 要查找的路径, pattern 模式
SEARCH_FIELS=()
searchFiles() {
path=$1
pattern=$2
files=`find ${path} -name "${pattern}" -maxdepth 100`
files=`echo ${files[@]} | tr ' ' '\n' | sort -r`
SEARCH_FIELS=${files[@]}
}

searchFiles . "xcodebuild*.log"
files=$SEARCH_FIELS
if [ ${#files[@]}==0 ]; then
echo "没有发现任何可以测试的版本"
else
for file in ${files[@]}
 do
    while read line
    do
        echo $line|xcpretty --report junit     #这里可根据实际用途变化
        echo $line
    done < $file      #filename 为需要读取的文件名
 done
fi
