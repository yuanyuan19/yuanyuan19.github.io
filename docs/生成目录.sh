#!/bin/bash

folder=$1

# 判断文件夹是否存在
if [ -d "$folder" ]; then
	cd $folder
	
   	i=0
	while((i!=-1)); do
		((i++))
		for file in ${i}_*; do	# 通配符，不是正则表达式
		    if [[ -f "$file" ]]; then
			echo "* [<b>${file:2:-3}</b>](/$folder/${file})"   # 打印文件名	[2,-3)
		    else
		    	i=-1
		    fi
		done
	done
else
    echo "文件夹不存在"
fi
