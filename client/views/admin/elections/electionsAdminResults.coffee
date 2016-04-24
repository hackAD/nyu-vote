Template.electionsAdminResults.helpers
  election: () ->
    election = Election.getActive()
    return election
  canEdit: () ->
    this.status == "unopened" && this.hasAdmin(Meteor.user())
  isPick: (choiceId, questionId) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
        if election.questions[i]._id == questionId
            question = election.questions[i]
    return question.options.type == "pick"
  isRank: (choiceId, questionId) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
        if election.questions[i]._id == questionId
            question = election.questions[i]
    return question.options.type == "rank"
  choiceLength: (choiceId, questionId, votes) ->
    election = Election.getActive()
    for i in [0...election.questions.length]
        if election.questions[i]._id == questionId
            question = election.questions[i]
    ranks = []
    for i in [1...question.choices.length+1]
        object = {}
        object["rank"] = i
        object["questionId"] = questionId
        object["choiceId"] = choiceId
        object["votesObject"] = votes
        ranks.push(object)
    return ranks
  votes: (choiceId, questionId, votes, rank) ->
    if choiceId == "abstain"
        return votes[questionId][choiceId]
    return votes[questionId][choiceId][rank]
  allowAbstain: () ->
    return @options.allowAbstain
