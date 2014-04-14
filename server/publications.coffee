Meteor.publish("adminGroups", ()->
  if not @userId
    @ready()
    return
  user = Meteor.users.findOne(@userId)
  return Group.findWithAdmin(user)
)
Meteor.publish("globalAdminGroups", () ->
  if not @userId
    @ready()
  user = Meteor.users.findOne(@userId)
  if user.isGlobalAdmin()
    return Groups.find()
  else
    @ready()
    return null
)
Meteor.publish("globalAdminElections", () ->
  if not @userId
    @ready()
  user = Meteor.users.findOne(@userId)
  if user.isGlobalAdmin()
    return Elections.find()
  else
    @ready()
    return null
)
Meteor.publish("adminElections", ()->
  user = User.fetchOne(@userId)
  return Election.findWithAdmin(user)
)
Meteor.publish("adminWhitelist", () ->
  if not @userId
    @ready()
    return
  user = User.fetchOne(@userId)
  return Groups.find({slug: "global-whitelist", netIds: user.getNetId()})
)

Meteor.publish("voterElections", () ->
  groups = findUserGroups(@)
  if not groups
    @ready()
    return
  cursor = Elections.find(
    groups:
      $in: _.map(groups, (g) -> g._id)
    status: "open"
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

