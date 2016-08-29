Accounts.config
  restrictCreationByEmailDomain: "nyu.edu"

root = global ? window

class User extends ReactiveClass(Meteor.users)
  constructor: (fields) ->
    _.extend(@, fields)
    User.initialize.call(@)

  isGlobalAdmin: ->
    globalAdminGroup = Group.fetchOne({slug: "global-admins"})
    if globalAdminGroup
      return globalAdminGroup.containsUser(@) ||
        _.contains(globalAdminGroup.admins, @getNetId())
    return false

  @fetchByNetId: (netId) ->
    return @fetchOne({"profile.netId": netId})

  isWhitelisted: () ->
    whitelist = Group.fetchOne({slug: "global-whitelist"})
    if whitelist.containsUser(@) || @isGlobalAdmin()
      return true

  getNetId: ->
    return @profile.netId

  toString: ->
    return @getNetId() + "(" + @_id + ")"

User.setupTransform()

Meteor.methods(
  createTestUser: (netId, password) ->
    if netId.indexOf("testuser") != 0
      throw new Meteor.Error("Error: netId must start with testuser")
    Accounts.createUser(
      username: netId
      email: netId + '@nyu.edu'
      password: password
    )

  getAdminGroups: (user) ->
    whitelist = Group.fetchOne({slug: "global-whitelist"})
    globalAdminGroup = Group.fetchOne({slug: "global-admins"})
    return {whitelist: whitelist, globalAdminGroup: globalAdminGroup}
)

root.User = User

