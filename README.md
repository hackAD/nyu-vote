The NYU Voting System
=====================

Available for use by anyone in the NYU GNU.

Allows for live balloting, and with strict access controls to
allow concurrent elections to occur without information leakage.

Contact lz781@nyu.edu for more info.

Documentation
============

Detailed usage documentation can be found here:
https://docs.google.com/document/d/18qsoORoz7B6R_f45JJMU8bvnA1ux5EhjHrnW2LpV8sQ/edit?usp=sharing

Configuration
=============

The app requires a Google API ID and secret. Copy the config.example
at the root of the app, and fill in the appropriate details. An external
mongoDB URI may also be specified.

No configuration is necessary for this if run in full stack mode as it
will inherit it from the fig configuration in the parent.

For standalone mode, modify the config file appropriately.

```
cp config.example config
nano config
```

Note: this app with default hackAD keys can only run on port 3000
without SSL, and on port 80 with SSL (which is handled by the full
stack deployment), as these are the only redirect_uris allowed on
the Google Cloud API console currently.

Deployment (full stack)
=========

It is recommended you deploy the entire app stack. Visit the repo 
[https://github.com/hackAD/docker-nyu-vote-server](hackAD/docker-nyu-vote-server)
for instructions.

### Configuration


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
