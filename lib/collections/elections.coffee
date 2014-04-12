root = global ? window

root.Elections = new Meteor.Collection("elections")

class Election extends ReactiveClass(Elections)
  constructor: (fields) ->
    _.extends(@, fields)
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

root.createQuestion = (name, description, election_id, options = {}) ->
  console.log("calling createQuestion")
  options ?= {}
  options.multi ?= true
  options.allowAbstain ?= true
  id = new Meteor.Collection.ObjectID()
  id = id.toHexString()
  console.log("Finished init")
  Elections.update(
    {_id: election_id},
    $push:
      questions:
        _id: id
        name: name
        description: description
        options:
          multi: options.multi
          allowAbstain: options.allowAbstain
        choices: []
  )
  console.log("pushed update")
  return id

root.createChoice = (name, description="", question_id, image="") ->
  id = new Meteor.Collection.ObjectID()
  id = id.toHexString()
  Elections.update(
    {"questions._id": question_id},
    $push:
      "questions.$.choices":
        _id: id
        name: name
        description: description
        image: image
        votes: []
      )
  return id

Meteor.methods(
  createQuestion: (name, description, election_id, options = {}) ->
    return root.createQuestion(name, description, election_id, options)
  createChoice: (name, description="", question_id, image="") ->
    return root.createChoice(name, description, question_id, image)
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
      ,
      (err, resp) -> throw new Metor.Error(500, err.reason) if err?
    )
    return true
)
