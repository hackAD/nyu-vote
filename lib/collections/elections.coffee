root = global ? window

root.Elections = new Meteor.Collection("elections")

class Election extends ReactiveClass(Elections)
  constructor: (fields) ->
    _.extend(@, fields)
    Election.initialize.call(@)

  hasAdmin: (user) ->
    # They could be a global admin
    if user.isGlobalAdmin()
      return true
    # They could be the creator
    if user.getNetId() == @creator
      return true
    # They can be the admin of any of the groups
    for group in @groups
      if group.hasAdmin(user)
        return true
    return false

  getBallot: (user) ->
    oldBallot = Ballot.fetch({netId: user.getNetId(), electionId: @_id})
    if oldBallot
      return oldBallot
    return generateBallot(user)

  hasVoted: (user) ->
    return Ballots.find({netId: user.getNetId(), electionId: @_id}).count() > 0

  addQuestion: ({name, description, options}) ->
    if (!name || name.length < 1)
      throw new Meteor.Error(500, "Questions must have a name")
    id = new Meteor.Collection.ObjectID().toHexString()
    description ?= ""
    options ?= {}
    options.type ?= "pick"
    if (options.type == "pick")
      options.multi ?= false
    options.allowAbstain ?= false
    @questions.push(
      _id: id
      name: name
      description: description
      options: options
      choices: []
    )
    return id
  
  addChoice: (questionId, {name, description, image}) ->
    if not questionId
      throw new Meteor.Error(500, "You must specify a question to add this choice to")
    if (!name || name.length < 1)
      throw new Meteor.Error(500, "Choices must have a name")

    id = new Meteor.Collection.ObjectID().toHexString()
    description ?= ""
    image ?= ""
    question = _.find(@questions, (question) ->
      return question._id == questionId
    )
    question.choices.push(
      _id: id
      name: name
      description: description
      image: image
      votes: 0
    )
    return id

  # Stateful tracking of the active election
  activeElectionDep = new Deps.Dependency
  activeElection = undefined
  @setActive = (newElectionSlug, adminMode) ->
    if activeElection.slug == newElectionSlug
      return @
    activeElectionDep.changed()
    activeElection = @fetchOne({slug: newElectionSlug})
    # if we are an admin, we don't want the ballot
    if not adminMode
      Ballot.setActiveBallot(activeElection)
    return @

  @getActive = () ->
    activeElectionDep.depend()
    return activeElection


Election.setupTransform()
# Promote it to the global scope
root.Election = Election

# We need to enforce slugs
Elections.before.insert((userId, doc) ->
  doc.slug = Utilities.generateSlug(doc.name, Elections)
  doc.status = "unopened"
)

Elections.after.update((userId, doc, fieldNames, modifier, options) ->
  if doc.name != @previous.name
    newSlug = Utilities.generateSlug(doc.name, Elections)
  Elections.update(doc._id, {
    $set: {slug: newSlug}
  })
)

# One can only create elections if they are on the whitelist. They are able to
# update and remove them however, if they are admins of the election
Elections.allow(
  insert: (userId, doc) ->
    user = User.fetchOne(userId)
    return user.isWhitelisted()
  update: (userId, doc, fieldNames, modifier) ->
    user = User.fetchOne(userId)
    return doc.hasAdmin(user)

  remove: (userId, doc) ->
    user = User.fetchOne(userId)
    return doc.hasAdmin(user)
)

# Elections are only mutable before an election. Also, no user can change the
# status, it must be done by the server
Elections.deny(
  update: (userId, doc, fieldNames) ->
    return (doc.status != "unopened" || "status" in fieldNames)
)

Elections.deny(
  update: (userId, doc, fieldNames, modifier) ->
    return 'creator' in fieldNames
)

Meteor.methods(
  createQuestion: (electionId, name, description, options = {}) ->
    election = Election.fetchOne(electionId)
    election.addQuestion(
      name: name
      description: description
      options: options
    )
    election.update()
  createChoice: (electionId, questionId, name, description="", image="") ->
    election = Election.fetchOne(electionId)
    election.addChoice(
      questionId: questionId
      name: name
      description: description
      image: image
    )
    election.update()
  vote: (election_id, choice_ids=[]) ->
    if Meteor.isServer and !Meteor.call("hasNotVoted", election_id)
      throw new Meteor.Error(500, "Error: Has already voted!")
    if typeof(choice_ids) == "string"
      choice_ids = [choice_ids]
    election = Elections.findOne(election_id)
    for question in election.questions
      matched_choices = (choice for choice in question.choices when choice._id in choice_ids)
      if !question.options?.allowAbstain
        if question.options?.multi && matched_choices.length == 0
          throw new Meteor.Error(500, "Error: At least one choice must be voted on!")
        if !question.options?.multi && matched_choices.length != 1
          throw new Meteor.Error(500, "Error: Exactly one choice must be voted on!")
      else
        if !question.options?.multi && matched_choices.length > 1
          throw new Meteor.Error(500, "Error: You cannot vote on more than one choice!")
      choice.votes.push(Meteor.user().profile.netId) for choice in matched_choices
    Elections.update(
      {_id: election_id}
      $set:
        questions: election.questions
      $push:
        voters: Meteor.user().profile.netId
    )

  createElection: (name, description="", group_ids = []) ->
    if typeof(group_ids) == "string"
      group_ids = [group_ids]
    if Meteor.isServer and !Meteor.call("isGroupAdminOf", group_ids)
      throw new Meteor.Error(500, "Error: Not a group admin!")
    Elections.insert(
      name: name
      description: description
      status: "closed"
      creator: Meteor.user().profile.netId
      groups: group_ids
      voters: []
      questions: []
      , (err, resp) -> throw new Metor.Error(500, err.reason) if err?
    )
    return true
)
