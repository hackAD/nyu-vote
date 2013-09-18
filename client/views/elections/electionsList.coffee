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





