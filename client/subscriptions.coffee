root = global ? window
Deps.autorun(() ->
  root.usersHandle = Meteor.subscribe("userData")
  if Router.current()?.route.name == "admin"
    root.adminElectionsHandle = Meteor.subscribe("adminElections")
    Meteor.subscribe("adminGroups")
  else
    root.electionsHandle = Meteor.subscribe("voterElections")
    root.ballotsHandle = Meteor.subscribe("voterBallots")
)
