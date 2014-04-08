root = global ? window
Deps.autorun(() ->
  if Router.current()?.route.name == "admin"
    root.adminElectionsHandle = Meteor.subscribe("adminElections")
    Meteor.subscribe("adminGroups")
  else
    root.electionHandle = Meteor.subscribe("Elections")
)
