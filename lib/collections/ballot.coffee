root = global ? window

root.Ballots = new Meteor.Collection("ballots")

class Ballot extends ReactiveClass(Ballots)
  ballotCache = {}
  constructor: (fields) ->
    _.extend(@, fields)
    Ballot.initialize.call(@)
    if not @election
      @election = Election.fetchOne(@electionId)

  # Validates the entire Ballot
  isValid: () ->
    for i in [0...@questions.length]
      if not @validate(i)
        return false
    return true

  # Validates a specific question on the ballot
  validate: (questionIndex) ->
    question = @election.questions[questionIndex]
    # TODO: implemenent validation for rankings
    if question.options.allowAbstain && @isAbstaining(questionIndex)
      return true
    choices = question.choices
    selectedChoices = @selectedChoices(questionIndex, true)
    if (selectedChoices.length == 0)
      return false

    if Meteor.isServer
      # checks all IDs on the choices are unique
      allChoicesUnique = _.reduce(selectedChoices, (seen, selectedChoice) ->
        if selectedChoice._id not in seen
          seen.push(selectedChoice._id)
        return seen
      , []).length == selectedChoices.length
      if not allChoicesUnique
        return false

      # checks all IDs on the choices match real IDs
      allChoicesValid = _.filter(selectedChoices, (selectedChoice) ->
        return _.find(choices, (choice) ->
          return selectedChoice._id == choice._id
        )
      ).length == selectedChoices.length
      if not allChoicesValid
        return false

    if (question.options.allowAbstain && @isAbstaining(questionIndex))
          return selectedChoices.length == 1
    if (question.options.type == "pick")
      if (question.options.voteMode == "multi")
        return selectedChoices.length > 0
      else if (question.options.voteMode == "pickN")
        return selectedChoices.length == question.options.pickNVal
      else
        return selectedChoices.length == 1

    else if (question.options.type == "rank")
      allRanksUnique = _.reduce(selectedChoices, (seen, selectedChoice) ->
          if selectedChoice.value not in seen
            seen.push(selectedChoice.value)
          return seen
        , []).length == selectedChoices.length

      if not allRanksUnique
        return false

      forceFullRanking = question.options.forceFullRanking
      if not forceFullRanking
        for i in [1...selectedChoices.length+1]
          flag = false
          for j in [0...selectedChoices.length]
            if selectedChoices[j].value == i
              flag = true
              break
          if not flag
            return false
        return true

      else
        # If all other choices but No Confidence have been picked validate the ballot so you
        # don't need to redundantly rank no confidence as the last one.
        # Of course we could always just validate when all but one have been ranked as the last one
        # is always redundant as there is only 1 possibility for the rank and by instant-runoff-voting
        # your vote will never go to the last person on your ballot. But it would feel weirder if you
        # didn't have to rank the last candidate instead of not ranking No Confidence.
        if question.options.includeNoConfidence && selectedChoices.length == question.choices.length-1
          noConfidenceSelected = true
          ballotValid = true;
          for choice in selectedChoices
            if choice.name == "No Confidence"
              noConfidenceSelected = false
              break
            if not (choice.value in [1...question.choices.length])
              ballotValid = false
              break
          if ballotValid && noConfidenceSelected
            return true

        # Else since we already have code in place that assures correct boundaries on choice values
        # and that they are all unique, we just need to check they have ranked everyone and it must be valid
        return selectedChoices.length == question.choices.length


    Log.error("validation logic failed, election: " + JSON.stringify(@election) +
      " ballot: " + JSON.stringify(@))
    return false

  selectedChoices: (questionIndex, returnBallots) ->
    question = @questions[questionIndex];
    # if we are abstaining, just return the abstain object
    if @isAbstaining(questionIndex)
      choices = question.choices
      if returnBallots
        return [{
          _id: "abstain"
          value: true
        }]
      else
        return [{
          _id: "abstain"
          name: "Abstain"
          description: "Abstain from this vote"
          image: ""
        }]
    if questionIndex > @questions.length - 1
      throw new Meteor.Error(500, questionIndex + " is out of bounds")
    array = if returnBallots then question.choices else
      @election.questions[questionIndex].choices
    selected = _.filter(array, (choice, index) =>
      ballotChoice = question.choices[index]
      return ballotChoice.value > 0
    )
    return selected

  getElection: () ->
    Election.fetchOne(@electionId)

  isPicked: (questionIndex, choiceIndex) ->
    @depend()
    choice = @questions[questionIndex].choices[choiceIndex]
    question = @questions[questionIndex]
    return choice.value > 0

  # toggling a pick on a choice
  pick: (questionIndex, choiceIndex, priority = null) ->
    @changed()
    question = @questions[questionIndex]
    choice = question.choices[choiceIndex]
    if priority == null
      # if no priority, we are in pick mode
      choice.value = !choice.value
    else
      choice.value = priority
    newValue = choice.value
    # If they just selected a choice
    if question.options.type == "pick" and newValue == true
      # If it is not multiple choice, or they picked abstain, make sure all
      # other choices are false
      if (question.options.voteMode == "single") || choice._id == "abstain"
        _.each(question.choices, (choice, index) ->
          if index != choiceIndex
            choice.value = false
        )
      else if (choice._id != "abstain") && @isAbstaining(questionIndex)
        _.find(question.choices, (choice, index) ->
          if choice._id == "abstain"
            choice.value = false
        )
    else if question.options.type == "rank" && @isAbstaining(questionIndex) && choice._id != "abstain"
      _.find(question.choices, (choice, index) ->
        if choice._id == "abstain"
          choice.value = false
        )

    return @

  abstain: (questionIndex) ->
    @changed()
    question = @questions[questionIndex]
    if (question.options.type == "pick")
      # set all choice values to false
      _.each(question.choices, (choice) ->
        choice.value = false
      )
      abstainChoice = question.choices[question.choices.length - 1]
      abstainChoice.value = true
    else if (question.options.type == "rank")
      _.each(question.choices, (choice) ->
        choice.value = 0
      )
      abstainChoice = question.choices[question.choices.length - 1]
      abstainChoice.value = true
    return @

  unAbstain: (questionIndex) ->
    @changed()
    question = @questions[questionIndex]
    if not question.options.allowAbstain
      return false
    abstainChoice = question.choices[question.choices.length - 1]
    abstainChoice.value = false
    return @

  isAbstaining: (questionIndex) ->
    ballotQuestion = @questions[questionIndex]
    electionQuestion = @election.questions[questionIndex]
    if not electionQuestion.options.allowAbstain
      return false
    abstainChoice = ballotQuestion.choices[ballotQuestion.choices.length - 1]
    @depend()
    return abstainChoice.value

  toString: () ->
    return "NetId: " + @netId + ", electionId: " + @electionId +
      ", data: " + JSON.stringify(@questions)

  @generateBallot = (election, user) ->
    if not election
      throw new Meteor.Error(500,
        "Cannot generate a ballot omit an election"
      )
    user ?= Meteor.user()
    if not user
      throw new Meteor.Error(500,
        "You must specify a user in order to generate a ballot!")
    ballot = new this({
      election: election,
      electionId: election._id,
      netId: user.getNetId(),
      questions: _.map(election.questions, (question) ->
        transformedQuestion = _.omit(question,
          "description", "name", "choices")
        # Transform each choice
        transformedQuestion.choices = _.map(question.choices, (choice, index) ->
          transformedChoice = _.omit(choice,
            "description", "image", "name", "votes")
          transformedChoice.value = switch (question.options.type)
            when "pick" then false
            when "rank" then 0
            else false
          return transformedChoice
        )
        if (transformedQuestion.options.allowAbstain)
          transformedQuestion.choices.push({
            name: "abstain"
            _id: "abstain"
            value: false
          })
        return transformedQuestion
      )
    })
    return ballot

  # Singleton to return a ballot if it exists, or create a new one if it
  # doesn't
  @getBallot = (election) ->
    if not election
      throw new Meteor.Error(500,
        "You must specify the election of the ballot you want")
    if ballotCache[election._id]
      return ballotCache[election._id]
    else
      ballotCache[election._id] = @generateBallot(election, Meteor.user())
      return ballotCache[election._id]

  # Stateful tracking of what the active ballot is
  activeBallotDep = new Deps.Dependency
  activeBallot = undefined
  @setActive = (election) ->
    if activeBallot?.electionId == election._id
      return @
    activeBallotDep.changed()
    activeBallot = @getBallot(election)
    return @

  # Reactively fetch the active ballot
  @getActive = () ->
    activeBallotDep.depend()
    if activeBallot
      activeBallot.depend()
    return activeBallot

