Meteor.publish("adminGroups", ()->
  user = Meteor.users.findOne(this.userId)
  return Groups.find(
    $or:
      [
        {admins: if user?.profile?.netId? then user.profile.netId else "" }
        ,
        {creator: user?.profile?.netId}
      ]
    )
)
Meteor.publish("adminElections", ()->
  user = Meteor.users.findOne(this.userId)
  groups = Groups.
    find({admins: if user?.profile?.netId? then user.profile.netId else ""}).fetch()
  return Elections.find(
      $or:
        [
          {groups: {$in: if groups.length > 0 then _.map(groups, (g) -> g._id) else []}}
          ,
          {creator: user?.profile?.netId}
        ]
    )
)
Meteor.publish("elections", () ->
  user = Meteor.users.findOne(this.userId)
  if not user
    this.ready()
    return
  groups = Groups.
    find({netIds: user.profile.netId}).fetch()
  if groups.length == 0
    this.ready()
    return
  handle = Elections.find(
    groups:
      $in: _.map(groups, (g) -> g._id)
    status:"open",
    voters: {$ne: user.profile.netId}
    ,
    {fields:
      name: 1,
      description: 1,
      questions: 1
    }
  )
  return handle
)

Meteor.publish("votedElections", () ->
  user = Meteor.users.findOne(this.userId)
  if not user
    this.ready()
    return
  groups = Groups.
    find({netIds: user.profile.netId}).fetch()
  if groups.length == 0
    this.ready()
    return
  return Elections.find(
    groups:
      $in: _.map(groups, (g) -> g._id)
    status:"open"
    ,
    {fields:
      name: 1
      description: 1
    }
  )
)
