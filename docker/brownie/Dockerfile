FROM python:3.8-slim

WORKDIR /usr/src/app

RUN pip install --upgrade pip
RUN pip install pytest
RUN apt-get update
RUN apt-get install -y libpq-dev
RUN apt-get install -y gcc

RUN pip install eth-brownie
RUN brownie init
