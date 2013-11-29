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
    Meteor.loginWithGoogleApps
      requestPermissions: ["email"],
      requestOfflineToken: true
  "click #logout": (e) ->
    Meteor.logout()
    window.location = "https://accounts.google.com/logout"

fixHome = () ->
  $("#main").css({"min-height": $(window).height() - $("#header").height() - $("#footer").height() - 15})

Template.home.rendered = fixHome
Template.about.rendered = fixHome
Template.admin.rendered = fixHome


  

