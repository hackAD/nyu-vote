Template.electionsList.helpers
  electionItems: () ->
    return Elections.find()

Template.electionItem.rendered = () ->
	theWindow = $(window)
	sticky = $(".electiontitle")
	test = $(".eachelection").first()
	test.scrollspy(
		onEnter: (element, position) ->
			console.log("You entered!")
			console.log element
			console.log position
		onLeave: (element, position) ->
			console.log "you left!"
			console.log element
			console.log position
			)
	topPositions = []
	for stick in sticky
		stick = $(stick)
		topPositions.push
			id: "#" + stick.attr("id")
			top: stick.offset().top
			sticky: false
	console.log topPositions
	top = sticky.offset().top
	theWindow.scroll( () ->
			#check(topPositions, theWindow)
		)

check = (topPositions, theWindow) ->
	console.log theWindow.scrollTop()
	for header in topPositions
		if !header.sticky && theWindow.scrollTop() > header.top
		  header.sticky = true
			$(".header-stick").removeClass("header-stick")
			$(header.id).addClass("header-stick")
			return


Template.electionsList.events
  "click .choice": (e) ->
    e.preventDefault()
    target = $(e.target)
    if !target.hasClass("choice")
      target = target.parent()
    target.toggleClass("chosen")
    target.parent().children(".abstain").removeClass("chosen")
    if target.parent().find(".choice.chosen").length == 0
      target.parent().find(".abstain").addClass("chosen")
  "click .abstain": (e) ->
    e.preventDefault()
    target = $(e.target)
    if !target.hasClass("abstain")
      target = target.parent()
    target.parent().children(".choice").removeClass("chosen")
    target.addClass("chosen")

  "click .vote": (e) ->
    e.preventDefault()
    election_id = this._id
    choices = $(e.target).parent()
      .find(".chosen.choice").map(() -> $(this).attr("data-id")).toArray()
    Meteor.call("vote", election_id, choices, (err, resp) ->
      if (err)
        Meteor.userError.throwError(err.reason)
      console.log resp)
