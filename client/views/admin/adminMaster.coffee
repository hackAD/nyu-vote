Session.setDefault("listMode", "elections")
Template.adminMaster.helpers
  loggedIn: () ->
    return Meteor.userId()
  canAccess: () ->
    return Groups.find().count() > 0
  electionsCount: () ->
    return Elections.find().count()
  groupsCount: () ->
    return Groups.find().count()
  listItems: () ->
    if Session.get("listMode") == "elections"
      return Elections.find()
    else
      return Groups.find()
  isElections: () ->
    return Session.equals("listMode", "elections")
  collectionName: () ->
    if Session.get("listMode") == "elections"
      return "Election"
    else
      return "Group"
  username: () ->
    return Meteor.user()?.profile.name

Template.adminMaster.events
  "click .login": (e) ->
    e.preventDefault()
    Meteor.loginWithGoogle(
      requestPermissions: ["email"],
      requestOfflineToken: true
    )

  "click .switch-election": (e) ->
    e.preventDefault()
    Session.set("listMode", "elections")

  "click .switch-group": (e) ->
    e.preventDefault()
    Session.set("listMode", "groups")
