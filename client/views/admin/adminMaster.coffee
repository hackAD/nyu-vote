Session.setDefault("listMode", "elections")
Template.adminMaster.helpers
  loggedIn: () ->
    return Meteor.userId()
  canAccess: () ->
    # if the server is sending down anything, then we are admin
    return Elections.find().count() > 0 || Groups.find().count() > 0
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
  superuserExists: () ->
    return Meteor.users.findOne({username: "devAdmin"})

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
  "click .admin-logout": (e) ->
    e.preventDefault()
    Meteor.logout(() ->
      window.location = "http://accounts.google.com/logout"
    )
  "click #delete-super-user": (e) ->
    e.preventDefault()
    if confirm("This removes the superuser account to which the password " +
      "is public (whch is a security threat). " +
      "This must be done before the app goes live but make " +
      "sure you have added yourself to the global admins list first. " +
      "instructions can be found at: https://github.com/hackAD/nyu-vote"
    )
      Meteor.call("deleteSuperuser")
