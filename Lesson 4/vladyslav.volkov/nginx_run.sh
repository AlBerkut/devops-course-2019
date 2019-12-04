#!/bin/bash

if nginx -v >/dev/null 2>&1; then

	nginx_ver=$(nginx -v 2>&1)
	echo "Removing $nginx_ver"
	apt-get purge nginx -y
else

	echo "Nginx is not installed"

fi

apt-get update
apt-get install curl gnupg2 ca-certificates lsb-release -y
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | tee /etc/apt/sources.list.d/nginx.list
curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
apt-get update
apt-get install nginx=1.14.2* -y

mkdir /etc/nginx/sites-available /etc/nginx/sites-enabled
sed -i '/http {/a include /etc/nginx/sites-enabled/*.conf;' /etc/nginx/nginx.conf
mv /etc/nginx/conf.d/default.conf /etc/nginx/sites-available/default.conf
ln -sf /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/
service nginx restart
curl -X GET 127.0.0.1 | grep -o "Welcome to nginx!" | head -1

nginx_proc=$(ps -lfC nginx | grep "master process" | awk '{print $4}')
nginx_proc_count=$(ps -lfC nginx | grep -c "worker process")
echo "Nginx main process have a PID: $nginx_proc"
echo -e "Number of Nginx working processes: \033[31m$nginx_proc_count\e[0m"
