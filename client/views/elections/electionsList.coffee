Template.electionsList.helpers
  electionItems: () ->
    return Elections.find()

Template.electionsList.events
  "click a": (e) ->
    e.preventDefault()
    Meteor.loginWithGoogleApps
      requestPermissions: ["email"]
      requestOfflineToken: true,

