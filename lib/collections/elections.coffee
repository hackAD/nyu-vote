root = global ? window

root.Elections = new Meteor.Collection("elections")

class Election extends ReactiveClass(Elections)
  constructor: (fields) ->
    _.extend(@, fields)
    @_activeQuestionIndex = 0
    createValidation(@)
    Election.initialize.call(@)

  # opens an election and locks it, also starts the vote counter
  open: () ->
    # This function can only be called on the server
    if (Meteor.isClient)
      return
    if @status == "open"
      throw new Meteor.Error(500, "Election is already open")
    # If it has been temporarily closed, just open it again
    else if @status == "closed"
      @status = "open"
      @update({$set: {status: @status}})
    else if @status == "unopened"
      @status = "open"
      # build the votes object which will hold our results
      @votes = {}
      for question in @questions
        question_object = {}
        for choice in question.choices
          question_object[choice._id] = 0
        if question.options.allowAbstain
          question_object["abstain"] = 0
        @votes[question._id] = question_object
      @update({$set:
        {
          status: @status,
          votes: @votes
        }
      })

  close: () ->
    @update({$set:
      {status: "closed"}
    })

  hasAdmin: (user) ->
    # They could be a global admin
    if user.isGlobalAdmin()
      return true
    # They could be the creator
    if user.getNetId() == @creator
      return true
    # They can be the admin of any of the groups
    for group in @groups
      groupObj = Group.fetchOne(group)
      if groupObj.hasAdmin(user)
        return true
    return false

  @findWithAdmin: (user) ->
    if not user
      return
    groups = Group.findWithAdmin(user).fetch()
    netId = user.getNetId()
    return @collection.find(
        $or:
          [
            {groups: {$in: if groups.length > 0 then _.map(groups, (g) -> g._id) else []}}
            ,
            {creator: netId}
          ]
      )

  getBallot: (user) ->
    oldBallot = Ballot.fetch({netId: user.getNetId(), electionId: @_id})
    if oldBallot
      return oldBallot
    return generateBallot(user)

  hasVoted: (user) ->
    return Ballots.find({netId: user.getNetId(), electionId: @_id}).count() > 0

  addQuestion: ({name, description, options}) ->
    if (!name || name.length < 1)
      throw new Meteor.Error(500, "Questions must have a name")
    id = new Meteor.Collection.ObjectID().toHexString()
    description ?= ""
    options ?= {}
    options.type ?= "pick"
    if (options.type == "pick")
      options.voteMode ?= "single"
    options.allowAbstain ?= false
    rankResults = [{round: 1}]
    @questions.push(
      _id: id
      name: name
      description: description
      options: options
      choices: []
      rankResults: rankResults
    )
    return id
  
  addChoice: (questionId, {name, description, image}) ->
    if not questionId
      throw new Meteor.Error(500, "You must specify a question to add this choice to")
    if (!name || name.length < 1)
      throw new Meteor.Error(500, "Choices must have a name")
    id = new Meteor.Collection.ObjectID().toHexString()
    description ?= ""
    image ?= ""
    question = _.find(@questions, (question) ->
      return question._id == questionId
    )
    question.rankResults[0][id] = 0
    question.choices.push(
      _id: id
      name: name
      description: description
      image: image
    )
    return id

  # Stateful tracking of the active election
  activeElection = {
    current: undefined
    dep: new Deps.Dependency
  }
  @setActive = (election, adminMode) ->
    activeElection.dep.changed()
    activeElection.current = election
    # if we are an admin, we don't want the ballot
    if not adminMode
      Ballot.setActive(election)
    return @

  @getActive = () ->
    activeElection.dep.depend()
    activeElection.current?.depend()
    return activeElection.current

  makeActive: (adminMode) ->
    Election.setActive(@)

  setActiveQuestion: (questionIndex) ->
    @set("_activeQuestionIndex", questionIndex)
    return @

  getActiveQuestionIndex: () ->
    return @get("_activeQuestionIndex")

  getActiveQuestion: () ->
    return @questions[@getActiveQuestionIndex()]

  getQuestion: (questionId) ->
    return _.find(@questions, (question) -> return question._id == questionId)

  # how we deterministically shuffle the candidates based on the user's netId
  random_map = {}

  # returns a numerical SHA1 hash of a string as an integer
  stringHash = (string) ->
    sha1 = CryptoJS.SHA1(string).toString()
    hash = parseInt(sha1, 16)
    return hash

  root.stringHash = stringHash

  getRandomElectionMap = (election, user) ->
    if !random_map[election._id]
      user ?= Meteor.user()
      random_map[election._id] = _.map(election.questions, (question) ->
        # Keep a record of which hashes correspond to which indexes
        choiceIndexes = {}
        # Hash every choice with a combination of the choiceId, and the
        # netId of the user
        choiceHashes = _.map(question.choices, (choice, index) ->
          seed = choice._id
          if user
            seed += user.profile.netId
          hash = stringHash(seed)
          choiceIndexes[hash] = index
          return hash
        )
        # Sort the hashes
        choiceHashes.sort()
        # Return the shuffled list of indexes
        return _.map(choiceHashes, (choiceHash) ->
          return choiceIndexes[choiceHash]
        )
      )
    return random_map[election._id]

  # fetches the map of the random choices for a specific question
  getRandomQuestionMap: (questionIndex) ->
    return getRandomElectionMap(@)[questionIndex]

  # returns the random choice for a specific question and choice index
  getRandomChoice: (questionIndex, choiceIndex) ->
    trueChoiceIndex = getRandomElectionMap(@)[questionIndex][choiceIndex]
    return @get("questions")[questionIndex].choices[trueChoiceIndex]

