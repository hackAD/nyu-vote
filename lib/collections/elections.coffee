root = global ? window
root.Elections = new Meteor.Collection("elections")

root.Elections.allow(
    update: (userId, doc, fieldNames) ->
        #FIX DOC ARGUMENT?
        return isGroupAdminOf(doc._id)
    insert: root.isAGroupAdmin
    remove: (userId, doc, fieldNames) ->
        #FIX DOC ARGUMENT?
        return isGroupAdminOf(doc._id)
)

root.Elections.deny(
    update: (userId, doc, fieldNames) ->
        return 'choices.votes' in fieldNames or 'admins' in fieldNames
)

root.Elections.deny(
    update: (userId, doc, fieldNames) ->
        #FIX DOC ARGUMENT?
        return isGroupAdminOf(doc)
)

root.createElection = (name, description, group_ids = [], voting_style) ->
    check(name, String)
    check(description, String)
    if !isGroupAdminOf(group_ids)
        throw new Meteor.error(500, "Error: Not group admin!", group_ids)
    if voting_style != "NYUAD" or "NYU"
        throw new Meteor.error(500, "Error: Voting style not recognised!", voting_style)
    Elections.insert(
        name: name
        descripton: description
        status: "closed"
        admins: [Meteor.user().profile.netId]
        groups: group_ids
        voters: []
        questions: []
        options:
            voting_style: voting_style
        ,
        createCallback((resp) -> Meteor.call("updateElectionAdmins", resp, [Meteor.user().profile.userId], createCallback()))
    )
    return true

root.createQuestion = (name, description, election_id) ->
    check(name, String)
    check(description, String)
    Elections.update(
        _id: election_id
        $push:
            question:
                _id: ObjectID()
                name: name
                descripton: description
                choice: []
    )
    return true

root.createChoice = (name, description, question_id, image="") ->
    check(name, String)
    check(description, String)
    Elections.update(
        "question._id": question_id
        $push:
            "question.$.choices":
                _id: ObjectID()
                name: name
                descripton: description
                image: image
                votes: []
    )
    return true

Meteor.methods(
    vote: (choices_id) ->
        Elections.update(
            "question.choices._id": choices_id
            $push:
                voters: Meteor.user().profile.netId
                "question.choices.$.votes": Meteor.user().profile.netId
        )
        return true

    updateElectionAdmins: (election_id, admins) ->
        founder = Groups.findOne({"_id":group_id})
        if founder?
            Groups.update(
                _id: group_id
                $set:
                    admins: [founder]
            )
        Groups.update(
             _id: group_id
            $addToSet:
                admins: 
                    $each: admins
        )
        return true
)