FROM dmitrymomot/nginx

MAINTAINER "Dmitry Momot" <mail@dmomot.com>

RUN apt-get install -y php5-fpm php5-cli php5-json php5-mcrypt php5-mysql php5-gd php5-curl

ENV PMA_SECRET          blowfish_secret
ENV PMA_USERNAME        pma
ENV PMA_PASSWORD        password
ENV PMA_NO_PASSWORD     0
ENV PMA_AUTH_TYPE       cookie
ENV MYSQL_USERNAME      mysql
ENV MYSQL_PASSWORD      password

RUN apt-get update
RUN apt-get install -y mysql-client

ENV PMA_VERSION 4.5.5.1
ENV MAX_UPLOAD "50M"

RUN wget "https://files.phpmyadmin.net/phpMyAdmin/$PMA_VERSION/phpMyAdmin-$PMA_VERSION-english.tar.bz2" \
 && tar -xvjf "/phpMyAdmin-$PMA_VERSION-english.tar.bz2" -C / \
 && rm "/phpMyAdmin-$PMA_VERSION-english.tar.bz2" \
 && rm -r /data/www/public \
 && mv "/phpMyAdmin-$PMA_VERSION-english" /data/www/public

ADD bootstrap/config.inc.php /
ADD bootstrap/create_user.sql /
ADD bootstrap/phpmyadmin-start /usr/local/bin/
ADD bootstrap/phpmyadmin-firstrun /usr/local/bin/

RUN chmod +x /usr/local/bin/phpmyadmin-start
RUN chmod +x /usr/local/bin/phpmyadmin-firstrun

RUN sed -i "s/http {/http {\n        client_max_body_size $MAX_UPLOAD;/" /etc/nginx/nginx.conf
RUN sed -i "s/upload_max_filesize = 2M/upload_max_filesize = $MAX_UPLOAD/" /etc/php5/fpm/php.ini
RUN sed -i "s/post_max_size = 8M/post_max_size = $MAX_UPLOAD/" /etc/php5/fpm/php.ini

EXPOSE 80

CMD phpmyadmin-start