Election.addOfflineFields(["_activeQuestionIndex", "creator", "votes", "status", "rankResults"])

Election.setupTransform()
# Promote it to the global scope
root.Election = Election

createValidation = (election, userId) ->
  election.questions ?= []
  election.groups ?= []
  return election


# We need to enforce slugs
Elections.before.insert((userId, doc) ->
  doc.slug = Utilities.generateSlug(doc.name, Elections)
  doc.status = "unopened"
  if userId
    user = User.fetchOne(userId)
    netId = user.getNetId()
    doc.creator = netId
  if (Meteor.isServer)
    Log.warn((if userId then user else "server") +
      " is creating election " + JSON.stringify(doc))
  return doc
)

Elections.before.update((userId, doc, fieldNames, modifier, options) ->
  if (Meteor.isServer)
    user = User.fetchOne(userId)
    ## reduced log for $inc updates that happen with votes
    modOps = Object.keys(modifier)
    if modOps.length == 1 and "$inc" in modOps
      Log.warn(user + " is incrementing with " +
        JSON.stringify(modifier) + " on electionId: " + doc._id)
    else
      Log.warn(user + " is making modification " + JSON.stringify(modifier) +
        " on election " + JSON.stringify(doc))
)

Elections.after.update((userId, doc, fieldNames, modifier, options) ->
  if doc.name != @previous.name
    newSlug = Utilities.generateSlug(doc.name, Elections)
    Elections.update(doc._id, {
      $set: {slug: newSlug}
    })
)

Elections.after.remove((userId, doc) ->
  if (Meteor.isServer)
    user = User.fetchOne(userId)
    Log.warn(user + " is deleting election " + JSON.stringify(doc))
)

# One can only create elections if they are on the whitelist. They are able to
# update and remove them however, if they are admins of the election
Elections.allow(
  insert: (userId, doc) ->
    user = User.fetchOne(userId)
    return user.isWhitelisted()
  update: (userId, doc, fieldNames, modifier) ->
    return true
    user = User.fetchOne(userId)
    return doc.hasAdmin(user)
  remove: (userId, doc) ->
    user = User.fetchOne(userId)
    return doc.hasAdmin(user)
)

# Elections are only mutable before an election. Also, no user can change the
# status, it must be done by the server
Elections.deny(
  update: (userId, doc, fieldNames) ->
    return (doc.status != "unopened" || "status" in fieldNames)
)

