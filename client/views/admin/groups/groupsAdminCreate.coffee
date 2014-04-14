Template.groupsAdminCreate.events
  "click .new.submitGroup": (e) ->
    e.preventDefault()
    name = $(".new.group.name").val()
    description = $(".new.group.description").val()
    admins = (admin for admin in $(".new.group.admins").val().split("\n") when admin != "")
    netIds = (netId for netId in $(".new.group.netids").val().split("\n") when netId != "")
    group = Group.create({
      name: name
      description: description
      admins: admins
      netIds: netIds
    }, (err) ->
      if not err
        group.refresh()
        Router.go("adminGroupsShow", {slug: group.slug})
      else
        Meteor.userError.throwError(500, err.message)
    )
