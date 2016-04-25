getQuestion = (questionId) ->
  election = Election.getActive()
  for i in [0...election.questions.length]
    if election.questions[i]._id == questionId
      return election.questions[i]
retrieveRankResults = () ->
  election = Election.getActive()
  Meteor.call("getRankResults", election._id, (error, result) ->
    election.set("rankResults", result)
  )
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
  getRankResults: (choiceId, questionId) ->
    election = Election.getActive()
    rankResults = election.get("rankResults")
    if not rankResults
      retrieveRankResults()
      if not choiceId
        return null
      rankResults = {}
      for questionObject in election.questions
        questionId = questionObject._id
        information = [{}]
        for choiceObject in questionObject.choices
          choiceId = choiceObject._id
          information[0][choiceId] = "Loading..."
        rankResults[questionId] = information
    
    information = []
    for i in [0...rankResults[questionId].length]
      roundInfo = {
        round: i+1,
        votesNumber: rankResults[questionId][i][choiceId]
      }
      information.push(roundInfo)
    return information


