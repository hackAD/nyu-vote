Router.configure
  template: "voterView"
  loadingTemplate: "loading"
Router.onBeforeAction("loading")

voterHandle = () ->
  return electionsHandle

setActiveElection = (newElectionSlug) ->
  Deps.nonreactive(() ->
    election = Election.getActive()
    if election?.slug != newElectionSlug
      election = Election.fetchOne({slug: newElectionSlug})
      election.makeActive()
    return election
  )


  

Router.map ->
  @route "home",
    path: "/"
  @route "electionsReview",
    path: "/:slug/review"
    waitOn: voterHandle
    onAfterAction: () ->
      setActiveElection(@params.slug)
  @route "electionsVote",
    path: "/:slug/:questionIndex"
    waitOn: voterHandle
    onAfterAction: () ->
      election = setActiveElection(@params.slug)
      if @params.questionIndex < 0
        @redirect("electionsVote", {slug: @params.slug, questionIndex: 0})
        return
      if @params.questionIndex > (election.questions.length - 1)
        @redirect("electionsReview", {slug: @params.slug})
        return

      election.setActiveQuestion(@params.questionIndex)
  @route "electionsShow",
    path: "/:slug/"
    waitOn: voterHandle
    onAfterAction: () ->
      election = Election.fetchOne({slug: @params.slug})
      election.makeActive()
  @route "admin",
    path: "/admin"
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