# You cannot update the creator of an election
Elections.deny(
  update: (userId, doc, fieldNames, modifier) ->
    return 'creator' in fieldNames
)

Meteor.methods(
  getRankResults: (electionId) ->
    ballots = Ballots.find(electionId: electionId).fetch()
    rankResults = {}
    if ballots.length == 0
      return rankResults
    for questionObject in ballots[0].election.questions
      questionId = questionObject._id
      questions = []
      for i in [0...ballots.length]
        ballot = ballots[i]
        for j in [0...ballot.questions.length]
          question = ballot.questions[j]
          if question._id == questionId
            questions.push(question)
      questionResults = []
      eliminated = []
      if questions.length == 0
        rankResults[questionId] = questionResults
        continue

      for i in [0...ballots[0].election.questions.length] #already checked at least one ballot
        if ballots[0].election.questions[i]._id == questionId
          questionInfo = ballots[0].election.questions[i]
          break

      for i in [0...questions.length]
        questions[i].choices.sort (a, b) ->
          return a.value-b.value

      for cnt in [0...questionInfo.choices.length-1]
        roundResult = {}
        for i in [0...questionInfo.choices.length]
          roundResult[questionInfo.choices[i]._id] = 0

        totalVotes = 0
        for i in [0...questions.length]
          ballot = questions[i].choices
          j = 0
          while ((ballot[j]._id == "abstain" and not ballot[j].value) or ballot[j].value == 0 or ballot[j]._id in eliminated) and j < ballot.length and not (ballot[j]._id == "abstain" and ballot[j].value)
            j++
          if not (j == ballot.length or (ballot[j]._id == "abstain" and ballot[j].value))
            totalVotes += 1
            roundResult[ballot[j]._id] += 1
        questionResults.push(roundResult)
        leader = questionInfo.choices[0]._id
        loser = questionInfo.choices[0]._id
        for i in [1...questionInfo.choices.length]
          if roundResult[questionInfo.choices[i]._id] > roundResult[leader]
            leader = questionInfo.choices[i]._id
          if questionInfo.choices[i]._id not in eliminated and roundResult[questionInfo.choices[i]._id] < roundResult[loser]
            loser = questionInfo.choices[i]._id
        if roundResult[leader] == roundResult[loser] or roundResult[leader] > (totalVotes//2)
          rankResults[questionId] = questionResults
          break
        else
          eliminated.push(loser)
    return rankResults

  toggleElectionStatus: (electionId) ->
    election = Election.fetchOne(electionId)
    if election.status == "closed" || election.status == "unopened"
      election.open()
    else
      election.close()

  createQuestion: (electionId, name, description, options = {}) ->
    election = Election.fetchOne(electionId)
    election.addQuestion(
      name: name
      description: description
      options: options
    )
    election.update()

  createChoice: (electionId, questionId, name, description="", image="") ->
    election = Election.fetchOne(electionId)
    election.addChoice(
      questionId: questionId
      name: name
      description: description
      image: image
    )
    election.update()

  resetElection: (electionId) ->
    election = Election.fetchOne(electionId)
    if not election.hasAdmin(Meteor.user())
      return
    Ballots.remove({electionId: election._id})
    election.update({
      $set: {
        status: "unopened"
      }
    })

  deleteElection: (electionId) ->
    election = Election.fetchOne(electionId)
    if not election.hasAdmin(Meteor.user())
      return
    Ballots.remove({electionId: election._id})
    election.remove()

  createElection: (name, description="", group_ids = []) ->
    if typeof(group_ids) == "string"
      group_ids = [group_ids]
    if Meteor.isServer and !Meteor.call("isGroupAdminOf", group_ids)
      throw new Meteor.Error(500, "Error: Not a group admin!")
    Elections.insert(
      name: name
      description: description
      status: "closed"
      creator: Meteor.user().profile.netId
      groups: group_ids
      voters: []
      questions: []
      , (err, resp) -> throw new Meteor.Error(500, err.reason) if err?
    )
    return true
)
