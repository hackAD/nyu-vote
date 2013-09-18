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
    setTimeout(() -> 
      $(".modifyGroup").html("Cancel modification")
      $(".modifyGroup").attr("class", "cancelModifyGroup btn btn-primary")
    , 100)
    Session.set("modifyingGroup", this._id)

  "click .createGroup": (e) ->
    e.preventDefault()
    Session.set("creatingGroup", "1")

  "click .cancelModifyGroup": (e) ->
    console.log("cancel class")
    e.preventDefault()
    setTimeout(() -> 
      $(".cancelModifyGroup").html("Modify Group")
      $(".cancelModifyGroup").attr("class", "modifyGroup btn btn-primary") 
    , 100)
    Session.set("modifyingGroup", "0")