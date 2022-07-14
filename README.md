# Blockchain-on-docker

## Install

1. Install docker, docker-compose, tmux

## How to build

1. Enter the project root

   ```cd <project directory>```
2. Build project

   ```make start```

## View logs

```docker logs <Container name> -f```

## Truffle Sample NFT

1. Deploy your script.

   ```truffle migrate```

2. Open truffle console.

   ```truffle console```

3. Initialize instance.

   ```truffle(development)> let textNFT = await NFT.deployed()```

4. Mint NFT.

   ```truffle(development)> textNFT.mint('<wallet address on ganache>')```

5. Confirm owner wallet address.

   ```truffle(development)> textNFT.ownerOf(0)```

## Operation

- hoge

  ```fuga```
