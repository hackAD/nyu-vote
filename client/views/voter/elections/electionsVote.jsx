/** @jsx React.DOM */

ElectionsVote = ReactMeteor.createClass({
  getMeteorState: function() {
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
    Router.go("electionsVote", {slug: this.state.election.slug, questionIndex: 0});
  },
  render: function() {
    var election = this.state.election;
    var questionIndex = this.state.questionIndex;
    var ballot = this.state.ballot;
    var question = this.state.question;

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
      <div id="voting-screen">
        <div className="header white-bg">
          <a href={Router.path("home")}>{"<  "}Exit</a>
          {election.name}
        </div>
        <div className="deep-blue-bg">
          <div className="centered-container">
            <h2>{question.name}</h2>
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
