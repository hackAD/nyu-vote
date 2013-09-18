Accounts.loginServiceConfiguration.remove
  service: "googleApps"
Accounts.loginServiceConfiguration.insert
  service: "googleApps",
  clientId: process.env.googleId,
  secret: process.env.googleSecret,
  domain: "nyu.edu"

Accounts.onCreateUser( (options, user) ->
  if user.username == "devAdmin" && isDevEnv()
    user.profile =
      netId: "devAdmin"
    return user
  if !user.services?.googleApps?.email
    throw new Meteor.Error("Not Google Apps account detected")
  netId = /([A-Za-z]+[0-9]+)@nyu.edu/.exec user.services.googleApps.email
  if !netId
    throw new Meteor.Error("Account does not have valid netId")
  user.profile =
    netId: netId[1]
  return user
  )
