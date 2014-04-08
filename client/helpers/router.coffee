Router.configure
  layoutTemplate: "oldMaster"

Router.map ->
  @route "home",
    path: "/"
    template: "home"
  @route "admin",
    path: "/admin"
    template: "admin"
  @route "about",
    path: "/about"
    template: "about"
