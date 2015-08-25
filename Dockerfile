FROM ubuntu:14.04

MAINTAINER lingliangz@gmail.com

RUN apt-get update
RUN apt-get install -y curl
RUN curl https://install.meteor.com/ | sh

ADD . /srv/nyu-vote

WORKDIR /srv/nyu-vote
RUN mkdir build
RUN meteor build .

EXPOSE 3000

CMD meteor
