Template.adminMaster.helpers
  loggedIn: () ->
    return Meteor.userId()
  canAccess: () ->
    return Groups.find().count() > 0

Template.adminMaster.events
  "click .login": (e) ->
    console.log("LOGGING IN")
    e.preventDefault()
    Meteor.loginWithGoogle(
      requestPermissions: ["email"],
      requestOfflineToken: true
    )
