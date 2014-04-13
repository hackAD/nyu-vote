Router.configure
  template: "voterView"
  loadingTemplate: "loading"
  onBeforeAction: () ->
    $('html,body').animate({scrollTop:0}, 300)


Router.onBeforeAction("loading")

voterHandle = () ->
  return [electionsHandle, ballotsHandle, usersHandle]
adminHandle = () ->
  return [
    Meteor.subscribe("adminElections"),
    Meteor.subscribe("adminGroups"),
    Meteor.subscribe("adminWhitelist")
  ]

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
    waitOn: voterHandle
  @route "admin",
    path: "/admin"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
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
      setActiveElection(@params.slug)
