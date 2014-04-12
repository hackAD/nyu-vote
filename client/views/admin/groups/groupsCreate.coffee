Template.groupsCreate.events
  "click .new.submitGroup": (e) ->
    name = $(".new.group.name").val()
    description = $(".new.group.description").val()
    admins = (admin for admin in $(".new.group.admins").val().split("\n") when admin != "")
    netIds = (netId for netId in $(".new.group.netids").val().split("\n") when netId != "")
    Meteor.call("addGroup", name, description, admins, netIds)
    Session.set("creatingGroup", "0")