Template.electionsQuestions.helpers
  "abstain": () ->
    return {
      name: "Abstain"
      description: ""
      image: ""
      abstain: true
    }
  "required": () ->
    return !this.options.allowAbstain
