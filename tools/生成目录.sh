#!/bin/bash

folder=$1				#要生成目录的文件夹
folder_path=$2			#在url中需要的文件路径

# 判断文件夹是否存在
if [ -d "$folder" ]; then
	cd $folder
	
   	i=0
	while((i!=-1)); do
		((i++))
		for file in ${i}_*; do	# 通配符，不是正则表达式
		    if [[ -f "$file" ]]; then
				echo "* [<b>${file:2:-3}</b>]($folder_path${file})"   # 打印文件名	[2,-3)
		    else
		    	i=-1
		    fi
		done
	done
else
    echo "文件夹不存在"
fi


# 文件夹下文档格式:1_xxx.md,2_xxx.md...

# ./生成目录.sh ../docs/blog/study/riscv编程与实践/ blog/study/riscv编程与实践/

# result:
# * [<b>实验环境搭建</b>](/blog/study/riscv编程与实践/1_实验环境搭建.md)
# * [<b>构建工具</b>](/blog/study/riscv编程与实践/2_构建工具.md)
# * [<b>调试工具</b>](/blog/study/riscv编程与实践/3_调试工具.md)
# * [<b>riscv汇编</b>](/blog/study/riscv编程与实践/4_riscv汇编.md)
# * [<b>RVOS代码解析</b>](/blog/study/riscv编程与实践/5_RVOS代码解析.md)
# * [<b>参考资料</b>](/blog/study/riscv编程与实践/6_参考资料.md)
# * [<b>零碎的知识</b>](/blog/study/riscv编程与实践/7_零碎的知识.md)	
