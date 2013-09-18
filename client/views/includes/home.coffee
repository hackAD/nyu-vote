Template.home.helpers
  ballotCount: ()->
    return Elections.find().count()
  loggedIn: () ->
    return Meteor.userId()
  noMoreVotes: () ->
    return Elections.find().count() == 0
  electionsReady: () ->
    return electionHandle.ready()


Template.home.events
  "click #login": (e) ->
    e.preventDefault()
    Meteor.loginWithGoogleApps
      requestPermissions: ["email"]
      requestOfflineToken: true,
  "click #logout": (e) ->
    e.preventDefault()
    Meteor.logout()

Template.home.rendered = () ->
  $("#main").css({"min-height": $(window).height() - $("#header").height() - $("#footer").height() - 20 })

