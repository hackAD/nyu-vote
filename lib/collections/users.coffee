Accounts.config
  restrictCreationByEmailDomain: "nyu.edu"

class User extends ReactiveClass
  self = @
  constructor: (params) ->
    _.extend(@, params)

  @create: (params) ->
    id = Elections.insert(params)
    return self.findOne(id)
