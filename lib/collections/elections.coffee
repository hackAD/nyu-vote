root = global ? window
root.Elections = new Meteor.Collection("elections")

root.electionRule = (userId, doc) ->
  if Meteor.isServer
    return Meteor.call("isGroupAdminOf", _.map(Groups.find({_id: {$in: doc.groups }}).fetch(), (group) -> group._id))
  else
    return true

root.Elections.allow(
  update: root.electionRule
  remove: root.electionRule
)

root.Elections.deny(
  update: (userId, doc, fieldNames) ->
    return 'questions.choices.votes' in fieldNames or 'voters' in fieldNames or 'creator' in fieldNames
)

root.createQuestion = (name, description, election_id, {multi=true, required=false}) ->
  id = new Meteor.Collection.ObjectID()
  id = id.toHexString()
  Elections.update(
    {_id: election_id},
    $push:
      questions:
        _id: id
        name: name
        description: description
        options:
          multi: multi
          required: required
        choices: []
  )
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
  vote: (election_id, choice_ids) ->
    if Meteor.isServer and !Meteor.call("hasNotVoted", election_id)
      throw new Meteor.Error(500, "Error: Has already voted!")
    if typeof(choice_ids) == "string"
      choice_ids = [choice_ids]
    election = Elections.findOne(election_id)
    for question in elections.questions
      matched_choices = (choice for choice in question.choices when choice._id in choice_ids)
      if question.options.required
        if question.options.multi && matched_choices.length == 0
          throw new Meteor.Error(500, "Error: At least one choice must be voted on!")
        if !question.options.multi && matched_choices.length != 1
          throw new Meteor.Error(500, "Error: Exactly one choice must be voted on!")
      else
        if !question.options.multi && matched_choices.length > 1
          throw new Meteor.Error(500, "Error: You cannot vote on more than one choice!")
      votes.push(Meteor.user().profile.netId) for votes in matched_choices.votes
    Elections.update(
      {_id: election_id}
      $set:
        questions: questions
      $push:
        voters: Meteor.user().profile.netId
    )
    return true

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