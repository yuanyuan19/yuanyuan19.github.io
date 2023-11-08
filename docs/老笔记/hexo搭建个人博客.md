---
title: hexo搭建个人博客
excerpt: 建议hexo+fluid
index_img: /img/index_img/1.jpg
categories:
  - 框架
  - 博客框架
tags:
  - hexo
category_bar: true
date: 2023-06-013 15:32:27
---

# Github + hexo搭建个人博客

### 参考文档

搭建自己的个人博客 [Github + hexo 实现自己的个人博客、配置主题（超详细） - 掘金 (juejin.cn)](https://juejin.cn/post/7064515729298554887)

官方文档 [在 GitHub Pages 上部署 Hexo | Hexo](https://hexo.io/zh-cn/docs/github-pages)

主要看fluid文档(https://hexo.fluid-dev.com/docs/guide/#latex-数学公式)

[Markdown 内嵌 HTML 标签 | Markdown 官方教程](https://markdown.com.cn/basic-syntax/htmls.html)

要先安装`git`，`nodejs`和`Hexo`

### 新建项目

```bash
$ hexo init <folder>
$ cd <folder>
$ npm install  #读取package.json并安装
```

#### 文件目录

```bash
.
├── _config.yml #网站的配置信息
├── package.json #应用程序的信息
├── scaffolds #模版文件夹，建文章时，Hexo 会根据 scaffold 来建立文件
├── source #用户资源
|   ├── _drafts
|   └── _posts
└── themes #主题文件夹
```

### 新建文章

```bash
hexo new "Write blog using markdown"
# 或简写为
hexo n "Write blog using markdown"
```

该命令会在 _post 目录下生成文件 write-blog-using-markdown.md。可以在文件开头设置标题，时间、标签，分类等，如下：

```yaml
title: 用 Markdown 写博客
date: 2018-08-13 09:22:18
tags:
    - markdown
    - blog
categories:
    - tutorial
    - markdown
```

接着这部分就是文章的正文，遵循 Markdown 格式。

### 生成静态页面

```bash
hexo generate
# 或简写为
hexo g
```

### 启动网站

```bash
hexo server
# 或简写为
hexo s
```

打开浏览器，在地址栏中输入 http://localhost:4000 就可以看到自己的博客了。本地网站只是方便开发时预览效果，其他人无法通过互联网访问。

*如果无法显示，可能是 4000 端口被占用了，可以使用如下命令指定端口*

```bash
hexo s -p 4444
```

*或者修改 node_modules/hexo-server/index.js 文件，修改默认端口*

```js
hexo.config.server = assign({
  port: 4444,
  log: false,
  ip: '0.0.0.0',
  compress: false,
  header: true
}, hexo.config.server);
```

### 插入图片

在 _config.yml 开启资源文件夹

```text
post_asset_folder: true
```

这样，在 _posts 目录下会生成一个与文章同名的文件夹。把需要插入到文章中的图片放到该文件夹中，并在写文章时通过如下标签引用即可。

```text
{% asset_img <图片名> [图片标题] %}
```

### 部署到 Github

安装 hexo-deployer-git

```bash
npm install hexo-deployer-git --save
```

修改 _config.yml 配置

```text
deploy:
  - type: git
    repo: https://github.com/yuanyuan19/yuanyuan19.github.io.git
    branch: gh-pages
```

部署

```
hexo clean
hexo deploy
```

### 使用 fluid 主题

```bash
git clone https://github.com/iissnan/hexo-theme-next themes/next
```

主题将会被下载到 theme/next 目录下。

在站点配置文件 _config.yml 更换主题：

```yaml
#theme: landscape    # 注释掉这一行，换成下面
theme: fluid
```

