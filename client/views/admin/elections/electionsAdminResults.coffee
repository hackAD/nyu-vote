Template.electionsAdminResults.helpers
  election: () ->
    election = Election.getActive()
    return election
  canEdit: () ->
    this.status == "unopened" && this.hasAdmin(Meteor.user())
  votes: (choiceId, questionId, votes) ->
    return votes[questionId][choiceId]
  allowAbstain: () ->
    return @options.allowAbstain
  getQuestion: (questionId) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
      if election.questions[i]._id == questionId
        return election.questions[i]
  isRank: (questionId) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
      if election.questions[i]._id == questionId
        question = election.questions[i]
    return question.options.type == "rank"
  isPick: (questionId) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
      if election.questions[i]._id == questionId
        question = election.questions[i]
    return question.options.type == "pick"

  getRankResults: (questionId, calculate) ->
    console.log(JSON.stringify(questionId))
    if not calculate
      return @results    
    @roundNumber = 0
    election = Election.getActive()
    Meteor.call("getRankResults", election._id, questionId, (error, result) ->
      Session.set("rankResults", result)
    )
    @results = Session.get("rankResults")
    console.log("hi")
    return null
  getRankVotes: (choiceId) ->
    ret = @results[@roundNumber][choiceId]
    @roundNumber++
    return ret
  getRankRound: () ->
    return @roundNumber+1


