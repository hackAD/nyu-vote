Template.electionsAdminList.helpers
  elections: () ->
    return Elections.find()
  groups: () ->
    return Groups.find({_id:{$in:this.groups}})
  notModifying: () ->
    return Session.get("modifying") != this._id
  openCloseElection: () ->
    if this.status == "open" then return "Close" else return "Open"
  allowAbstain: () ->
    if this.options.allowAbstain then return "Allow" else return "Forbid"
  multi: () ->
    if this.options.multi then return "Multiple" else return "Single"

Template.electionsAdminList.events
  "click .modifyElection": (e) ->
    e.preventDefault()
    Session.set("modifying", this._id)