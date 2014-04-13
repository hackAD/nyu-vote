Router.configure
  template: "voterView"
  loadingTemplate: "loading"

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
  election = Elections.findOne({slug: newElectionSlug})
  election.makeActive()
  return election

Router.map ->
  @route "home",
    path: "/"
    waitOn: voterHandle
    onAfterAction: () ->
      $('html,body').animate({scrollTop:0}, 300)
  @route "admin",
    path: "/admin"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "admin"
  @route "adminElectionsCreate",
    path: "/admin/elections/create"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminCreate"
  @route "adminElectionsEdit",
    path: "/admin/elections/:slug/edit"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminEdit"
    onAfterAction: () ->
      election = setActiveElection(@params.slug)
  @route "adminElectionsShow",
    path: "/admin/elections/:slug"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminShow"
    onAfterAction: () ->
      election = setActiveElection(@params.slug)
  @route "about",
    path: "/about"
    layoutTemplate: "adminMaster"
    template: "about"
  @route "electionsReview",
    path: "/:slug/review"
    waitOn: voterHandle
    onAfterAction: () ->
      setActiveElection(@params.slug)
      $('html,body').animate({scrollTop:0}, 300)
  @route "electionsVote",
    path: "/:slug/:questionIndex"
    waitOn: voterHandle
    onAfterAction: () ->
      $('html,body').animate({scrollTop:0}, 300)
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
      $('html,body').animate({scrollTop:0}, 300)