Ballot.setupTransform()

Ballot.addOfflineFields(["election"])

# Ballots must match the user that is submitting them, and have the right
# fields
Ballots.allow(
  insert: (userId, ballot) ->
    if not ballot.netId || not ballot.electionId || not ballot.questions
      return false
    if not userId
      if (Meteor.isServer)
        Log.warn("Someone tried to cast a ballot without being logged in" +
          "Ballot: " + JSON.stringify(ballot))
      return false
    user = User.fetchOne(userId)
    if not user || not user.profile.netId
      return false
    if (Meteor.isServer)
      election = Election.fetchOne(ballot.electionId)
      commonGroup = Groups.findOne({
        _id: {$in: election.groups},
        netIds: user.getNetId()
      })
      if not commonGroup
        Log.warn(user + " tried to vote without being in the election" +
          " groups. Ballot: " + JSON.stringify(ballot))
        return false
    if not ballot.netId == user.profile.netId
      if (Meteor.isServer)
        Log.warn(user + " tried to vote on behalf of " + ballot.netId +
          "Ballot: " + JSON.stringify(ballot))
      return false
    return ballot.isValid()
)

# Ballots can be denied for not being unique or for the election not being
# open. They alsso cannot be updated or removed
Ballots.deny(
  insert: (userId, ballot) ->
    if (Meteor.isServer)
      election = Election.fetchOne(ballot.electionId)
      user = User.fetchOne(userId)
      if election.status != "open"
        Log.warn(user + " tried to cast a ballot for election that's" +
          " not open. Ballot: " + JSON.stringify(ballot))
        return true
      if Ballots.find({
        netId: ballot.netId,
        electionId: ballot.electionId
      }).count() > 0
        Log.warn(user + " tried to cast a repeat ballot. Ballot: " +
          JSON.stringify(ballot))
        return true
    return false
  update: () ->
    return true
  remove: () ->
    return true
)

# Prevent redundant data from getting duplicated into the DB
Ballots.before.insert((userId, ballot) ->
  for question in ballot.questions
    delete question.options
    for choice in question.choices
      delete choice.name
)

# After a ballot is inserted, we need to increment all the voted regions of
# the ballot
Ballots.after.insert((userId, ballot) ->
  if (Meteor.isClient)
    return
  user = User.fetchOne(userId)
  toIncrement = {}
  for i in [0...ballot.questions.length]
    question = ballot.questions[i]
    if question?.options?.type != "pick"
      continue
    choices = @transform().selectedChoices(i)
    _.each(choices, (choice) ->
      toIncrement["votes." + question._id + "." + choice._id] = 1
    )
  Elections.update(ballot.electionId, {
    "$inc": toIncrement
  })
  Log.verbose("BALLOT CAST: " + user + " cast ballot. Ballot: " +
    JSON.stringify(ballot))
)


# After it is inserted
root.Ballot = Ballot
