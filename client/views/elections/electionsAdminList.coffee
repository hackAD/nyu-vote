Template.electionsAdminList.helpers
  elections: () ->
    return Elections.find()

Template.electionsAdminList.events
  "click .modifyElection": (e) ->
    e.preventDefault()
    Session.set("modifying", this._id)
