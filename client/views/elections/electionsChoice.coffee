Template.electionsChoice.helpers
  imageExists: () ->
    console.log "error"
    console.log this
    return this.image.length > 1
  choiceClass: () ->
    return this.abstain? "abstain" : "choice"
