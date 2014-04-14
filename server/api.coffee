Router.map ->
  @route "createElectionAPI",
    where: "server"
    path: "/api/election"
    action: () ->
      if this.params.secret != process.env.apiSecret
        this.response.writeHead(401, {'Content-Type': "text/plain"})
        this.response.end("Bad secret")
        return
      electionData = JSON.parse(this.request.body)
      Election.create(electionData)
      this.response.writeHead(200, {'Content-Type': "text/plain"})
      this.response.end("Ok")
  @route "createGroupAPI",
    where: "server"
    path: "/api/group"
    action: () ->
      if this.params.secret != process.env.apiSecret
        this.response.writeHead(401, {'Content-Type': "text/plain"})
        this.response.end("Bad secret")
        return
      groupData = this.request.body
      Group.create(groupData)
      this.response.writeHead(200, {'Content-Type': "text/plain"})
      this.response.end("Ok")
