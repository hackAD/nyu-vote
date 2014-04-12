Template.admin.helpers
  "electionsCount": () ->
    return Elections.find().count()
  "groupsCount": () ->
    return Groups.find().count()
  "isAdmin": () ->
    return Groups.find().count() > 0
  "electionsReady": () ->
    Session.get("adminReady")
    return adminElectionsHandle?.ready()

Template.admin.created = () ->
  setTimeout(() ->
    Session.set("adminReady", 1)
  , 200)
  setTimeout(() ->
    Session.set("adminReady", 0)
  , 400)
