Template.footer.helpers
  "loggedIn": () ->
    return Meteor.userId

Template.footer.events
  "click #logoutFoot": (e) ->
    e.preventDefault()
    Meteor.logout()
    window.location = "https://accounts.google.com/logout"
