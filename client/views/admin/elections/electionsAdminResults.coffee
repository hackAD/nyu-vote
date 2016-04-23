Template.electionsAdminResults.helpers
  election: () ->
    election = Election.getActive()
    return election
  canEdit: () ->
    this.status == "unopened" && this.hasAdmin(Meteor.user())
  votes: (choiceId, questionId, votes) ->
  	console.log(JSON.stringify(votes));
    return votes[questionId][choiceId]
  allowAbstain: () ->
    return @options.allowAbstain
