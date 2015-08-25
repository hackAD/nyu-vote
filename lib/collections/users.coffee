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

User.setupTransform()

root.User = User
  
