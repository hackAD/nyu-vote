FROM lingz/meteor

MAINTAINER lingliangz@gmail.com

ADD . /srv/nyu-vote

WORKDIR /srv/nyu-vote

RUN mrt install && mrt update

EXPOSE 3000

CMD /srv/nyu-vote/run.sh
