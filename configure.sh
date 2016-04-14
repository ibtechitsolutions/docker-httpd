mkdir -p /var/www/html

groupadd -g 10099 ibtech-www
useradd -u 10099 -g 10099 -M -s /usr/sbin/nologin ibtech-www

cat > /usr/local/apache2/conf/extra/loja.conf << EOF
LoadModule allowmethods_module modules/mod_allowmethods.so
LoadModule file_cache_module modules/mod_file_cache.so
LoadModule cache_module modules/mod_cache.so
LoadModule cache_disk_module modules/mod_cache_disk.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule include_module modules/mod_include.so
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
LoadModule session_module modules/mod_session.so
LoadModule session_cookie_module modules/mod_session_cookie.so
LoadModule vhost_alias_module modules/mod_vhost_alias.so
LoadModule negotiation_module modules/mod_negotiation.so
LoadModule actions_module modules/mod_actions.so
LoadModule rewrite_module modules/mod_rewrite.so

User ibtech-www
Group ibtech-www

DocumentRoot "/var/www/html"
<Directory "/var/www/html">
     Options FollowSymLinks
     Options Indexes FollowSymLinks
     AllowOverride All
     DirectoryIndex index.php index.html
     Require all granted
</Directory>

ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://php-fpm:9000/var/www/html/\$1

KeepAlive Off

ServerTokens Minimal
EOF


echo "Include /usr/local/apache2/conf/extra/loja.conf" >> /usr/local/apache2/conf/httpd.conf

echo 'Yes, do as I say!' | apt-get remove bash -y -q --force-yes
