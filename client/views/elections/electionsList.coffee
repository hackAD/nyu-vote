Template.electionsList.helpers
  electionItems: () ->
    return Elections.find()

Template.electionsList.events
  "click #login": (e) ->
    e.preventDefault()
    Meteor.loginWithGoogleApps
      requestPermissions: ["email"]
      requestOfflineToken: true,
  "click .choice": (e) ->
    e.preventDefault()
    target = $(e.target)
    if target.hasClass("choice")
      target.toggleClass("chosen")
    else
      target.parent().toggleClass("chosen")
  "click .vote": (e) ->
    e.preventDefault()
    election_id = this._id
    choices = $(e.target).parent()
      .children(".chosen").map(() -> $(this).attr("data-id")).toArray()
    Meteor.call("vote", election_id, choices, (err, resp) ->
      if (err)
        Meteor.userError.throwError(err.reason)
      console.log resp)
