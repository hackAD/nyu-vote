questionCount = 0
choiceCount = 0

Template.electionsAdminEdit.helpers
  election: () ->
    questionCount = 0
    return Election.getActive()
  allowAbstain: () ->
    return if @options.allowAbstain then "checked" else null
  pick: () ->
    return if @options.type == "pick" then "checked" else null
  single: () ->
    return if @options.voteMode == "single" then "checked" else null
  multi: () ->
    return if @options.voteMode == "multi" then "checked" else null
  pickN: () ->
    return if @options.voteMode == "pickN" then "checked" else null
  pickNVal: () ->
    election = Election.getActive()
    election.depend()
    return @options.pickNVal
  unlessPickN: () ->
    election = Election.getActive()
    election.depend()
    isPickN = @options.voteMode == "pickN"
    return if isPickN then null else "disabled"
  canEdit: () ->
    @status == "unopened"
  groups: () ->
    seen = {}
    existingGroups = _.map(@groups, (groupId) ->
      seen[groupId] = true
      localGroup = Group.fetchOne(groupId)
      if localGroup
        return localGroup
      else
        return  {
          _id: groupId
          name: "hidden group"
        }
    )
    Groups.find().forEach((group) ->
      if seen[group._id]
        return
      existingGroups.push(group)
    )
    return existingGroups

  hasGroup: (id, groups) ->
    return if id in groups then "checked" else null
  questionCount: (increment) ->
    choiceCount = 0
    if increment == 1 
      questionCount += 1
    return questionCount
  resetChoiceCount: () ->
    choiceCount = 0
  choiceCount: () ->
    choiceCount += 1
    return choiceCount
  isPickQuestion: (election) ->
    election.depend()
    return @options.type == "pick"
  isRankQuestion: (election) ->
    election.depend()
    return @options.type == "rank"

Template.electionsAdminEdit.events
  "click .save-election, submit .election-form": (e) ->
    e.preventDefault()
    groups = $(".election.groups").val()
    oldElection = @
    questionIndex = -1
    choiceIndex = -1
    values = $('form').serializeArray()
    newGroups = []
    for field in values
      switch field.name
        when "group"
          newGroups.push(field.value)
        when "name"
          oldElection.name = field.value
        when "description"
          oldElection.description = field.value
        when "questionName"
          choiceIndex = -1
          questionIndex += 1
          oldElection.questions[questionIndex].name = field.value
        when "questionDescription"
          oldElection.questions[questionIndex].description = field.value
        when "choiceName"
          choiceIndex += 1
          oldElection.questions[questionIndex].choices[choiceIndex].name = field.value
        when "choiceDescription"
          oldElection.questions[questionIndex].choices[choiceIndex].description = field.value
        when "choiceImage"
          oldElection.questions[questionIndex].choices[choiceIndex].image = field.value
    oldElection.groups = newGroups
    oldElection.update(() =>
      Router.go("adminElectionsShow", {slug: @slug})
    )

  "click .submitQuestion": (e) ->
    e.preventDefault()
    election = Election.getActive()
    name = $(".new.question.name").val()
    description = $(".new.question.description").val()
    election.addQuestion({
      name: name
      description: description
      options: {
        type: "pick"
        voteMode: "single"
        allowAbstain: true
        allowIncompleteRanking: false
      }
    })
    election.update((err) ->
      if not err
        $(".new.question.name").val("")
        $(".new.question.description").val("")
      else
        alert("Error: " + err.message)
    )
  "click .submitChoice": (e, template) ->
    e.preventDefault()
    id = e.target.value
    election = Election.getActive()
    questionId = @_id
    name = $("#new-choice-name-" + id).val()
    description = $("#new-choice-description-" + id).val()
    image = $("#new-choice-image-" + id).val()
    election.addChoice(questionId, {
      name: name
      description: description
      image: image
    })
    election.update((err) ->
      if not err
        $("#new-choice-name-" + id).val("")
        $("#new-choice-description-" + id).val("")
        $("#new-choice-image-" + id).val("")
      else
        alert("Error: " + err.message)
    )

  "click .delete-election": (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to delete this election?")
      election = Election.getActive()
      Meteor.call("deleteElection", election._id)
      Router.go("admin")

  "click .reset-election": (e) ->
    e.preventDefault()
    election = Election.getActive()
    if confirm("Are you sure you want to reset this election?"
      + " All votes will be discarded")
      Meteor.call("resetElection", election._id)

  "change .allowAbstain": (e) ->
    election = Election.getActive()
    question = election.getQuestion($(e.target).attr("data-questionId"))
    question.options.allowAbstain = $(e.target).prop("checked")
    election.changed()

  "change .allowIncompleteRanking": (e) ->
    election = Election.getActive()
    question = election.getQuestion($(e.target).attr("data-questionId"))
    question.options.allowIncompleteRanking = $(e.target).prop("checked")
    election.changed()

  "change .vote-type": (e) ->
    election = Election.getActive()
    question = election.getQuestion($(e.target).attr("data-questionId"))
    question.options.type = e.target.value
    if e.target.value == "pick"
      question.options.voteMode = "single"
    if e.target.value == "rank"
      question.options.voteMode = "simple"
      delete question.options.pickNVal
    election.changed()

  "change .vote-mode": (e, template) ->
    election = Election.getActive()
    question = election.getQuestion($(e.target).attr("data-questionId"))
    question.options.voteMode = e.target.value
    switch e.target.value
      when "pickN"
        question.options.pickNVal = 1
      else
        delete question.options.pickNVal
    election.changed()

  "blur .pickNVal": (e) ->
    election = Election.getActive()
    question = election.getQuestion($(e.target).attr("data-questionId"))
    question.options.pickNVal = parseInt(e.target.value)
    election.changed()

