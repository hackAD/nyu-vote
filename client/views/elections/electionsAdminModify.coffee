Template.electionsAdminModify.helpers
  elections: () ->
    return Elections.find()
  notModifying: () ->
    return Session.get("modifying") != this._id