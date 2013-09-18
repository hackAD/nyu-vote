Template.electionsAdminModify.helpers
  allowAbstain: () ->
    if this.options.allowAbstain then return "checked" else return ""
  multi: () ->
    if this.options.multi then return "checked" else return ""
  groups: () ->
    return Groups.find({_id:{$in:this.groups}})

Template.electionsAdminModify.events
  "click .submitElection": (e) ->
    name = $(".election.name").val()
    description = $(".election.description").val()
    Session.set("modifyingElection", "0")