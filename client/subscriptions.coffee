root = global ? window
Deps.autorun(() ->
  root.usersHandle = Meteor.subscribe("userData")
  if /admin/.test(Router.current()?.route.name)
    root.adminElectionsHandle = Meteor.subscribe("adminElections")
    root.adminGroupsHandle = Meteor.subscribe("adminGroups")
    root.adminWhitelistHandle = Meteor.subscribe("adminWhitelist")
  else
    root.electionsHandle = Meteor.subscribe("voterElections")
    root.ballotsHandle = Meteor.subscribe("voterBallots")
)
