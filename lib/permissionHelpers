Meteor.startup( () ->
    isElectionAdmin = (election_id) ->
        return Meteor.call("isElectionAdmin", election_id)
    isGlobalAdmin = () ->
        return Meteor.call("isGlobalAdmin")
    isAGroupAdmin = () ->
        return Meteor.call("isAGroupAdmin")
    isGroupAdminOf = (group_ids) ->
        return Meteor.call("isGroupAdminOf", group_ids)

)