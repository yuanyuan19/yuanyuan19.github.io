对于学习，我喜欢**遵循一个固定、程序化的流程，有规律地养成习惯**，实现自我提升。

## 文件说明

docs:被部署的文件夹

- index.html:入口文件
- README.md:用于内容渲染
- blog:博客模块
  - 这里的每个博客模块都对应着一个专题，用tools的脚本可以快速生成
- js:存放在index.html中引入的部分js文件	
- live2d:看板娘的js和css文件
- CNAME:Gtihub pages自动添加的域名文件
- .nojekyll:阻止 GitHub Pages 忽略掉下划线开头的文件
- github-mark.svg:图标

tools:一些维护项目时方便的脚本工具

Makefile:执行命令的脚本文件

README.md:说明文件

## 日志

### 1.5

对博客的架构进行了大规模修改

新增封面，大规模修改布局

修改看板娘的js文件让看板娘默认隐藏，waifu-tips.js.back是原来的js文件

### 11.8

新增latex公式支持插件

解决中文路径编码下长度超过50导致gitalk不能使用的问题

### 10.27

更新了部分riscv的笔记，编译原理笔记写一半也放上了

新增了看板娘，评论，复制插件等

新增电子木鱼