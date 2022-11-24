FROM node:18

RUN apt update
RUN apt upgrade
RUN apt install -y git

RUN yarn install
RUN yarn add -D hardhat

WORKDIR /usr/src/app
