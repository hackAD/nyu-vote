root = global ? window

root.Ballots = new Meteor.Collection("ballots")

class Ballot extends ReactiveClass(Ballots)
  ballotCache = {}
  constructor: (fields) ->
    _.extend(@, fields)
    Ballot.initialize.call(@)

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
      console.log(transformedQuestion)
      # Transform each choice
      transformedQuestion.choices = _.map(question.choices, (choice, index) ->
        transformedChoice = _.omit(choice,
          "description", "image", "name", "votes")
        transformedChoice.value = switch (question.options.type)
          when "pick" then {
            selected: "no"
          }
          when "rank" then {
            rank: 0
          }
          else {
            selected: "no"
          }
        return transformedChoice
      )
      if (transformedQuestion.options.allowAbstain)
        transformedChoice.push({
          name: "abstain"
          _id: "abstain"
          value: "true"
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
    if activeBallot.electionId == election._id
      return @
    activeBallotDep.changed()
    activeBallot = @getBallot(election)
    Election.setActive(election.slug)
    return @

  @getActive = () ->
    activeBallotDep.depend()
    return activeBallot

Ballot.setupTransform()

root.Ballot = Ballot
