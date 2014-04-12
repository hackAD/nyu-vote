Accounts.config
  restrictCreationByEmailDomain: "nyu.edu"


class User extends ReactiveClass(Meteor.users)
  constructor: (fields) ->
    _.extends(@, fields)
    User.initialize.call(@)

  isGlobalAdmin: ->
    globalAdminGroup = Group.fetchOne({slug: "global-admins"})
    if globalAdminGroup
      return _.contains(globalAdminGroup.admins, @getNetId())

  getNetId: ->
    return @profile.netId

  @fetchByNetId: (netId) ->
    return @fetchOne({"profile.netId": netId})

  isWhitelisted: ->
    whitelist = Group.fetchOne({slug: "Global Whitelist"})
    return whitelist.contains(user)


  
