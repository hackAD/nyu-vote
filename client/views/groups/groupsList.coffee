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

  "click .deleteGroup": (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to delete group '" + this.name + "'?")
      Groups.remove({_id: this._id})

  "click .cancelModifyGroup": (e) ->
    console.log("cancel class")
    e.preventDefault()
    Session.set("modifyingGroup", "0")
