ElectionsVote = React.createClass({
  mixins: [ReactMeteorData],
  getMeteorData: function() {
    var activeElection = Election.getActive();
    var activeBallot = Ballot.getActive();
    return {
      election: activeElection,
      question: activeElection.getActiveQuestion(),
      ballot: activeBallot,
      questionIndex: activeElection.getActiveQuestionIndex()
    };
  },
  beginVote: function() {
    Router.go("electionsVote", {slug: this.data.election.slug, questionIndex: 0});
  },
  render: function() {
    var election = this.data.election;
    var questionIndex = this.data.questionIndex;
    var ballot = this.data.ballot;
    var question = this.data.question;
    var options = question.options;

    var optionsMessage;
    switch (options.type) {
      case "pick":
        switch(options.voteMode) {
          case "single":
            optionsMessage = "Pick Single Candidate";
            break;
          case "multi":
            optionsMessage = "Pick Any Number of Candidates";
            break;
          case "pickN":
            optionsMessage = "Pick " + options.pickNVal.toString() + " Candidate" + (options.pickNVal === 1 ? "" : "s");
            break;
          default:
            throw new Error("voteMode during single pick not one of three possible modes");
        }
        break;
      case "rank":
        if (options.forceFullRanking) {
          optionsMessage = "Rank All Candidates";
        }
        else {
          optionsMessage = "Rank Any Number of Candidates";
        }
        break;
      default:
        throw new Error("Vote type was neither rank nor pick");
    }

    var choices = [];
    var randomMap = election.getRandomQuestionMap(questionIndex);
    var hasNoConfidence = false;
    for (var i = 0, length = question.choices.length; i < length; i++) {
      var choice = election.getRandomChoice(questionIndex, i);
      var trueIndex = randomMap[i];
      if (choice.name !== "No Confidence") {
        choices.push(
          <ElectionsChoice question={question} ballot={ballot} choice={choice} choiceIndex={trueIndex} questionIndex={questionIndex} isAbstain={false} />
        );
      }
      else {
        // Don't add No Confidence now as we want it to be the last option for aesthetics
        // but make sure we know that we have to add it later
        if (hasNoConfidence) {
          // Can't have more than one No Confidence option
          throw new Error("There was more than one No Confidence option");
        }
        hasNoConfidence = true;
      }
    }
    // Put No Confidence option last, but before Abstain
    if (hasNoConfidence) {
      var infoMessage = "";
      if (options.type === "rank") {
        infoMessage = "\
All candidates ranked lower than this No Confidence option will be considered as you having no confidence in them. \
These lower ranks will function as: \"in the worst case that one of these candidates will be elected, I would rather have this candidate\"\
";
      }
      choices.push(
        // Adding the infoMessage prop adds the info button to the right of the title
        <ElectionsChoice question={question} ballot={ballot} choice={choice} choiceIndex={trueIndex} questionIndex={questionIndex} isAbstain={false} infoMessage={infoMessage} />
      );
    }
    if (question.options.allowAbstain)
      choices.push(
        <ElectionsChoice question={question} ballot={ballot} questionIndex={questionIndex} isAbstain={true} />
      );
    return(
      <div id="voting-screen">
        <div className="header white-bg">
          <a className="header-exit" href={Router.path("home")}>{"<  "}Exit</a>
            {election.name}
          <a className="header-help" href={Router.path("help")}>
            Help
          </a>
        </div>
        <div className="deep-blue-bg">
          <div className="centered-container">
            <h2>{question.name}</h2>
            <h3 id="options-message">{optionsMessage}</h3>
            <p className="body-text">{question.description}</p>
          </div>
        </div>
        <div>
          {choices}
        </div>
        <ElectionsFooter ballot={ballot} election={election} questionIndex={questionIndex} />
      </div>
    );
  }
});
