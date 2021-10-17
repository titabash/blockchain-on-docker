FROM trufflesuite/ganache-cli

ENTRYPOINT /bin/sh -c "node /app/ganache-core.docker.cli.js --db=/ganache_data --mnemonic '${MNEMONIC}' --networkId 5777 --debug"
