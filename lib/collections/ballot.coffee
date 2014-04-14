root = global ? window

root.Ballots = new Meteor.Collection("ballots")

class Ballot extends ReactiveClass(Ballots)
  ballotCache = {}
  constructor: (fields) ->
    _.extend(@, fields)
    Ballot.initialize.call(@)

  # Validates the entire Ballot
  isValid: () ->
    for i in [0...@questions.length]
      if not @validate(i)
        return false
    return true

  # Validates a specific question on the ballot
  validate: (questionIndex) ->
    valid = false
    question = @questions[questionIndex]
    # TODO: implemenent validation for rankings
    if (question.options.type == "pick")
      choices = question.choices
      selectedChoices = @selectedChoices(questionIndex, true)
      if (question.options.multi)
        if (question.options.allowAbstain && @isAbstaining(questionIndex))
          valid = selectedChoices.length == 1
        else
          valid = selectedChoices.length > 0
      else
        valid = selectedChoices.length == 1
    return valid

  selectedChoices: (questionIndex, returnBallots) ->
    election = @getElection()
    # if we are abstaining, just return the abstain object
    if @isAbstaining(questionIndex)
      choices = @questions[questionIndex].choices
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
    array = if returnBallots then @questions[questionIndex].choices else
      election.questions[questionIndex].choices
    selected = _.filter(array, (choice, index) =>
      ballotChoice = @questions[questionIndex].choices[index]
      return ballotChoice.value == true
    )
    return selected

  getElection: () ->
    Election.fetchOne(@electionId)

  # For pick mode
  isPicked: (questionIndex, choiceIndex) ->
    @depend()
    choice = @questions[questionIndex].choices[choiceIndex]
    return choice.value == true

  # toggling a pick on a choice
  pick: (questionIndex, choiceIndex) ->
    @changed()
    question = @questions[questionIndex]
    choice = question.choices[choiceIndex]
    choice.value = !choice.value
    newValue = choice.value
    # Changes if they just selected a choice
    if newValue == true
      # If it is not multiple choice, make sure all other choices are false
      if (!question.options.multi)
        _.each(question.choices, (choice, index) ->
          if index != choiceIndex
            choice.value = false
        )
      # Otherwise check if abstain is on, and if so, set it to false
      else if (question.options.allowAbstain)
        abstainChoice = question.choices[question.choices.length - 1]
        abstainChoice.value = false
    # Changes if they deselected a choice
    else
      if (question.options.allowAbstain)
        # If it's not multiple choice or nothing else is selected
        if (!question.options.multi || !_.find(question.choices, (choice) ->
          return choice.value == true
        ))
          abstainChoice = question.choices[question.choices.length - 1]
          abstainChoice.value = true
    return @

  abstain: (questionIndex) ->
    @changed()
    question = @questions[questionIndex]
    # TODO: implement rank abstain
    if (question.options.type == "pick")
      # set all choice values to false
      _.each(question.choices, (choice) ->
        choice.value = false
      )
      abstainChoice = question.choices[question.choices.length - 1]
      abstainChoice.value = true
    return @

  isAbstaining: (questionIndex) ->
    question = @questions[questionIndex]
    if not question.options.allowAbstain
      return false
    abstainChoice = question.choices[question.choices.length - 1]
    @depend()
    return abstainChoice.value

  @generateBallot = (election, user) ->
    if not election
      throw new Meteor.Error(500,
        "Cannot generate a ballot omit an election"
      )
    user ?= Meteor.user()
    if not user
      throw new Meteor.Error(500,
        "You must specify in a user to generate a ballot!")
    ballot = new this()
    ballot.netId = user.getNetId()
    ballot.electionId = election._id
    # Transform each question
    ballot.questions = _.map(election.questions, (question) ->
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
          value: true
        })
      return transformedQuestion
    )
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

Ballot.addOfflineFields(["random_map"])

# Ballots must match the user that is submitting them, and have the right
# fields
Ballots.allow(
  insert: (userId, ballot) ->
    if not ballot.netId || not ballot.electionId || not ballot.questions
      return false
    if not userId
      return false
    user = User.fetchOne(userId)
    if not user.profile.netId
      return false
    if not ballot.netId == user.profile.netId
      return false
    return ballot.isValid()
)

# Ballots can be denied for not being unique or for the election not being
# open. They alsso cannot be updated or removed
Ballots.deny(
  insert: (userId, ballot) ->
    election = Election.fetchOne(ballot.electionId)
    if (Meteor.isServer)
      if election.status != "open"
        return true
    if Ballots.find({
      netId: ballot.netId,
      electionId: ballot.electionId
    }).count() > 0
      return true
    return false
  update: () ->
    return true
  remove: () ->
    return true
)

# After a ballot is inserted, we need to incremenet all the voted regions of
# the ballot
Ballots.after.insert((userId, ballot) ->
  if (Meteor.isClient)
    return
  toIncrement = {}
  for i in [0...ballot.questions.length]
    question = ballot.questions[i]
    choices = @transform().selectedChoices(i)
    _.each(choices, (choice) ->
      toIncrement["votes." + question._id + "." + choice._id] = 1
    )
  Elections.update(ballot.electionId, {
    "$inc": toIncrement
  })
)


# After it is inserted
root.Ballot = Ballot
