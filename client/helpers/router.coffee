Router.configure
  template: "voterView"

Router.map ->
  @route "home",
    path: "/"
  @route "electionsShow",
    path: "/vote/:slug/"
    onBeforeAction: () ->
      Election.setActive(this.params.slug)
  @route "electionsVote",
    path: "/:slug"

  @route "admin",
    path: "/admin"
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
