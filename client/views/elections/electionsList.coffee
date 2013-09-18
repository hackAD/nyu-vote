Template.electionsList.helpers
  electionItems: () ->
    return Elections.find()

Template.electionItem.rendered = () ->
	renderRows()
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
    if target.hasClass("choice")
      target.toggleClass("chosen")
    else
      target.parent().toggleClass("chosen")
  "click .vote": (e) ->
    e.preventDefault()
    election_id = this._id
    choices = $(e.target).parent()
      .children(".chosen").map(() -> $(this).attr("data-id")).toArray()
    Meteor.call("vote", election_id, choices, (err, resp) ->
      if (err)
        Meteor.userError.throwError(err.reason)
      console.log resp)

$(window).on("resize orientationchange", () ->
	setTimeout(() ->
		renderRows()
	, 500)
	)

renderRows = () ->
	for row in $(".row")
		$(row).css({height: ""})
		$(row).height($(row).height())