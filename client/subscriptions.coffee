root = global ? window
Deps.autorun(() ->
  root.usersHandle = Meteor.subscribe("userData")
  if /admin/.test(Router.current()?.route.name)
    root.adminElectionsHandle = Meteor.subscribe("adminElections")
    root.adminGroupsHandle = Meteor.subscribe("adminGroups")
    root.adminWhitelistHandle = Meteor.subscribe("adminWhitelist")
    Deps.autorun(() ->
      user = Meteor.user()
      if user?.isGlobalAdmin()
        root.globalAdminElectionsHandle = Meteor.subscribe("globalAdminElections")
        root.globalAdminGroupsHandle = Meteor.subscribe("globalAdminGroups")
    )
  else
    root.electionsHandle = Meteor.subscribe("voterElections")
    root.ballotsHandle = Meteor.subscribe("voterBallots")
)
