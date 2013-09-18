Template.groupsModify.helpers
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

Template.groupsModify.events
  "click .submitGroup": (e) ->
    name = $(".group.name").val()
    description = $(".group.description").val()
    admins = (admin for admin in $(".group.admins").val().split("\n") when admin != "")
    netIds = (netId for netId in $(".group.netids").val().split("\n") when netId != "")
    Groups.update(
      {_id: this._id}
      $set:
        name: name
        description: description
        admins: admins
        netIds: netIds
    )