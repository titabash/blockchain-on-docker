FROM node:14-slim

RUN apt-get update
RUN apt-get install -y python
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y git
RUN npm i -g --unsafe-perm=true --allow-root truffle

WORKDIR /usr/src/app
