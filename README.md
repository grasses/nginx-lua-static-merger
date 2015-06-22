# nginx-lua-static-merger


# About

`nginx-lua-static-merger`是一个基于openresty的模块，主要用于合并静态文件，减少http请求，加快静态文件访问速度的模块。

使用`nginx-lua-static-merger` 需要在编译nginx时候添加openresty的模块，或者直接安装openresty作为服务器。

`nginx-lua-static-merger`可以让你的js、css请求不要那么多，一个就够了。

![nginx-lua-static-merger](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-nginx-lua-static-merger-look.jpg)


# 0x02.Usage

## Openresty

[http://openresty.org/cn/](http://openresty.org/cn/)

Openresty是国人写的开源项目，打包了标准的 Nginx 核心，很多的常用的第三方模块，以及它们的大多数依赖项。


```
tar xzvf ngx_openresty-VERSION.tar.gz
cd ngx_openresty-VERSION/
./configure
make
make install

```
详细的安装教程还是去看官网吧。


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

![how nginx-lua-static-merger work](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-nginx-lua-static-merger-how-work.jpg)

<hr><br>

# Effect

下面是在不作处理情况请求多个js结果：

![不做处理](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-normal_http_get.jpg)

下面是第一次请求下，lua既要获取数据又要合并生成cache，属于冷数据：

![cold_js_by_ngx_static_merger](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-cold_js_by_ngx_static_merger_2.jpg)

![cold_js_by_ngx_static_merger](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-cold_js_by_ngx_static_merger_1.jpg)

第二次访问就是热数据了，访问速度是增加的：

![热数据](http://77l5jp.com1.z0.glb.clouddn.com/blog/2015-06-22-hot_js_time.jpg)

# Version

15.06.22

* Beta Version

# License

## GPL

























