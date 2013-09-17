Accounts.loginServiceConfiguration.remove
  service: "googleApps"
Accounts.loginServiceConfiguration.insert
  service: "googleApps",
  clientId: process.env.googleId,
  secret: process.env.googleSecret,
  domain: "nyu.edu"

Accounts.onCreateUser( () ->

  )
