Template.electionsChoice.helpers
  imageExists: () ->
    return this.image.length > 1
  choiceClass: () ->
    return this.abstain? "abstain" : "choice"
