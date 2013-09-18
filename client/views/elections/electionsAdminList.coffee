Template.electionsAdminList.helpers
  elections: () ->
    return Elections.find()
  groups: () ->
    return Groups.find({_id:{$in:this.groups}})
  notModifying: () ->
    return Session.get("modifyingElection") != this._id
  openCloseElection: () ->
    if this.status == "open" then return "Close" else return "Open"
  allowAbstain: () ->
    if this.options.allowAbstain then return "Allow" else return "Forbid"
  multi: () ->
    if this.options.multi then return "Multiple" else return "Single"
  voteCountTotal: () ->
    return this.voters.length
  voteCountQuestion: () ->
    count = 0
    if this.choices?.length > 0
      for choice in this.choices
        count += choice.votes.length
    return count
  voteCountChoice: () ->
    return this.votes.length


Template.electionsAdminList.events
  "click .modifyElection": (e) ->
    e.preventDefault()
    Session.set("modifyingElection", this._id)
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
