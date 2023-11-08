---
title: npm全局和局部
excerpt: 胡乱试试看
index_img: /img/index_img/1.jpg
categories:
  - 小实验
  - nodejs
tags:
  - npm
category_bar: true
date: 2023-06-013 15:32:27
hide: true
---

#### 玩一玩`npm`

首先执行`npm init`生成`packages.json`文件

![image-20230506175952037](assets/npm全局和局部/image-20230506175952037.png)

`npm install hexo  ` ：局部安装 添加依赖

![image-20230506180246891](assets/npm全局和局部/image-20230506180246891.png)

`npm remove hexo` ：截图是顺着代码执行下来的，能看出`remove`会自动删除相应的依赖

![image-20230506180355958](assets/npm全局和局部/image-20230506180355958.png)

全局安装和全局删除，`dependencies`没有变，`node_modules`也没有变

![image-20230506180737805](assets/npm全局和局部/image-20230506180737805.png)

```
npm install hexo
npm install qs
npm install react
```

然后删除`node_modules`，执行`npm install`，可见`dependencies`的包都被装上了

![image-20230506181230202](assets/npm全局和局部/image-20230506181230202.png)

```
npm remove hexo qs react
```

执行完又是光秃秃的了

![image-20230613160146793](assets/npm全局和局部/image-20230613160146793.png)
