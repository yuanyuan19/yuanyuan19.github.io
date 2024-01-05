---
title: git学习笔记 
excerpt: git有点类似于galgame里的存档功能，它会记录你对代码的修改，从而实现代码的管理。整理了一些常用的git命令，包括创建本地仓库和提交代码，版本管理和分支管理，推送本地代码到远程仓库等
index_img: /assets/2_git/index_img.jpg
categories:
  - 实用技术
  - git
tags:
  - git
category_bar: true
date: 2023-05-06 02:18:51
---

  ### 参考文档

廖雪峰的git教程 https://www.liaoxuefeng.com/wiki/896043488029600/900003767775424

git官方文档 https://git-scm.com/book/zh/v2

### 基础命令速查

#### 初始化仓库和提交命令

`git init`：将当前目录配置成`git`仓库，信息记录在隐藏的`.git`文件夹中，使用`ls -a`查看隐藏的文件夹。

`git add <file>`：将`file`添加到暂存区

`git add .`：将所有待加入暂存区的文件加入暂存区

`git commit -m "给自己看的备注信息"`：将暂存区的内容提交到当前分支

`git status`：查看仓库状态

#### 版本回退

`git log`:查看提交日志

`git reset --hard HEAD`:撤销对代码的修改并且将代码回滚到当前版本，`--hard`参数将暂存区与项目文件夹（工作区）中被追踪的文件的修改都撤销，但未追踪和`.gitignore`的文件不在它的管辖范围内，并删除该版本后的所有的提交。

`git reset --hard HEAD~1` ：回到上一个版本

#### 分支管理

`git checkout HEAD~1`:切换到上一个版本（切换后`HEAD`处于`detached`）

`git checkout master`:切换到master分支

`git branch -v`:查看各个分支的最后一次提交

#### 远程仓库

`git remote add origin git@xx.git` :`origin`是本地的远程仓库名称，`git@xx.git` 是远程仓库的地址

`git push -u origin master` :将本地的 `master` 分支推送到远程仓库，`-u` 参数表示关联远程分支

`git pull`：从远程仓库拉取最新代码

### 配置密钥并推送到远程仓库

执行`git init`初始化仓库，发现多了一个`.git`文件夹，所有与`git`有关的内容都储存在这个文件夹下

去`gitee`新建`acapp`仓库，在仓库首页有相关的命令行提示，可以参考。

如果没有配置用户名和邮箱，将无法使用`git commit`，配置用户名和邮箱的命令如下

```
git config --global user.name "献出心脏"
git config --global user.email "10338170+devote_your_heart@user.noreply.gitee.com"
```

在你执行`git commit`时候会将你的用户名和邮箱与提交信息一起存储在本地仓库中，在推送和拉取远程仓库时会同时提交你的身份，以方便知道谁谁谁对代码做了什么。

执行`ssh-keygen`创建公私钥，执行`cat id_rsa.pub`查看公钥，然后把公钥粘贴到`gitee`的设置里。

执行以下命令以推送到远程仓库

```
git add .
git commit -m "first"
git remote add origin git@gitee.com:devote_your_heart/acapp.git
git push -u origin "master"
```

#### 建议添加`.gitignore`

在`.gitignore`内的文件不会被追踪。使用通配符忽略文件或文件夹

比如`**/__pycache__`，`**`可以匹配任意数量的子目录，因此它可以匹配`/__pycache__`,`a/__pycache__`,`a/b/__pycache__`等文件夹

如果有子文件夹没有被`.gitignore`匹配，但在执行`git add .`时未能提交到暂存区，可能因为该子文件夹也存在`.git`文件夹，删除子文件夹下的`.git`文件夹再重新提交就行。

