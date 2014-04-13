/** @jsx React.DOM */

ElectionsVote = ReactMeteor.createClass({
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

    var choices = [];
    var randomMap = election.getRandomQuestionMap(questionIndex);
    for (var i = 0, length = question.choices.length; i < length; i++) {
      var choice = election.getRandomChoice(questionIndex, i);
      var trueIndex = randomMap[i];
      choices.push(
        <ElectionsChoice ballot={ballot} choice={choice} choiceIndex={trueIndex} questionIndex={questionIndex} isAbstain={false} />
      );
    }
    if (question.options.abstain)
      choices.push(
        <ElectionsChoice ballot={ballot} isAbstain={true} />
      );
    return(
      <div>
        <div>
          <a href={Router.path("home")}>Exit</a>
          <h1>{election.name}</h1>
        </div>
        <div>
          <h2>{question.name}</h2>
          <p>{question.description}</p>
        </div>
        <div>
          {choices}
        </div>
        <ElectionsFooter ballot={ballot} election={election} questionIndex={-1} />
      </div>
    );
  }
});
