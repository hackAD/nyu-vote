Meteor.publish("adminGroups", ()->
  user = Meteor.users.findOne(@userId)
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
  user = Meteor.users.findOne(@userId)
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
Meteor.publish("voterElections", () ->
  groups = findUserGroups(@)
  if not groups
    @ready()
    return
  cursor = Elections.find(
    groups:
      $in: _.map(groups, (g) -> g._id)
    ,
    {fields:
      name: 1,
      description: 1,
      questions: 1,
      slug: 1
    }
  )
  return cursor
)

Meteor.publish("voterBallots", () ->
  user = Meteor.users.findOne(@userId)
  if not user
    @ready()
    return
  cursor = Ballots.find(
    netId: user.getNetId()
  )
  return cursor
)

Meteor.publish("userData", () ->
  if not @userId
    @ready()
    return
  cursor = Meteor.users.find(
    {_id: @userId}
    ,
    {fields:
      "profile": 1
    }
  )
  return cursor
)

findUserGroups = (context) ->
  user = Meteor.users.findOne(context.userId)
  if not user
    return false
  groups = Groups.
    find({netIds: user.profile.netId}).fetch()
  if groups.length == 0
    return false
  return groups

