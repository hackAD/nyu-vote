root = global ? window
root.Groups = new Meteor.Collection("groups")

root.Groups.allow(
    update: root.isAGroupAdmin
    insert: root.isGlobalAdmin
    remove: root.isGlobalAdmin
)

root.Groups.deny(
    update: (userId, doc, fieldNames) ->
        return 'admins' in fieldNames
)

root.addGroup = (name, description, admins) ->
    Groups.insert(
        name: name
        description: description
        admins: admins
    )
    return true

root.removeGroup = (group_id) ->
    Groups.remove({"_id": group_id})
    return true

Meteor.methods(
    updateGroupAdmins: (group_id, admins) ->
        founder = Groups.findOne({"_id":group_id})
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