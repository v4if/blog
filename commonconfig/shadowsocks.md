## vultr centos7 ShadowSocks

## 安装shadowsocks
```bash
$ yum install m2crypto python-setuptools
$ easy_install pip
$ pip install shadowsocks
```

`vi  /etc/shadowsocks.json`
```bash
{
    "server":"::",
    "server_port": 443,
    "local_address": "127.0.0.1",
    "local_port":1080,
    "password":"12345678",
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open": true
}
```

## 配置防火墙

### 安装防火墙
```bash
$ yum install firewalld
```

### 启动防火墙
```bash
$ systemctl start firewalld
```

### 端口号是你自己设置的端口
```bash
$ firewall-cmd --permanent --zone=public --add-port=443/tcp
$ firewall-cmd --reload
```

## 启动ShadowSocks
```bash
ssserver -c /etc/shadowsocks.json  #前台终端启动
ssserver -c /etc/shadowsocks.json --fast-open -q -d start   #后台启动
ssserver -d stop #停止
```

## 开启BBR TCP加速
[Google BBR](https://github.com/iMeiji/shadowsocks_install/wiki/%E5%BC%80%E5%90%AFTCP-BBR%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6%E7%AE%97%E6%B3%95)
