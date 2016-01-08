Meteor.publish("adminGroups", ()->
  if not @userId
    @ready()
    return
  user = User.fetchOne(@userId)
  if user.isGlobalAdmin()
    return Groups.find()
  else
    return Group.findWithAdmin(user)
)
Meteor.publish("adminElections", ()->
  if not @userId
    @ready()
    return
  user = User.fetchOne(@userId)
  if user.isGlobalAdmin()
    return Elections.find()
  else
    return Election.findWithAdmin(user)
)
Meteor.publish("adminWhitelist", () ->
  if not @userId
    @ready()
    return
  user = User.fetchOne(@userId)
  return Groups.find({slug: "global-whitelist", netIds: user.getNetId()})
)

Meteor.publish("voterElectionsAndBallots", () ->
  user = Meteor.users.findOne(@userId)
  groups = findUserGroups(@)
  if not groups
    @ready()
    return
  electionsCursor = Elections.find(
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
  openElections = electionsCursor.map((election) ->
    return election._id
  )
  ballotsCursor = Ballots.find(
    netId: user.getNetId()
    electionId:
      $in: openElections
  )

  return [
    electionsCursor,
    ballotsCursor
  ]
)

Meteor.publish("userData", () ->
  if not @userId
    @ready()
    return
  user = User.fetchOne(@userId)
  if user.isGlobalAdmin()
    cursor = Meteor.users.find(
      {$or: [
        {_id: @userId},
        {username: "devAdmin"}
      ]}
    )
  else
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

