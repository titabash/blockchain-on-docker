FROM trufflesuite/ganache-cli

RUN apk add bash

ENTRYPOINT /bin/sh -c "node /app/ganache-core.docker.cli.js --db=/ganache_data --networkId 5777 --debug"
