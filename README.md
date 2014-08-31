The NYU Voting System
=====================

Available for use by anyone in the NYU GNU.

Allows for live balloting, and with strict access controls to
allow concurrent elections to occur without information leakage.

Contact lz781@nyu.edu for more info.

Configuration
============

The app requires a Google API ID and secret. Copy the config.example
at the root of the app, and fill in the appropriate details. An external
mongoDB URI may also be specified.

```
cp config.example config
nano config
```

Deployment (full stack)
=========

It is recommended you deploy the entire app stack. Visit the repo 
[https://github.com/hackAD/docker-nyu-vote-server](hackAD/docker-nyu-vote-server)
for instructions.

Deployment (standalone)
==========

This is is if, for some reason, you only want to run this app in isolation.

First install docker:
```
curl https://raw.githubusercontent.com/lingz/Scripts/master/install/docker.sh | bash
```

Then to start the app:
```
./scripts/start.sh
```
