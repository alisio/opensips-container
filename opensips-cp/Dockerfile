# docker build --rm -t opensips-cp .
# docker run -i -t -d -p 80:80 -p 443:443 --net opensips-container_opensips --name opensips-cp opensips-cp
FROM  centos:7
LABEL maintainer="Antonio Alisio alisio.meneses@gmail.com"
RUN   yum update -y
RUN   yum install -y \
      httpd \
      iproute \
      less \
      mariadb \
      nmap-ncat \
      php \
      php-gd \
      php-mysql \
      php-xmlrpc \
      php-pear \
      php-pecl-apc \
      rsync \
      unzip \
      vim-enhanced \
      wget
RUN   sed -i "s/short_open_tag *= *Off/short_open_tag = On/g" /etc/php.ini
RUN 	pear install MDB2 \
      pear install MDB2#mysql \
      pear install log
      #pear upgrade mdb2-beta mdb2_driver_mysqli-beta
#     Configurar php
WORKDIR /root/opensips-cp
# Configurar opensips-CP
RUN   wget https://github.com/OpenSIPS/opensips-cp/archive/7.2.3.zip
RUN   unzip 7.2.3.zip
RUN   /bin/rm -f 7.2.3.zip
RUN   mv opensips-cp-7.2.3 /var/www/html/opensips-cp
RUN   chown -R apache:apache /var/www/html/opensips-cp/
RUN   chown apache:apache /var/www/html/opensips-cp/config/access.log
COPY  ./files/etc/httpd/conf.d/opensips.cp.conf /etc/httpd/conf.d/opensips.cp.conf
COPY  ./files/opensips_config.sql .
COPY  ./files/root/boot.sh /root/boot.sh
RUN   sed -i 's/^ $config->db_host =.*/ $config->db_host = \"bancodedados\";/g' /var/www/html/opensips-cp/config/db.inc.php
RUN   sed -i 's/^ $config->db_port =.*/  $config->db_port = \"3306\";/g' /var/www/html/opensips-cp/config/db.inc.php
RUN   sed -i 's/json:127.0.0.1:8080\/json/json:opensips:8080\/json/g' /var/www/html/opensips-cp/config/boxes.global.inc.php
# Configurar dialplan no cp
RUN   sed -i 's/array("a","Descr a"),/array("3","usrloc"),/g' /var/www/html/opensips-cp/config/tools/system/dialplan/local.inc.php
RUN   sed -i 's/array("b","Descr b"),/array("4","routing"),/g' /var/www/html/opensips-cp/config/tools/system/dialplan/local.inc.php
RUN   sed -i 's/array("c","Descr c"),/array("5","service"),/g' /var/www/html/opensips-cp/config/tools/system/dialplan/local.inc.php
# Configurar SIPTrace
RUN   sed -i 's/ $proxy_list=array("udp:.*/ $proxy_list=array("udp:opensips:5060","tcp:opensips:5060");/g' /var/www/html/opensips-cp/config/tools/system/siptrace/local.inc.php
EXPOSE  80
EXPOSE  443
VOLUME  /var/www/html/opensips-cp
CMD  ["sh","/root/boot.sh"]
#CMD   ["httpd", "-D",  "FOREGROUND"]
