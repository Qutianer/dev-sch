FROM nginx:1.21.3
RUN apt-get update && apt-get -y install php7.3-fpm php7.3-mysql stress-ng && rm -rf /var/lib/apt/lists/*
COPY include/40-php-fpm.sh  /docker-entrypoint.d/
COPY include/site.conf /etc/nginx/conf.d/default.conf
COPY include/nginx.conf /etc/nginx/nginx.conf
COPY src /opt/app/api
