/** @jsx React.DOM */

ElectionsReview = ReactMeteor.createClass({
  getMeteorState: function() {
    var activeElection = Election.getActive();
    var activeBallot = Ballot.getActive();
    return {
      election: activeElection,
      ballot: activeBallot,
    };
  },
  render: function() {
    var election = this.state.election;
    var ballot = this.state.ballot;
    var questionNodes = [];
    var choiceMapFunction = function(choice) {
      return(
        <div>
          <h1>{choice.name}</h1>
          <p>{choice.description}</p>
          <ElectionsChoiceImage choice={choice} />
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
        if (selectedChoicesNodes.length === 0)
          selectedChoicesNodes = (
            <div>
              <h3>No Option Selected</h3>
            </div>
          );
        questionNodes.push(
          <div>
            <div className={classNames}>
              <h1>{question.name}</h1>
              <p>{question.description}</p>
            </div>
            {isValid ?
              null :
              <h2>This question has not been completed</h2>
            }
            {selectedChoicesNodes}
            <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: i}) }>Change</a>
          </div>
        );
      }
    }
    return(
     <div>
        <div>
          <a href={Router.path("home")}>Exit</a>
          <h1>{election.name}</h1>
        </div>
        <div>
          Please review your ballot:
        </div>
        <div>
          {questionNodes}
        </div>
        <ElectionsFooter ballot={ballot} election={election} questionIndex={-1} />
      </div>
    );
  }
});
