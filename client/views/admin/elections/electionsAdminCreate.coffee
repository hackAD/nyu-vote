Template.electionsAdminCreate.events
  "submit #newElection": (e) ->
    e.preventDefault()
    name = $("#electionName").val()
    description = $("#electionDescription").val()
    election = new Election({name: name, description: description})
    election.put(() ->
      $("#electionName").val("")
      $("#electionDescription").val("")
      election.refresh()
      Router.go("adminElectionsShow", {slug: election.slug})
    )
