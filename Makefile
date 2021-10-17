NETWORK_NAME = blockchain-testnet

start:
	@if [ -z "`docker network ls | grep $(NETWORK_NAME)`" ]; then docker network create $(NETWORK_NAME); fi
	sh ./tools/start.sh
remove:
	sh ./tools/remove.sh
	@if [ -n "`docker network inspect $(NETWORK_NAME) | grep \"\\"Containers\\": {}\"`" ]; then docker network rm $(NETWORK_NAME); fi
stop:
	sh ./tools/stop.sh
restart:
	sh ./tools/remove.sh
	@if [ -z "`docker network ls | grep $(NETWORK_NAME)`" ]; then docker network create $(NETWORK_NAME); fi
	sh ./tools/start.sh
