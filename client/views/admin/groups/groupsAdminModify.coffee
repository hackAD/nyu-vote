Template.groupsAdminEdit.helpers
  group: () ->
    return Group.getActive()
  netIds: () ->
    str = ""
    for netId in this.netIds
      str+=netId+"\n"
    return str
  admins: () ->
    str = ""
    for netId in this.admins
      str+=netId+"\n"
    return str

Template.groupsAdminEdit.events
  "click .save-group": (e) ->
    e.preventDefault()
    group = Group.getActive()
    name = $(".group.name").val()
    description = $(".group.description").val()
    admins = (admin for admin in $(".group.admins").val().split("\n") when admin != "")
    netIds = (netId for netId in $(".group.netids").val().split("\n") when netId != "")
    group.name = name
    group.description = description
    group.admins = admins
    group.netIds = netIds
    group.update((err) ->
      if not err
        group.refresh()
        Router.go("adminGroupsShow", {slug: group.slug})
      else
        Meteor.userError.throwError(500, err.message)
    )

  "click .delete-group": (e) ->
    if confirm("Are you sure you want to delete this group?")
      group = Group.getActive()
      group.remove()
      Router.go("admin")
