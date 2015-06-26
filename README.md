# nginx-lua-static-merger

<hr><br>

# About

详细教程请看：[http://homeway.me/2015/06/22/nginx-lua-static-merger/](http://homeway.me/2015/06/22/nginx-lua-static-merger/)

`nginx-lua-static-merger`是一个基于openresty的模块，主要用于合并静态文件，减少http请求，加快静态文件访问速度的模块。

使用`nginx-lua-static-merger` 需要在编译nginx时候添加openresty的模块，或者直接安装openresty作为服务器。

`nginx-lua-static-merger`可以让你的js、css请求不要那么多，一个就够了。


<center><img alt="nginx-lua-static-merger" src="http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-nginx-lua-static-merger-look.jpg"></center>

<hr><br>

# Usage

## install openresty

[http://openresty.org/cn/](http://openresty.org/cn/)

```
wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz
tar xzvf ngx_openresty-1.7.10.1.tar.gz
cd ngx_openresty-1.7.10.1/
./configure
make
make install

```

## install nginx-lua-static-merger

> $git clone https://github.com/grasses/nginx-lua-static-merger

> $cd nginx-lua-static-merger

> $chmod +x install

> $./install

Remember install openresty before run install script.


## file path

	|--/usr/local/openresty/nginx
	|						`--lua
	|							`--nginx-lua-static-merger.lua
	|						`--conf 
	|							`--nginx.lua
	|--/www/openresty/static
	|				`--js
	|				`--css
	|				`--cache
	
注意

1、`nginx.conf`中的`lua_package_path "/usr/local/openresty/lualib/?.lua;;";`和
`lua_package_cpath "/usr/local/openresty/lualib/?.so;;";`，如果你是编译nginx而不是直接安装openresty，目录记得放对。

2、确保`/www/openresty/static`有Lua写的权限。

## use

前端调用方法如下：

	<link rel="stylesheet" href="/bootstrap/css/bootstrap.min.css;/qiniu/css/main.css;/css/navbar.css">
	<script src="/js/jquery.min.js;/js/main.js;/qiniu/bootstrap/js/bootstrap.min.js;/qiniu/js/plupload/plupload.full.min.js;/qiniu/js/plupload/i18n/zh_CN.js"></script>

<hr><br>

# How it work

Nginx在location通过 `content_by_lua_file` 把接下来的处理丢个Lua做逻辑。

Lua通过uri进行md5编码，判断cache是否存在，如果cache不存在，循环分割、遍历uri，访问响应的路径，查找静态文件，存在则记录，最后写cache入文件，方便下次访问。

<center><img alt="how nginx-lua-static-merger work" src="http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-nginx-lua-static-merger-how-work.jpg"></center>


<hr><br>


# Version

15.06.22

* Beta Version

15.06.26

* Fix a bug (single static file error)

* Add install script



<hr><br>


# License

## GPL