Deps.autorun(() ->
  if Meteor.Router.page() == "admin"
    Meteor.subscribe("adminElections")
    Meteor.subscribe("adminGroups")
  else
    Meteor.subscribe("Elections")
)
