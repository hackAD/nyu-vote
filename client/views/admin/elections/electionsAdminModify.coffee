questionCount = 0
choiceCount = 0
Template.electionsAdminEdit.helpers
  election: () ->
    questionCount = 0
    return Election.getActive()
  allowAbstain: () ->
    return if this.options.allowAbstain then "checked" else null
  multi: () ->
    return if this.options.multi == true then "checked" else null
  canEdit: () ->
    this.status == "unopened"
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
  questionCount: () ->
    choiceCount = 0
    questionCount += 1
    return questionCount
  choiceCount: () ->
    choiceCount += 1
    return choiceCount

Template.electionsAdminEdit.events
  "click .save-election, submit .election-form": (e) ->
    e.preventDefault()
    groups = $(".election.groups").val()
    oldElection = @
    questionIndex = -1
    choiceIndex = -1
    values = $('form').serializeArray()
    allowAbstain = $('')
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
          oldElection.questions[questionIndex].options.allowAbstain = false
          oldElection.questions[questionIndex].options.multi = false
        when "questionDescription"
          oldElection.questions[questionIndex].description = field.value
        when "questionAllowAbstain"
          oldElection.questions[questionIndex].options.allowAbstain = if field.value == "on" then true else false
        when "questionMulti"
          oldElection.questions[questionIndex].options.multi = if field.value == "on" then true else false
        when "choiceName"
          choiceIndex += 1
          oldElection.questions[questionIndex].choices[choiceIndex].name = field.value
        when "choiceDescription"
          oldElection.questions[questionIndex].choices[choiceIndex].description = field.value
        when "choiceImage"
          oldElection.questions[questionIndex].choices[choiceIndex].image = field.value
    Elections.update(
      {_id: this._id},
      $set:
        name: oldElection.name
        description: oldElection.description
        questions: oldElection.questions
        groups: newGroups
    )
  "click .submitQuestion": (e) ->
    e.preventDefault()
    election = Election.getActive()
    name = $(".new.question.name").val()
    description = $(".new.question.description").val()
    if $(".new.question.allowAbstain").is(':checked')
      allowAbstain = true
    else
      allowAbstain = false
    if $(".new.question.multi").is(':checked')
      multi = true
    else
      multi = false
    election.addQuestion({
      name: name
      description: description
      options: {
        type: "pick"
        allowAbstain: allowAbstain
        multi: multi
      }
    })
    election.update((err) ->
      if not err
        $(".new.question.name").val("")
        $(".new.question.description").val("")
        $(".new.question.multi").attr("checked", false)
        $(".new.question.allowAbstain").attr("checked", false)
      else
        Meteor.userError.throwError(err.message)
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
        Meteor.userError.throwError(err.message)
    )

  "click .delete-election": (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to delete this election?")
      election = Election.getActive()
      election.remove()
      Router.go("admin")
