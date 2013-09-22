Template.electionsAdminList.helpers
  elections: () ->
    return Elections.find()
  groups: () ->
    return Groups.find({_id:{$in:this.groups}})
  notModifying: () ->
    return Session.get("modifyingElection") != this._id
  openCloseElection: () ->
    if this.status == "open" then return "Close" else return "Open"
  openCloseClass: () ->
    if this.status == "open" then return "btn-warning" else return "btn-success"
  allowAbstain: () ->
    if this.options.allowAbstain then return "Allows" else return "Forbids"
  abstainTextClass: () ->
    if this.options.allowAbstain then return "text-success" else return "text-warning"
  multi: () ->
    if this.options.multi then return "Multiple" else return "Single"
  multiTextClass: () ->
    if this.options.multi then return "text-success" else return "text-warning"
  voteCountTotal: () ->
    return this?.voters?.length
  voteCountQuestion: () ->
    total = []
    if this?.choices?.length > 0
      for choice in this.choices
        total = _.union(total, choice.votes)
    return total.length
  voteCountChoice: () ->
    return this?.votes?.length


Template.electionsAdminList.events
  "click .modifyElection": (e) ->
    e.preventDefault()
    Session.set("modifyingElection", this._id)
  "click .deleteElection": (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to delete election '" + this.name + "'?")
      Elections.remove({_id: this._id})
  "click .openCloseElection": (e) ->
    e.preventDefault()
    if this.status == "open"
      status = "closed"
    else
      status = "open"
    Elections.update(
      {_id:this._id}
      $set:
        status: status
    )
  "submit #newElection": (e) ->
    e.preventDefault()
    name = $("#electionName").val()
    description = $("#electionDescription").val()
    Meteor.call("createElection", name, description, [], (err, resp) ->
      if (err)
        Meteor.userError.throwError(err.reason)
      else
        $("#electionName").val("")
        $("#electionDescription").val("")
    )
