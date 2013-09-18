Template.home.helpers
  ballotCount: ()->
    return Elections.find().count()
  loggedIn: () ->
    return Meteor.userId()

Template.home.events
  "click #login": (e) ->
    e.preventDefault()
    Meteor.loginWithGoogleApps
      requestPermissions: ["email"]
      requestOfflineToken: true,
