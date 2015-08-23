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
mongoDB URI may also be specified. You can also change the SITE_URL
if you are developing on a remote server (be sure to also add
that URL to the Google Apps callback)

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

Start Development Server
=========

This is for running just the nyu-vote server during development.

First make sure you have docker installed

```
curl -sSL https://get.docker.com/ | sh
```

Then build the docker config

```
./scripts/build.sh
```

Finally, run the dev script and start the server

```
./scripts/dev.sh
mrt
```

By default, you should now have a server running on port 3000.

Deployment (full stack)
=========

It is recommended you deploy the entire app stack. Visit the repo 
[https://github.com/hackAD/docker-nyu-vote-server](hackAD/docker-nyu-vote-server)
for instructions.

The script in ./scripts/start.sh does not currently work
