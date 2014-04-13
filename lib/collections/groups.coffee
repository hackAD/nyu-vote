root = global ? window
root.Groups = new Meteor.Collection("groups")

class Group extends ReactiveClass(Groups)
  constructor: (fields) ->
    _.extend(@, fields)
    Group.initialize.call(@)
  
  hasAdmin: (user) ->
    if user.isGlobalAdmin()
      return true
    return _.contains(@admins, user.getNetId())

  # Whether a user is present in a group as a voter
  containsUser: (user) ->
    return _.contains(@netIds, user.getNetId())

  # Finds which groups have a specific user as an admin
  @findWithAdmin = (user) ->
    netId = user.getNetId()
    return @collection.find(
      {
        $or: [
          admins: netId
          ,
          creator: netId
          ]
      }
    )

Group.setupTransform()
# Registering offline fields
Group.addOfflineFields(["creator"])
# Promote it to the global scope
root.Group = Group

# Registering Hooks
Groups.before.insert((userId, doc) ->
  doc.slug = Utilities.generateSlug(doc.name, Groups)
)
Groups.after.update((userId, doc, fieldNames, modifier, options) ->
  if doc.name != @previous.name
    newSlug = Utilities.generateSlug(doc.name, Groups)
  Groups.update(doc._id, {
    $set: {slug: newSlug}
  })
)

# They must be on the whitelist to create groups but they can edit groups that
# they are the admin of
Groups.allow(
  insert: (userId, doc) ->
    user = User.fetchOne(userId)
    return user.isWhitelisted()
  update: (userId, doc) ->
    doc.hasAdmin(User.fetchOne(userId))
  remove: (userId, doc) ->
    doc.hasAdmin(User.fetchOne(userId))
)

# The creator of a group is immutable
Groups.deny(
  update: (userId, doc, fieldNames) ->
    return "creator" in fieldNames
)

Meteor.methods(
  addGroup: (name, description, admins, netIds=[]) ->
    if Meteor.isServer and !Meteor.call("isAGroupAdmin")
      throw new Meteor.Error(500,
      "Error: You are not administrator of any group!")
    Groups.insert(
      name: name
      description: description
      creator: Meteor.user().profile.netId
      admins: admins
      netIds: netIds
    )
    return Groups.findOne({name:name})._id
)
