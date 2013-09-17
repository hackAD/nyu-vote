Template.electionsList.helpers
  electionItems: () ->
    return Elections.find()

Template.electionsList.events
  "click a": (e) ->
    e.preventDefault()
    console.log("working")
