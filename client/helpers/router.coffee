Router.configure
  template: "voterView"
  loadingTemplate: "loading"
Router.onBeforeAction("loading")

voterHandle = () ->
  return electionsHandle

Router.map ->
  @route "home",
    path: "/"
  @route "electionsReview",
    path: "/:slug/review"
    waitOn: voterHandle
    onAfterAction: () ->
      election = Election.fetchOne({slug: this.params.slug})
      election.makeActive()
      election.setActiveQuestion(-1)
  @route "electionsVote",
    path: "/:slug/:questionIndex"
    waitOn: voterHandle
    onAfterAction: () ->
      election = Election.fetchOne({slug: this.params.slug})
      election.makeActive()
      election.setActiveQuestion(this.params.questionIndex)
  @route "electionsShow",
    path: "/:slug/"
    waitOn: voterHandle
    onAfterAction: () ->
      election = Election.fetchOne({slug: this.params.slug})
      election.makeActive()
  @route "admin",
    path: "/admin"
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
