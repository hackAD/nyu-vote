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
      return _.contains(globalAdminGroup.admins, @getNetId())
    return false

  getNetId: ->
    return @profile.netId

  @fetchByNetId: (netId) ->
    return @fetchOne({"profile.netId": netId})

  isWhitelisted: ->
    whitelist = Group.fetchOne({slug: "Global Whitelist"})
    return whitelist.contains(user)

User.setupTransform()

root.User = User
  
