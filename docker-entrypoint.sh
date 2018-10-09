#!/bin/bash


# THANKS https://github.com/SocialEngine/docker-php-apache :)


randname() {
    local LC_ALL=C
    tr -dc '[:lower:]' < /dev/urandom |
        dd count=1 bs=16 2>/dev/null
}

create_user_from_directory_owner() {
    if [ "$MODE" = "dev" ]; then
        owner=www-data
        group=www-data
    else
        if [ $# -ne 1 ]; then
            echo "Creates a user (and group) from the owner of a given directory, if it doesn't exist."
            echo "Usage: create_user_from_directory_owner <path>"

            return 1
        fi

        local owner group owner_id group_id path
        path=$1

        owner=$(stat -c '%U' $path)
        group=$(stat -c '%G' $path)
        owner_id=$(stat -c '%u' $path)
        group_id=$(stat -c '%g' $path)
        
        if [ $owner = "UNKNOWN" ]; then
            owner=$(randname)
            if [ $group = "UNKNOWN" ]; then
                group=$owner
                addgroup --system --gid "$group_id" "$group" > /dev/null
            fi
            adduser --no-create-home --system --uid=$owner_id --gid=$group_id "$owner" > /dev/null
            echo "[Apache User] Created user for uid ($owner_id), and named it '$owner'"
        fi
    fi

    if [ "$(grep -lir loja.conf /usr/local/apache2/conf/httpd.conf | wc -l)" = 0 ]; then
        echo "IncludeOptional /usr/local/apache2/conf/extra/loja.conf" >> /usr/local/apache2/conf/httpd.conf
    fi

    if [ "$(grep -lir loja.conf.d /usr/local/apache2/conf/httpd.conf | wc -l)" = 0 ]; then
        echo "IncludeOptional /usr/local/apache2/conf/loja.conf.d/*.conf" >> /usr/local/apache2/conf/httpd.conf
    fi

    if [ -d /usr/local/apache2/conf/loja.conf.d ]; then
	    touch /usr/local/apache2/conf/extra/loja.conf
    else
	    mkdir /usr/local/apache2/conf/loja.conf.d

    	if [ ! -f /usr/local/apache2/conf/extra/loja.conf ]; then
	        cat << EOF > /usr/local/apache2/conf/extra/loja.conf
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

DocumentRoot "/var/www/html"
<Directory "/var/www/html">
     Options FollowSymLinks
     AllowOverride All
     DirectoryIndex index.php index.html
     Require all granted
</Directory>

Alias /img/banner/ /var/www/img/banner/
Alias /img/destaque/ /var/www/img/destaque/
Alias /img/galeria/ /var/www/img/galeria/
Alias /img/layout/ /var/www/img/layout/
Alias /img/medida/ /var/www/img/medida/
Alias /img/produtos/ /var/www/img/produtos/
Alias /img/promocao/ /var/www/img/promocao/
Alias /img/vantagem/ /var/www/img/vantagem/
Alias /img/vendedor/ /var/www/img/vendedor/

<Directory /var/www/img>
     Options FollowSymLinks
     Require all granted
</Directory>

<Location /protected>
  SSLOptions +StdEnvVars
  SSLVerifyClient require
</Location>

ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://php-fpm:9000/var/www/html/\$1

KeepAlive Off

ServerTokens Minimal
EOF
	fi

    fi

    export APACHE_RUN_USER=$owner
    export APACHE_RUN_GROUP=$group
    echo "[Apache User] Set APACHE_RUN_USER to $owner and APACHE_RUN_GROUP to $group"

    return 0
}


create_user_from_directory_owner "/var/www/html"

exec "$@"
