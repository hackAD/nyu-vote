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
    var choiceFilter = function(choice, index) {
      var ballotChoice = ballot.questions[i].choices[index];
      console.log(i)
      console.log(index)
      console.log(ballot);
      console.log(ballotChoice)
      return ballotChoice.value === true;
    };
    var choiceMap = function(choice) {
      return(
        <div>
          <h1>{choice.name}</h1>
          <p>{choice.description}</p>
        </div>
      );
    };
    for (var i = 0, length = election.questions.length; i < length; i++) {
      var question = election.questions[i];
      // TODO: implement for rank
      if (question.options.type == "pick") {
        var selectedChoices;
        selectedChoices = _.filter(question, choiceFilter);
        var selectedChoicesNodes = _.map(selectedChoices, choiceMap);
        questionNodes.push(
          <div>
            <div>
              <h1>{question.name}</h1>
              <p>{question.description}</p>
            </div>
            {selectedChoicesNodes}
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
