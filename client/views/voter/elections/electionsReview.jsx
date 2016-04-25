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
    var choiceMapFunction = function(priority, choice, pick_or_abstain, last, abstain) {
      if (pick_or_abstain){
        return(
          <div className="light-green-bg">
            <div className="green-bg">
              <h2 className="centered-container">{choice.name}</h2>
            </div>
            <div className="centered-container">
              <ElectionsChoiceImage choice={choice} small={false} />
              <p className="body-text">{choice.description}</p>
              <a className="large-button" href={Router.path("electionsVote", {slug: election.slug, questionIndex: i}) }>Change</a>
            </div>
          </div>
        );
      }

      else{
        return(
          <div className="light-green-bg">
            <div className="centered-container">
              <h3>{priority.toString()}</h3>
              <br />
              <ElectionsChoiceImage choice={choice} small={true} />
              <br />
              <br />
              <h3>{choice.name}</h3>
            </div>
            {last ? <div className="centered-container"><a className="large-button" href={Router.path("electionsVote", {slug: election.slug, questionIndex: i}) }>Change</a></div> : null}
          </div>
          );
      }
    };

    for (var i = 0, length = election.questions.length; i < length; i++) {
      var question = election.questions[i];
      var isValid = ballot.validate(i);
      var classNames = React.addons.classSet({
        valid: isValid,
        invalid: !isValid
      });
      var selectedChoices = ballot.selectedChoices(i);
      var choicesValues = ballot.selectedChoices(i, true);
      choicesValues.sort(function(a, b){return a.value-b.value});
      var selectedChoicesNodes = [];
      for (var j = 0; j < selectedChoices.length; j++){
        var node;
        for (var k = 0; k < selectedChoices.length; k++){
          if (selectedChoices[k]._id == choicesValues[j]._id){
            node = selectedChoices[k];
            break;
          }
        }
        var is_pick_or_abstain = question.options.type=="pick" || (choicesValues.length == 1 && choicesValues[0]._id == "abstain");
        var is_last_node = j==selectedChoices.length-1;
        selectedChoicesNodes.push(choiceMapFunction(choicesValues[j].value, node, is_pick_or_abstain, is_last_node));
      }

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
              </div>
            </div>
          }
          {selectedChoicesNodes}
        </div>
      );
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
