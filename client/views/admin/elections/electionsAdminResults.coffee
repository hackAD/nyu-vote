getQuestion = (questionId) ->
  election = Election.getActive()
  for i in [0...election.questions.length]
    if election.questions[i]._id == questionId
      return election.questions[i]

calculateRank = () =>
  election = Election.getActive()
  ((id) ->
    Meteor.call("getRankResults", id, (error, result) ->
      Session.set("rankResults", {
        result: result,
        timestamp: Date().toString(),
        id: id
      })
    )
  )(election._id)

Template.electionsAdminResults.events
  "click #refresh-rank": (e) ->
    e.preventDefault()
    calculateRank()

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
  isRank: (questionId) ->
    question = getQuestion(questionId)
    return question.options.type == "rank"
  isPick: (questionId) ->
    question = getQuestion(questionId)
    return question.options.type == "pick"
  hasRank: () ->
    election = Election.getActive()
    for question in election.questions
      if question.options.type == "rank"
        return true
    return false
  retrieveRankResults: () ->
    election = Election.getActive()
    results = Session.get("rankResults")
    if not results or results.id != election._id
      calculateRank()
  getRankTime: () ->
    results = Session.get("rankResults")
    return results?.timestamp
  getRankResults: (choiceId, questionId) ->
    election = Election.getActive()
    results = Session.get("rankResults")
    # get results
    rankResults = results?.result
    # if we don't already have them, calculate them
    # and generate loading information
    if not rankResults
      return ([{
        round: 0
        votesNumber: "Loading"
      }])
    #if there are no ballots, or in these ballots
    #no one answered this question then just output 0 votes
    else if not rankResults[questionId]? or rankResults[questionId].length == 0
      return ([{
          round: 1
          votesNumber: 0
        }])

    else
      # get all the information
      information = []
      for i in [0...rankResults[questionId].length]
        roundInfo = {
          round: i+1,
          votesNumber: rankResults[questionId][i][choiceId]
        }
        information.push(roundInfo)
      return information
  getWinner: () ->
    questionId = @_id
    choices = @choices
    results = Session.get("rankResults")
    rankResults = results?.result
    if not rankResults
      return "Loading"
    else if not rankResults[questionId]?
      # This should be appropriate in this situation
      # as we assume we are displaying all 0 votes
      return "Tie"
    else
      # calculate winner
      questionResults = rankResults[questionId]
      lastRoundResults = questionResults[questionResults.length-1]
      winnerId = null
      winnerVotes = -1
      _.each(lastRoundResults, (votes, choiceId) ->
        if votes > winnerVotes
          winnerVotes = votes
          winnerId = choiceId
        else if votes == winnerVotes
          winnerId = "tie"
      )
      if winnerId == null
        throw new Meteor.Error(500, "didn't find a winner for unknown reasons")
      else if winnerId == "tie"
        return "Tie";
      else
        for choice in choices
          if choice._id == winnerId
            return choice.name
        throw new Meteor.Error(500, "Winner choice wasn't to be found in choices array")
