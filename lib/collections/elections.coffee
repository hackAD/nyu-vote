root = global ? window
root.Elections = new Meteor.Collection("elections")

root.Elections.allow(
    update: root.isAGroupAdmin
    insert: root.isAGroupAdmin
    remove: root.isAGroupAdmin
)

root.Elections.deny(
    update: (userId, doc, fieldNames) ->
        return 'candidates.votes' in fieldNames or 'admins' in fieldNames
)

root.Elections.deny(
    update: (userId, doc, fieldNames) ->
        #FIX DOC ARGUMENT?
        return !isGroupAdminOf(doc)
)

root.createElection = (name, description, group_ids = [], voting_style) ->
    check(name, String)
    check(description, String)
    if !isGroupAdminOf(group_ids)
        throw new Meteor.error(500, "Error: Not group admin!", group_ids)
    if voting_style != "NYUAD" or "NYU"
        throw new Meteor.error(500, "Error: Voting style not recognised!", voting_style)
    Elections.insert(
        "name": name
        "descripton": description
        "status": "closed"
        "admins": [Meteor.user().profile.netId]
        "groups": group_ids
        "voters": []
        "category": []
        "options":
            "voting_style": voting_style

    )
    #GET ELECTION_ID
    Meteor.call("updateElectionAdmins", election_id, [Meteor.user().profile.userId])
    return true

root.createCategory = (name, description, election_id) ->
    check(name, String)
    check(description, String)
    Elections.update(
        "_id": election_id
        $push:
            "category":
                "_id": ObjectID()
                "name": name
                "descripton": description
                "candidates": []
    )
    return true

root.createCandidate = (name, description, category_id, image="") ->
    check(name, String)
    check(description, String)
    Elections.update(
        "category._id": category_id
        $push:
            "category.$.candidates":
                "_id": ObjectID()
                "name": name
                "descripton": description
                "image": image
                "votes": []
    )
    return true

Meteor.methods(
    vote: (candidates_id) ->
        Elections.update(
            "category.candidates._id": candidates_id
            $push:
                "voters": Meteor.user().profile.netId
                "category.candidates.$.votes": Meteor.user().profile.netId
        )
        return true

    updateElectionAdmins: (election_id, admins) ->
        founder = Groups.findOne({"_id":group_id})
        if founder?
            Groups.update(
                "_id": group_id
                $set:
                    "admins": [founder]
            )
        Groups.update(
             "_id": group_id
            $addToSet:
                "admins": 
                    $each: admins
        )
        return true
)