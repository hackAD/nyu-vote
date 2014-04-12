Router.configure
  template: "voterView"

Router.map ->
  @route "home",
    path: "/"
  @route "electionList"
  @route "admin",
    path: "/admin"
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
