Template.electionsList.helpers
	electionItems: () ->
		return Elections.find({})

Template.electionItem.created = () ->
	setTimeout(() ->
			renderRows()
		, 100)
	$(window).on("orientationchange", () ->
		setTimeout(() ->
			renderRows()
		, 500)
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
		counter = target.parent().attr("chosen-number")
		if target.parent().attr("data-multi") != "true"  && !target.hasClass("chosen")
			target.parent().find(".choice").removeClass("chosen")
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
		noAbstains =  $(e.target).parent().find(".abstain-false")
		if noAbstains.find(".choice.chosen").length != noAbstains.length
			$(e.target).parent().find(".vote-error").html("You did not answer all required questions")
		choices = $(e.target).parent()
			.find(".chosen.choice").map(() -> $(this).attr("data-id")).toArray()
		Meteor.call("vote", election_id, choices)

renderRows = () ->
	max = Math.max.apply(null, $(".profilebox").map( () -> $(this).height()).toArray())
	$(".profilebox").height(max)
