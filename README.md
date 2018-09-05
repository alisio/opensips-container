# opensips-container
Docker file para criar container opensips baseado na imagem do Centos 7.

1. Criar rede dos containers
1. Criar e iniciar o  container do banco de dados mysql
1. Criar e iniciar imagem do opensips
1. Criar e iniciar o container do opensips

Criar Rede dos containers:
```sh
sudo docker network create rede_opensips
```

Criar e iniciar o container do banco de dados:
```sh
sudo docker run --name bancodedados -e MYSQL_ROOT_PASSWORD=opensips -d --net rede_opensips mariadb
```

Criar e iniciar imagem do opensips:

```sh
sudo git clone https://github.com/alisio/opensips-container.git
cd opensips-container
sudo docker build --rm -t opensips-container .
```

Executar:

Executar container sem montagem de volumes

```sh
sudo docker run -d -e IP_SERVIDOR_DOCKER="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')" --name opensips01 -p 5060:5060/udp --net rede_opensips opensips-container
```

Conectar:

```sh
sudo docker exec -t -i opensips01 /bin/bash
``

Utilizando o compose:
1. Editar o arquivo docker-compose.yml e inserir o IP do servidor em IP_SERVIDOR_DOCKER
1. executar o comando para criacao dos containers
```sh
IP_SERVIDOR_DOCKER="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')" docker-compose up
```
