# docker run -i -t -d -p 5060:5060/udp -p 5061:5061 --name opensips --network opensips-container_opensips opensips
FROM centos:7
LABEL maintainer="Antonio Alisio alisio.meneses@gmail.com"
COPY  ./files/etc/yum.repos.d /etc/yum.repos.d
RUN   rpm --import http://packages.irontec.com/public.key
RUN   rpm --import https://archive.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
RUN   yum -y install epel-release
RUN   yum -y update
RUN   yum install -y \
      iproute \
      less \
      net-tools \
      rsync \
      sngrep \
      tcpdump \
      vim-enhanced \
      wget
WORKDIR   /usr/src/
RUN wget http://downloads.asterisk.org/pub/telephony/certified-asterisk/releases/asterisk-certified-13.21-cert2.tar.gz
RUN tar -xvzf asterisk-*
WORKDIR   /usr/src/asterisk-certified-13.21-cert2
RUN ./contrib/scripts/install_prereq install
RUN ./configure
RUN make menuselect.makeopts
RUN menuselect/menuselect --enable chan_sip menuselect.makeopts
RUN menuselect/menuselect --enable chan_console menuselect.makeopts
RUN menuselect/menuselect --enable app_confbridge menuselect.makeopts
RUN make && make install
RUN make samples
WORKDIR /etc/asterisk
COPY  ./files/etc/asterisk .
VOLUME  /etc/asterisk/
EXPOSE   5600/udp
EXPOSE   5601/tcp
EXPOSE   10000-10100
#CMD ["sh","/root/boot.sh"]
CMD asterisk -vvvc
