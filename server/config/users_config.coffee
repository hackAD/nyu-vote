ServiceConfiguration.configurations.remove
  service: "google"
ServiceConfiguration.configurations.insert
  service: "google",
  clientId: process.env.googleId,
  secret: process.env.googleSecret,

Accounts.onCreateUser( (options, user) ->
  if user.username == "devAdmin" && isDevEnv()
    user.profile =
      netId: "devAdmin"
    return user
  netId = /([A-Za-z]+[0-9]+)@nyu.edu/.exec user.services.google.email
  if !netId
    throw new Meteor.Error("Error: Account does not have valid netId!")
  user.profile =
    netId: netId[1]
    name: user.services.google.name
  return user
  )
