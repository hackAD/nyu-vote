isDevEnv = () ->
    if process.env.ROOT_URL == "http://localhost:3000"
        return true
    else
        return false

Meteor.startup( () ->
    if isDevEnv() and Meteor.users.find().count() == 0
        Accounts.createUser(
            "devAdmin"
            ""
            "password"
                name: "devAdmin"
                netId: "devAdmin"
        )
    if isDevEnv() and Groups.find({"name": "global"}).count == 0
        Groups.insert(
            "name": "global"
            "admins": "devAdmin"
            "netId": "devAdmin"
        )
)