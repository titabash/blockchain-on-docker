# Blockchain-on-docker

## Install
1. Install docker, docker-compose, tmux

## How to build
1. Enter the project root<br>
   ```cd <project directory>```
2. Build project<br>
   ```make start```

## View logs
```docker logs <Container name> -f```

## Brownie Sample Test
```brownie bake token && cd token ```<br>
```brownie networks add Development dev2 cmd=ganache-cli host=http://10.254.249.5:8545```<br>
```brownie test --network dev```

## Truffle Sample Test
```truffle init ```<br>
```truffle migrate```<br>
```truffle console```<br>
```truffle(development)> let helloWorld = await HelloWorld.deployed()```<br>
```truffle(development)> helloWorld.say()```<br>

## Operation
- hoge<br>
  ```fuga```
