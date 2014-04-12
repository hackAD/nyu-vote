Router.configure
  template: "voterView"

Router.map ->
  @route "home",
    path: "/"
  @route "electionList",
    path: "/vote"
  @route "admin",
    path: "/admin"
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
