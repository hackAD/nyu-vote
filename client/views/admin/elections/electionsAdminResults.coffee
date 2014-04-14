Template.electionsAdminResults.helpers
  election: () ->
    election = Election.getActive()
    return election
  canEdit: () ->
    this.status == "unopened" && this.hasAdmin(Meteor.user())
  votes: (choiceId, questionId, votes) ->
    return votes[questionId][choiceId]

Template.electionsAdminResults.events
  "click .delete-election": (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to delete this election?")
      election = Election.getActive()
      election.remove()
      Router.go("admin")
