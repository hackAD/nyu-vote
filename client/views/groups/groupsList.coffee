Template.groupsList.helpers
  groups: () ->
    Groups.find()
  notModifying: () ->
    return Session.get("modifyingGroup") != this._id
  creating: () ->
    return Session.get("creatingGroup") == "1"

Template.groupsList.events
  "click .modifyGroup": (e) ->
    e.preventDefault()
    Session.set("modifyingGroup", this._id)
  "click .createGroup": (e) ->
    e.preventDefault()
    Session.set("creatingGroup", "1")