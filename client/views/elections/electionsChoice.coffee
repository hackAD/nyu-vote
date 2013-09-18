Template.electionsChoice.helpers
  imageExists: () ->
    return this.image.length > 1
  choiceClass: () ->
    return if this.abstain? then "abstain chosen" else "choice"
