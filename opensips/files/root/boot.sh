#!/bin/bash
# Programa:
#       Este programa configura o opensips no primeiro boot
#
IP_SERVIDOR_DOCKER=${IP_SERVIDOR_DOCKER:-"127.0.0.1"}
PORTA_DO_SERVICO=${PORTA_DO_SERVICO:-"5060"}
IP_DO_CONTAINER=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
IP_BANCO_DE_DADOS=${IP_BANCO_DE_DADOS:-"bancodedados"}
PORTA_BANCO_DE_DADOS=${PORTA_BANCO_DE_DADOS:-"3306"}
SENHA_ROOT_BANCO_DE_DADOS=${SENHA_BANCO_DE_DADOS:-"opensips"}
SENHA_BANCO_DE_DADOS=${SENHA_BANCO_DE_DADOS:-"opensipsrw"}
USUARIO_BANCO_DE_DADOS=${USUARIO_BANCO_DE_DADOS:-"opensips"}

echo "IP do container" : ${IP_DO_CONTAINER}
echo "IP do servidor rodando o container : ${IP_SERVIDOR_DOCKER}"
echo Aguardando a carga do banco de dados
while ! nc -z bancodedados ${PORTA_BANCO_DE_DADOS}; do
  echo Esperando;
  sleep 2;
done;
echo Banco de dados carregado!;

if [[ ! -f /etc/opensips/container_provisionado ]]; then

  # Alterar config do opensips
  sed -i "s/advertised_address=.*/advertised_address=\"${IP_SERVIDOR_DOCKER}\"/g" /etc/opensips/opensips.cfg
  sed -i "s/alias=.*/alias=\"${IP_DO_CONTAINER}\"/g" /etc/opensips/opensips.cfg
  sed -i "s/listen=.*/listen=udp:${IP_DO_CONTAINER}:${PORTA_DO_SERVICO}/g" /etc/opensips/opensips.cfg
  sed -i "s/mysql:\/\/opensips:opensipsrw@localhost\/opensips/mysql:\/\/opensips:opensipsrw@${IP_BANCO_DE_DADOS}\/opensips/g" /etc/opensips/opensips.cfg
  sed -i "s/SIP_DOMAIN=.*/SIP_DOMAIN=${IP_SERVIDOR_DOCKER}/g" /etc/opensips/opensipsctlrc
  sed -i "s/DBHOST=.*/DBHOST=${IP_BANCO_DE_DADOS}/g" /etc/opensips/opensipsctlrc
  sed -i "s/DBPORT=.*/DBPORT=${PORTA_BANCO_DE_DADOS}/g" /etc/opensips/opensipsctlrc
  sed -i "s/DBRWUSER=.*/DBRWUSER=${USUARIO_BANCO_DE_DADOS}/g" /etc/opensips/opensipsctlrc
  sed -i "s/DBRWPW=.*/DBRWPW=\"${SENHA_BANCO_DE_DADOS}\"/g" /etc/opensips/opensipsctlrc
cat << EOF > /root/dbconfig.txt
$SENHA_ROOT_BANCO_DE_DADOS
y
y
EOF

  opensipsdbctl create < /root/dbconfig.txt
  mysql -uroot -p${SENHA_ROOT_BANCO_DE_DADOS} -h ${IP_BANCO_DE_DADOS} opensips -e "alter table subscriber add column dpid int default 0"
    mysql -uroot -p${SENHA_ROOT_BANCO_DE_DADOS} -h ${IP_BANCO_DE_DADOS} opensips -e "alter table subscriber add column privacy int default 0"
  mysql -uroot -p${SENHA_ROOT_BANCO_DE_DADOS} -h ${IP_BANCO_DE_DADOS} opensips -e "ALTER TABLE acc ADD caller_id CHAR( 64 ) NOT NULL ;"
  mysql -uroot -p${SENHA_ROOT_BANCO_DE_DADOS} -h ${IP_BANCO_DE_DADOS} opensips -e  "ALTER TABLE acc ADD callee_id CHAR( 64 ) NOT NULL ;"
  mysql -uroot -p${SENHA_ROOT_BANCO_DE_DADOS} -h ${IP_BANCO_DE_DADOS} opensips -e  "ALTER TABLE acc ADD leg_type CHAR(10) NOT NULL;"
  # Adicionar o dominio do proprio servidor
  echo opensipsctl domain add ${IP_SERVIDOR_DOCKER}
  echo opensipsctl domain add ${IP_DO_CONTAINER}
  opensipsctl domain add ${IP_SERVIDOR_DOCKER}
  opensipsctl domain add ${IP_DO_CONTAINER}
  # TODO: adicionar gateways
  touch /etc/opensips/container_provisionado
fi
/usr/sbin/opensips -M 8 -m 256 -F -f /etc/opensips/opensips.cfg
