Template.electionsChoice.helpers
  imageExists: () ->
    return this.image.length > 1
  choiceClass: () ->
    return if this.abstain? then "abstain chosen" else "choice"
  profileImage: () ->
    return if this.image.length > 0 then this.image else "http://www.pentagram.com/en/NYUAD_Pattern_620W.gif"
