---
title: Linux学习笔记 
excerpt: 整理了以ubuntu为例的linux常用命令，包括用户和用户权限管理，包管理等等。也整理了如何用ssh远程登陆服务器和用scp传输文件
index_img: /assets/1_linux/index_img.jpg
categories:
  - 实用技术
  - Linux
tags:
  - Linux
category_bar: true
date: 2023-05-06 01:03:20
---

### 基础命令速查

#### 用户管理

**启用root用户账号**：执行`sudo passwd root`设置`root`账户的密码。

**添加用户**：使用`adduser acs`添加用户`acs`，按照提示输入密码。

**登录用户**：`su root`以`root`用户身份登入，登录其他用户执行`su <username>`

**退出用户**：`exit`退出登录，当退出最后一个用户后会结束当前会话

**获取当前登录用户**：`$USER` 是一个环境变量，用于获取当前登录用户的用户名，执行`echo $USER`打印当前用户名

#### 权限管理

**添加`sudo`权限**：普通用户执行一些命令需要`sudo`权限，使用`usermod -aG sudo acs`将用户添加到 `sudo` 组中，普通用户使用`sudo`权限会被要求输入当前用户密码。

**`sudo: command not found`解决方案**：`sudo` 是一个默认不安装在一些 Linux 发行版本中的命令行工具，遇到这种情况需要切换到` root `用户，然后安装`sudo`：

```
apt update
apt install sudo
```

**添加当前用户到`Docker`用户组**：`sudo usermod -aG docker $USER`，这样可以允许该用户在后续操作中使用 `Docker `命令，而不需要通过 `sudo` 命令来执行命令。

#### 文件管理

注意根目录的位置在`/`

**rm删除命令**：`rm` 命令可以删除文件和目录，语法：`rm [-fir] <文件或目录>`。`-f `表示强制删除，不需要对每个文件进行确认提示；`-r `表示递归删除目录下的所有文件，在删除文件夹的时候使用。例如强制删除某个文件夹可以执行`rm -rf <path_to_directory>`

#### 包管理

**`apt`和`apt-get`**：`apt` 是`apt-get`的优化版，二者都是用来管理 `Ubuntu `和 `Debian` 等 `Linux` 系统上的软件包的命令行工具。 

**`apt update`**：安装包前先执行`apt update`更新软件包列表，确保安装的是最新版本的包。

**安装包**：`apt install <package_name>`

> `apt install -y <package_name> `：使用`apt`和`apt-get`都需要手动确认，通过在`install`后加上`-y`可以自动确认
>
> 在`dockerfile`里执行`apt install`一定要加上`-y`来自动确认！

**卸载包**：`apt remove <package_name>`

### ssh登录远程服务器

#### 基本用法

`ssh <user>@<hostname>`:远程登录服务器，`user`表示用户名，`hostname`表示`ip`地址或域名，默认登录端口号为22

`ssh user@hostname -p 22`：登录到服务器特定端口

#### 配置别名

创建文件 `~/.ssh/config`，然后在文件中输入：

```
Host server1
        HostName 8.130.116.50
        User acs

Host django
        HostName 8.130.116.50
        User acs
        Port 20000
```

之后再登录`acs@8.130.116.50`时，可以直接用`ssh server1`

#### 密钥登录

执行`ssh-keygen`在本地创建密钥，默认路径`.ssh`，一直按回车使用默认配置。执行完毕后后，`~/.ssh/`目录下会多出一对以 `id_dsa` 或 `id_rsa` 命名的文件，其中一个带有 `.pub` 扩展名。 `.pub` 文件是公钥，另一个则是与之对应的私钥。

之后想免密码登录哪个服务器，就将公钥传给哪个服务器即可。例如，想免密登录`server1`服务器。则将公钥中的内容，复制到`server1`中的`~/.ssh/authorized_keys`文件夹内，也可以使用`ssh-copy-id myserver`一键添加公钥。

添加完登录就不需要输入密码了。

### `scp`传输文件

`scp`是SSH协议下的一个文件传输工具，命令格式为`scp [options] <source_path> <destination_path>`，`[options]`表示可选参数，例如 `-r` 选项递归上传整个目录及其子目录的文件，`-P`指定远程 SSH 服务器的端口号，默认为 22。

例如`scp -r -P 20000 oj acs@8.130.116.50:/home/acs/`，将本地的`oj`文件夹上传到服务器的20000端口，由于已经配置过别名，命令等价于`scp -r oj django:/home/acs/`。
