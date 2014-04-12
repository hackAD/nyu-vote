root = global ? window

root.Ballots = new Meteor.Collection("ballots")

class Ballot extends ReactiveClass(Ballots)
  constructor: (fields) ->
    _.extends(@, fields)
    Election.initialize.call(@)

  generateBallot: (election, user) ->
    ballot = new this()
    ballot.netId = user.getNetId()
    ballot.electionId = election._id
    # Transform each question
    questions = _.map(election.questions, (question) ->
      transformedQuestion = _.without(question,
        "description", "name", "choices")
      # Transform each choice
      transformedQuestion.choices = _.map(question.choices, (choice, index) ->
        transformedChoice = _.without(choice,
          "description", "image", "name", "votes")
        transformedChoice.value = switch (question.options.type)
          when "pick" then {
            selected: "no"
          }
          when "rank" then {
            rank: 0
          }
          else {
            selected: "no"
          }
        return transformedChoice
      )
      if (transformedQuestion.options.allowAbstain)
        transformedChoice.push({
          name: "abstain"
          _id: "abstain"
          value: "true"
        })
      return transformedQuestion
    )
    return ballot

