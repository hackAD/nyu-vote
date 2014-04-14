Template.electionsAdminCreate.events
  "submit #newElection": (e) ->
    e.preventDefault()
    name = $("#electionName").val()
    description = $("#electionDescription").val()
    console.log(name)
    console.log(description)
    election = new Election({name: name, description: description})
    election.put(() ->
      $("#electionName").val("")
      $("#electionDescription").val("")
      election.refresh()
      Router.go("adminElectionsShow", {slug: election.slug})
    )
