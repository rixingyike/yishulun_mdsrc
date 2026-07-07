---
createTime: 2023-06-13 09:44:46
---
# Github Pages 博客如何绑定根域名？

Godaddy 的域名不需要域名备案，这是它方便的地方，但它不充许在根域名上直接添加 CNAME 记录，换句话说，原来在国内域名商下的域名，转移到 Godaddy 后，在 Github Pages 上绑定的根域名不再有效了。

以我的博客为例说明一下。原来我可以直接将根域名 yishulun.com 绑定到 rixingyike.github.io，www 域名通过 CNAME 绑定到根域名，这样无论读者访问根域名还是 www 域名，都可以跳转到根域名。国内早期网站网址的写法一般都会在前面带上 www，其实 www 只是一个子域名，与其它 blog、news 等子域名是等同的，为了照顾国内读者的使用习惯，我将 www 域名跳转到根域名（yishulun.com）。但是，在我的域名转移到 Godaddy 之后，这一招不好使了，Godaddy 的 DNS 解析不充许将根域名以 CNAME 的方式绑定到另一个二级域名上。

在国外，普遍认为根域名是一个域名的主要域名，www 只是一个从属的子域名。并且在 Godaddy 上，根域名只允许绑定 A 记录，不允许直接绑定 CNAME 记录，据说这是为了 CNAME 记录污染 DNS 缓存，造成在根域名上使用的邮件服务投递错乱。

那么这个问题怎么解决呢？怎么兼容老读者的使用习惯，使他们打开 yishulun.com 时看到页面不是网页荒漠呢？

有人说，可以在网站根目录下添加。htaccess 文件：

```bash
RewriteEngine on
RewriteCond %{http_host}^yishulun.com [NC]
RewriteRule ^(.*)$https://www.yishulun.com/$1 [L,R=301]
```

.htaccess 是给 Apache 服务器使用的网站配置文件，如果服务器不是 Apache，这个文件是起不到任何作用的。事实上我的 Github Pages 博客是由 Node.js 驱动的，因此这一招并不好使。

有人说，在页面上使用脚本实现 301 跳转，页面访问不到，JS 脚本怎么可能执行？或者在 Godaddy DCC 配置面板上，添加 Fowarding 记录，我试了这招，等待了一晚上并不好用——因为那个博主说，Godaddy 配置生效时间长，所以等了这么久。

最后说一下我是怎么配置成功的，现在读者无论访问 yishulun.com，还是访问 www.yishulun.com，最终都会跳转到 https://yishulun.com。

第一步：在 Godaddy DCC 配置面板上，添加 A 记录分别到 185.199.108.153、185.199.109.153、185.199.110.153 和 185.199.111.153。完成这一步以后，稍后用 dig 指令检查域名配置，看到如下类似结果，说明配置成功了。

```bash
$ dig yishulun.com

; <<>> DiG 9.10.6 <<>> yishulun.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37755
;; flags: qr rd ra; QUERY: 1, ANSWER: 4, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;yishulun.com.			IN	A

;; ANSWER SECTION:
yishulun.com.		600	IN	A	185.199.109.153
yishulun.com.		600	IN	A	185.199.111.153
yishulun.com.		600	IN	A	185.199.110.153
yishulun.com.		600	IN	A	185.199.108.153
```

第二步，添加 CNAME 记录到 rixingyike.github.io。

第三步，在 Github Pages 配置处，填写 Custom domain 为 yishulun.com，注意这里是根域名。并选择 Enforce HTTPS 选项。

第四步，在网站根目录下，放置一个 CNAME 文件，内容为 yishulun.com。如果你使用的静态博客程度也是 vitepress，将这个文件放在。vitepress/public 目录下即可。

完成以上步骤，配置就算完成了。