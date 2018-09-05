#!/bin/bash
# Programa:
#       Este programa faz as configurações iniciais doopensips-cp
#
IP_SERVIDOR_DOCKER=${IP_SERVIDOR_DOCKER:-"127.0.0.1"}
PORTA_DO_SERVICO=${PORTA_DO_SERVICO:-"5060"}
PORTA_DA_INTERFACE_MI_OPENSIPS=${PORTA_DO_INTERFACE_MI_OPENSIPS:-"8080"}
IP_DO_CONTAINER=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
IP_BANCO_DE_DADOS=${IP_BANCO_DE_DADOS:-"bancodedados"}
PORTA_BANCO_DE_DADOS=${PORTA_BANCO_DE_DADOS:-"3306"}
SENHA_ROOT_BANCO_DE_DADOS=${SENHA_BANCO_DE_DADOS:-"opensips"}
SENHA_BANCO_DE_DADOS=${SENHA_BANCO_DE_DADOS:-"opensipsrw"}
USUARIO_BANCO_DE_DADOS=${USUARIO_BANCO_DE_DADOS:-"opensips"}
echo "IP do container" : ${IP_DO_CONTAINER}
echo "IP do servidor rodando o container : ${IP_SERVIDOR_DOCKER}"
echo "Aguardando a carga do opensips (porta ${PORTA_DA_INTERFACE_MI_OPENSIPS})"
while ! nc -z opensips ${PORTA_DA_INTERFACE_MI_OPENSIPS}; do
  echo Esperando;
  sleep 2;
done;
echo Opensips Carregado.!;

if [[ ! -f /var/www/html/opensips-cp/container_provisionado ]]; then
  # Configurar banco de dados
  mysql -Dopensips -p${MYSQL_ROOT_PASSWORD:-opensips} -h ${IP_BANCO_DE_DADOS} < /var/www/html/opensips-cp/config/tools/admin/add_admin/ocp_admin_privileges.mysql
  mysql -Dopensips -p${MYSQL_ROOT_PASSWORD:-opensips} -h ${IP_BANCO_DE_DADOS} opensips < opensips_config.sql
  mysql -Dopensips -p${MYSQL_ROOT_PASSWORD:-opensips} -h ${IP_BANCO_DE_DADOS} < /var/www/html/opensips-cp/config/tools/system/smonitor/tables.mysql
  mysql -Dopensips -p${MYSQL_ROOT_PASSWORD:-opensips} -h ${IP_BANCO_DE_DADOS} < /var/www/html/opensips-cp/config/tools/system/smonitor/tables.mysql
  echo Tabelas do opensips control panel configuradas
  touch /var/www/html/opensips-cp/container_provisionado
fi
httpd -D FOREGROUND
