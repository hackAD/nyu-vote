Template.groupsAdminShow.helpers
  group: () ->
    return Group.getActive()
  usersCount: () ->
    return this.netIds.length
  canEdit: () ->
    return @hasAdmin(Meteor.user())
