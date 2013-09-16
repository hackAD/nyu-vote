root = global ? window
root.Elections = new Meteor.Collection("elections")

root.electionRule = (userId, doc) ->
    if Meteor.isServer
        return Meteor.call("isGroupAdminOf", _.map(Groups.find({_id: {$in: doc.groups }}).fetch(), (o) -> o._id))
    else
        return true

root.Elections.allow(
    update: root.electionRule
    remove: root.electionRule
)

root.Elections.deny(
    update: (userId, doc, fieldNames) ->
        return 'choices.votes' in fieldNames or 'voters' in fieldNames or 'creator' in fieldNames
)

root.createQuestion = (name, description, election_id) ->
    id = new Meteor.Collection.ObjectID()
    id = id.toHexString()
    Elections.update(
        {_id: election_id},
        $push:
            questions:
                _id: id
                name: name
                descripton: description
                choices: []
    )
    return id

root.createChoice = (name, description, question_id, image="") ->
    id = new Meteor.Collection.ObjectID()
    id = id.toHexString()
    Elections.update(
        {"questions._id": question_id},
        $push:
            "questions.$.choices":
                _id: id
                name: name
                descripton: description
                image: image
                votes: []
    )
    return id

Meteor.methods(
    vote: (election_id, choice_ids) ->
        questions = Elections.findOne(election_id)
        increment(choice) for choice in choices in questions when choice._id in choice_ids
        increment = (choice) ->
            choice.votes.push(Meteor.user().profile.userId)
        Elections.update(
            {_id: election_id},
            $push:
                voters: Meteor.user().profile.userId
            $set:
                questions: questions
        )
        return true

    createElection: (name, description, group_ids = [], voting_style) ->
        if voting_style != "NYUAD" and voting_style != "NYU"
            throw new Meteor.Error(500, "Error: Voting style not recognised!")
        if typeof(group_ids) == "string"
            group_ids = [group_ids]
        if Meteor.isServer and !Meteor.call("isGroupAdminOf", group_ids)
            throw new Meteor.Error(500, "Error: Not a group admin!")
        Elections.insert(
            name: name
            descripton: description
            status: "closed"
            creator: Meteor.user().profile.netId
            groups: group_ids
            voters: []
            questions: []
            options:
                voting_style: voting_style
            ,
            (err, resp) -> throw new Metor.Error(500, err.reason) if err?
        )
        return true
)