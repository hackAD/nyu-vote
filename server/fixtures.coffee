isDevEnv = () ->
    if process.env.ROOT_URL == "http://localhost:3000/"
        return true
    else
        return false

Meteor.startup( () ->
    console.log(process.env.ROOT_URL)
    console.log(Meteor.users.find().count())
    if isDevEnv() and Meteor.users.find().count() == 0
        console.log("adding devadmin")
        Accounts.createUser(
            username:"devAdmin"
            password:"password"
            profile:
                name: "devAdmin"
                netId: "devAdmin"
        )
    if isDevEnv() and Groups.find({"name": "global"}).count == 0
        Groups.insert(
            name: "global"
            admins: ["devAdmin"]
            netIds: ["devAdmin"]
        )
)