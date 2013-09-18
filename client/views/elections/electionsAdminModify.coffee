Template.electionsAdminModify.helpers
  allowAbstain: () ->
    if this.options.allowAbstain then return "checked" else return ""
  multi: () ->
    if this.options.multi then return "checked" else return ""
  groups: () ->
    return Groups.find({_id:{$in:this.groups}})