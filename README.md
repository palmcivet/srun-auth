# Srun-auth

![github](https://img.shields.io/badge/github-Palm%20Civet-blue)![build](https://img.shields.io/badge/build-pass-orange)

针对 [深澜(Srun)](https://srun.com/) 认证系统的命令行工具。

采用 Bash 编写，依赖于以下系统命令：

- base64
- curl
- ip / ifconfig

常见 Linux 发行版均携带。

使用终端登录校园网/局域网，适用于服务器、树莓派等无 GUI 场景下的联网登录。

## 安装

下载 `srun-auth.sh` 并赋予权限即可使用：

```bash
$ curl -# -O https://raw.githubusercontent.com/Palmcivet/srun-auth/master/srun-auth.sh
$ chmod 755 srun-auth.sh
```

## 用法

```bash
$ ./srun-auth.sh -u myName -p myPass 10.4.20.128
```

使用 `-h` 获取帮助。
