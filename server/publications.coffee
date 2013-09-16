Meteor.publish("adminGroups", ()->
    user = Meteor.users.findOne({_id:this.userId})
    return Groups.find({admins:user.profile.netId})
)
Meteor.publish("adminElections", ()->
    user = Meteor.users.findOne({_id:this.userId})
    return Elections.find({admins:user.profile.netId})
)