Template.groupsAdminShow.helpers
  group: () ->
    return Group.getActive()
  usersCount: () ->
    return this.netIds.length
  canEdit: () ->
    user = Meteor.user()
    if user.isGlobalAdmin()
      return true
    return @hasAdmin(user)
