# docker run -i -t -d -p 5060:5060/udp -p 5061:5061 --name opensips --network opensips-container_opensips opensips
FROM centos:7
LABEL maintainer="Antonio Alisio alisio.meneses@gmail.com"
COPY  ./files/etc/yum.repos.d /etc/yum.repos.d
RUN   rpm --import http://packages.irontec.com/public.key
RUN   rpm --import https://archive.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN   yum -y install epel-release
#RUN   yum -y update
RUN   yum install -y http://yum.opensips.org/2.3/releases/el/7/x86_64/opensips-yum-releases-2.3-3.el7.noarch.rpm
RUN   yum install -y \
      expect \
      iproute \
      mariadb \
      net-tools \
      nmap-ncat \
      opensips \
      opensips-db_mysql \
      opensips-httpd \
      opensips-json \
      opensips-pua_usrloc \
      openssh-clients \
      rsync \
      sngrep \
      tcpdump \
      vim-enhanced
EXPOSE 5060/udp
EXPOSE 5061/tcp
WORKDIR /etc/opensips/
COPY  ./files/etc/opensips .
COPY  ./files/root /root
RUN   chmod 700 /root/boot.sh
VOLUME  /etc/opensips/
CMD ["sh","/root/boot.sh"]
#CMD ["/usr/sbin/opensips","-M","8","-m","256","-F","-f","/etc/opensips/opensips.cfg"]
