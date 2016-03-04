ServiceConfiguration.configurations.remove
  service: "google"
ServiceConfiguration.configurations.insert
  service: "google",
  clientId: process.env.googleId,
  secret: process.env.googleSecret,

Accounts.onCreateUser((options, user) ->
  if user.username == "devAdmin"
    user.profile =
      netId: "devAdmin"
      name: "devAdmin"
    return user
  # Manual test user creation
  if user.emails?[0]?.address?.indexOf("testuser") == 0
    if not Meteor.user()?.isGlobalAdmin()
      throw new Meteor.Error("Error: Must be global admin to create users")
    netId = user.emails[0].address.split("@")[0]
    user.profile =
      netId: netId
      name: netId
    return user
  netId = /([A-Za-z]+[0-9]+)@nyu.edu/.exec user.services.google.email
  if !netId
    throw new Meteor.Error("Error: Account does not have valid netId!")
  user.profile =
    netId: netId[1]
    name: user.services.google.name
  return user
)
