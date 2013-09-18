root = global ? window
Deps.autorun(() ->
  if Meteor.Router.page() == "admin"
    root.adminElectionsHandle = Meteor.subscribe("adminElections")
    Meteor.subscribe("adminGroups")
  else
    root.electionHandle = Meteor.subscribe("Elections")
)
