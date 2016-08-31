Router.configure
  template: "voterView"
  loadingTemplate: "loading"

Router.onBeforeAction("loading")

homeHandle = () ->
  return [
    Meteor.subscribe("userData"),
    Meteor.subscribe("voterElectionsAndBallots"),
    Meteor.subscribe("adminGroups"),
  ]
voterHandle = () ->
  return [
    Meteor.subscribe("userData"),
    Meteor.subscribe("voterElectionsAndBallots"),
  ]
adminHandle = () ->
  return [
    Meteor.subscribe("userData"),
    Meteor.subscribe("adminElections"),
    Meteor.subscribe("adminGroups"),
    Meteor.subscribe("adminWhitelist")
  ]

setActiveElection = (newElectionSlug) ->
  Session.set("listMode", "elections")
  election = Elections.findOne({slug: newElectionSlug})
  if election
    # will throw if we are trying to look at an election that
    # doesn't exist or we don't have the privacy level for
    election.makeActive()
    return election

setActiveGroup = (newGroupSlug) ->
  Session.set("listMode", "groups")
  group = Groups.findOne({slug: newGroupSlug})
  if group
    group.makeActive()
    return group

#Router.route "/",
  #onAfterAction: ()
Router.map ->
  @route "home",
    path: "/"
    waitOn: homeHandle
    onAfterAction: () ->
      if @params.query.username && @params.query.password
        Meteor.loginWithPassword(
          @params.query.username,
          @params.query.password
        )
      $('html,body').animate({scrollTop:0}, 300)
  @route "about",
    path: "/about"
    template: "about"
  @route "help",
    path: "/help"
    template: "help"
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
  @route "adminElectionsResult",
    path: "/admin/elections/:slug/result"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminResults"
    onAfterAction: () ->
      setActiveElection(@params.slug)
  @route "adminElectionsEdit",
    path: "/admin/elections/:slug/edit"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminEdit"
    onAfterAction: () ->
      setActiveElection(@params.slug)
  @route "adminElectionsShow",
    path: "/admin/elections/:slug"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "electionsAdminShow"
    onAfterAction: () ->
      setActiveElection(@params.slug)
  @route "adminGroupsCreate",
    path: "/admin/groups/create"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "groupsAdminCreate"
  @route "adminGroupsEdit",
    path: "/admin/groups/:slug/edit"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "groupsAdminEdit"
    onAfterAction: () ->
      setActiveGroup(@params.slug)
  @route "adminGroupsShow",
    path: "/admin/groups/:slug"
    waitOn: adminHandle
    layoutTemplate: "adminMaster"
    template: "groupsAdminShow"
    onAfterAction: () ->
      setActiveGroup(@params.slug)
  @route "electionsReview",
    path: "/:slug/review"
    waitOn: voterHandle
    onAfterAction: () ->
      $('html,body').animate({scrollTop:0}, 300)
      setActiveElection(@params.slug)
  @route "electionsVote",
    path: "/:slug/:questionIndex"
    waitOn: voterHandle
    onAfterAction: () ->
      $('html,body').animate({scrollTop:0}, 300)
      election = setActiveElection(@params.slug)
      if not election
        return
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
      $('html,body').animate({scrollTop:0}, 300)
      setActiveElection(@params.slug)
