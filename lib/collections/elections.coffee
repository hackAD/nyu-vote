root = global ? window
class Election
  self = @

  constructor: (params) ->
    _.extend(@, params)

  # static methods

  @create: (params) ->
    id = Elections.insert(params)
    return self.findOne(id)

  @findOne: (id) ->
    election = Object.create(Election)
    Deps.autorun () ->
      _.extend(election, Elections.findOne(id))
    if _.isEmpty(election)
      throw new Meteor.Error(404, "Election with _id #{id} not found")
    return election

  hasVoted: () ->
    return !@.questions?

root.Election = Election

root.Elections = new Meteor.Collection("elections",
  transform: (doc) ->
    return new Election(doc)
)

root.electionRule = (userId, doc, fieldNames, modifier) ->
  if Meteor.isServer
    groupModifier = ([operation,operand.groups["$each"]] for operation, operand of modifier when "groups" of operand) 
    groupModifier = groupModifier[0]
    if groupModifier == [] then groupModifier = ["",[]]
    return Meteor.call("isGroupAdminOf", groupModifier[1]) and (groupModifier[0]=="$addToSet" or "groups" not in fieldNames)
  else
    return true

root.electionRule2 = (userId, doc, fieldNames, modifier) ->
  if Meteor.isServer
    return Meteor.call("isInGroupAdminsOf", doc.groups)
  else
    return true

root.electionRule3 = (userId, doc, fieldNames, modifier) ->
  if Meteor.isServer
    return Meteor.call("isCreatorOf", doc.creator)
  else
    return true

root.Elections.allow(
  update: root.electionRule2
  remove: root.electionRule2
)

root.Elections.allow(
  update: root.electionRule3
  remove: root.electionRule3
)

root.Elections.deny(
  update: (userId, doc, fieldNames, modifier) ->
    console.log(fieldNames, modifier)
    console.log 'questions.choices.votes' in fieldNames or 'voters' in fieldNames or 'creator' in fieldNames
    return 'questions.choices.votes' in fieldNames or 'voters' in fieldNames or 'creator' in fieldNames
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
