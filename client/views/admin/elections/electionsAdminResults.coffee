getQuestion = (questionId) ->
  election = Election.getActive()
  for i in [0...election.questions.length]
    if election.questions[i]._id == questionId
      return election.questions[i]

calculateRank = () =>
  election = Election.getActive()
  Meteor.call("getRankResults", election._id, (error, result) ->
    election.set("rankResults", result)
    election.set("rankResultsTimestamp", Date().toString())
  )

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
    rankResults = election.get("rankResults")
    if not rankResults
      calculateRank()
  getRankTime: () ->
    election = Election.getActive()
    return election.get("rankResultsTimestamp")
  getRankResults: (choiceId, questionId) ->
    election = Election.getActive()
    # get results
    rankResults = election.get("rankResults")
    # if we don't already have them, calculate them
    # and generate loading information
    if not rankResults
      return ([{
          round: 0
          votesNumber: "Loading"
        }])
    #if there are no ballots, or in these ballots
    #no one answered this question then just output 0 votes
    else if rankResults == {} or rankResults[questionId] == []
      return ([{
          round: 1
          votesNumber: 0
        }])
    else
      information = []
      for i in [0...rankResults[questionId].length]
        roundInfo = {
          round: i+1,
          votesNumber: rankResults[questionId][i][choiceId]
        }
        information.push(roundInfo)
      return information
