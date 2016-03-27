ElectionsReview = React.createClass({
  mixins: [ReactMeteorData],
  getMeteorData: function() {
    var activeElection = Election.getActive();
    var activeBallot = Ballot.getActive();
    return {
      election: activeElection,
      ballot: activeBallot,
    };
  },
  render: function() {
    var election = this.data.election;
    var ballot = this.data.ballot;
    var questionNodes = [];
    var choiceMapFunction = function(choice) {
      return(
        <div className="light-green-bg">
          <div className="green-bg">
            <h2 className="centered-container">{choice.name}</h2>
          </div>
          <div className="centered-container">
            <ElectionsChoiceImage choice={choice} />
            <p className="body-text">{choice.description}</p>
            <a className="large-button" href={Router.path("electionsVote", {slug: election.slug, questionIndex: i}) }>Change</a>
          </div>
        </div>
      );
    };
    for (var i = 0, length = election.questions.length; i < length; i++) {
      var question = election.questions[i];
      var isValid = ballot.validate(i);
      var classNames = React.addons.classSet({
        valid: isValid,
        invalid: !isValid
      });
      // TODO: implement for rank
      if (question.options.type == "pick") {
        var selectedChoices = ballot.selectedChoices(i);
        var selectedChoicesNodes = _.map(selectedChoices, choiceMapFunction);
        // if (selectedChoicesNodes.length === 0)
        //   selectedChoicesNodes = (
        //     <div>
        //       <h3>No Option Selected</h3>
        //     </div>
        //   );
        questionNodes.push(
          <div className="light-blue-bg">
            <div className="centered-container" id="question-container">
              <h2>{question.name}</h2>
            </div>
            {isValid ?
              null :
              <div className="incomplete-bg">
                <div className="centered-container">
                  <h2>question not complete</h2>
                  <a className="large-button" href={Router.path("electionsVote", {slug: election.slug, questionIndex: i}) }>Change</a>
                </div>
              </div>
            }
            {selectedChoicesNodes}
          </div>
        );
      }
    }
    return(
     <div id="review-screen">
        <div className="header white-bg">
          <a className="header-exit" href={Router.path("home")}>
            {"< "}Exit
          </a>
          {election.name}
          <a className="header-help" href={Router.path("help")}>
            Get Help
          </a>
        </div>
        <div className="deep-blue-bg">
          <h2>Please review your ballot</h2>
        </div>
        <div>
          {questionNodes}
        </div>
        <ElectionsFooter ballot={ballot} election={election} questionIndex={-1} />
      </div>
    );
  }
});
