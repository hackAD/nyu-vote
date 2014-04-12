Template.electionsAdminModify.helpers
  allowAbstain: () ->
    return if this.options.allowAbstain == true then "checked" else ""
  multi: () ->
    return if this.options.multi == true then "checked" else ""
  groups: () ->
    return Groups.find()
  hasGroup: (id, groups) ->
    console.log "checking group"
    console.log id
    console.log groups
    return if id in groups then "checked" else ""

Template.electionsAdminModify.events
  "click .submitElection, submit .election-form": (e) ->
    e.preventDefault()
    groups = $(".election.groups").val()
    #Elections.update({_id: this._id},$set:{name: name,description: description},$addToSet:{groups:$each:groups})
    oldElection = Elections.findOne(this._id)
    questionIndex = -1
    choiceIndex = -1
    Session.set("modifyingElection", "0")
    values = $('.election-form').serializeArray()
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
  "click .cancelSubmitElection": (e) ->
    e.preventDefault()
    Session.set("modifyingElection", "0")
  "click .submitQuestion": (e) ->
    e.preventDefault()
    name = $(".new.question.name").val()
    description = $(".new.question.description").val()
    if $(".new.question.allowAbstain").attr('checked') == "checked"
      allowAbstain = true 
    else 
      allowAbstain = false
    if $(".new.question.multi").attr('checked') == "checked"
      multi = true 
    else 
      multi = false
    Meteor.call("createQuestion", name, description, this._id, {allowAbstain: allowAbstain, multi: multi})
  "click .submitChoice": (e) ->
    e.preventDefault()
    name = $(".new.choice.name").val()
    description = $(".new.choice.description").val()
    image = $(".new.choice.image").val()
    console.log "creating choice"
    console.log name
    Meteor.call("createChoice", name, description, this._id, image)
