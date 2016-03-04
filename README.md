The NYU Voting System
=====================

Available for use by anyone in the NYU GNU.

Allows for live balloting, and with strict access controls to
allow concurrent elections to occur without information leakage.

Contact lz781@nyu.edu for more info.

Documentation
============

Detailed usage documentation can be found here:
[Usage Docs](https://docs.google.com/document/d/18qsoORoz7B6R_f45JJMU8bvnA1ux5EhjHrnW2LpV8sQ/edit?usp=sharing)

Configuration
=============

The app requires a Google API ID and secret. Copy the config.example
at the root of the app, and fill in the appropriate details. An external
mongoDB URI may also be specified. These options are all passed in as
environment variables, but for your convenience, there is a config file
that passes these in for you.

For your Google Apps token. Be sure your redirect URLs are correctly set.
Here is an example:

![Example](http://i.imgur.com/njeMN9w.png)

You can get a token from here:
[https://console.developers.google.com](https://console.developers.google.com)

No configuration is necessary for this if run in full stack mode as it
will inherit it from the docker-compose configuration in the parent.

For standalone mode, either pass the environment variables in manually
or modify the config file appropriately.

```
cp config.example config
nano config
```

Note: Make sure to check the Google Cloud Console to make sure the
redirect uris are the same as the URIs you are using, especially if
you are not developing on localhost.

Deployment (full stack)
=========

To deploy the app with the reverse router visit the repo here:
[https://github.com/hackAD/docker-nyu-vote-server](hackAD/docker-nyu-vote-server)
for instructions.

### Configuration

Deployment (Dev)
==========

For dev, it actually mounts the drive so you only need to build once

```
./scripts/build.sh
```

Then just run the starting script

```
./scripts/start.sh
meteor
```

It should now be running on Port 3000

Deployment (standalone)
==========

This is is if you only want to run this app on its own. You MUST have 
the MONGO_URL environment variable setup as it runs a bundled version 
of the app. If you do not want to run a separate MongoDB instance, just
run the app in Dev mode as described above.


First install docker:
```
curl https://raw.githubusercontent.com/lingz/Scripts/master/install/docker.sh | bash
```

Make sure to build the app the first time and after any changes

```
./scripts/build.sh
```

Then to start the app:
```
./scripts/start.sh
```

It should now be running on Port 3000

Docker Builds
============

There is a githook on this repo to build a new Docker image whenever there is
a push to master. **Therefore ONLY push stable, tested branches to master. If you
don't do this, new instances of NYU Vote could be broken**. Do development on
another branch, and push to master only when it is stable. Our docker image
can be found here:

[Docker Hub hackad/nyu-vote](https://hub.docker.com/r/hackad/nyu-vote/)

Running the first time
======================

The app ships with a user account called "devAdmin" which is the first superadmin.
When you first set this up you probably want to add your own NYU account to the
super user list and delete this devAdmin account. To do so:

1. Open a Javascript Console in the browser and enter:

```
Meteor.loginWithPassword("devAdmin", "password")
```

Then check if it worked with

```
Meteor.user()
// You should see:
> User {_id: "jbqgxRC9FX9AdWPoc", profile: Object, emails: Array[1], username: "devAdmin", _dep: T…r.Dependency…}
```

2. Go to HOST/admin and go to Groups and Global Admins. Then
add the NetIds you want to both the Admins and Users of this list.
Check that it works by logging out, and logging back in with your
user and seeing if you can access HOST/admin

3. Once you have verified that it is working from your user, you want to
click the "Delete Superuser" button on the sidebar from the
HOST/admin page. If it worked, then the button will dissapear.
