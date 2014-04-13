/** @jsx React.DOM */

ElectionsFooter = React.createClass({
  getButton: function() {
    var questionIndex = parseInt(this.props.questionIndex);
    var ballot = this.props.ballot;
    var election = this.props.election;
    var question = ballot.questions[questionIndex];
    var button;
    if (questionIndex === -1) {
      button = <a href="#" onClick={this.vote}>Cast Vote</a>;
    } else if (questionIndex == election.questions.length - 1)
      button = <a href={Router.path("electionsReview", {slug: election.slug})}>Review Ballot</a>;
    else
      button = <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})}>Next</a>;
    return button;
  },
  render: function() {
    var self = this;
    var progressBar = _.map(self.props.election.questions, function(question, index) {
      return(
        <a href={Router.path("electionsVote", {slug: self.props.election.slug, questionIndex: index})}>
          GoTo {index}
        </a>
      );
    });
    progressBar.push(
      <a href={Router.path("electionsReview", {slug: this.props.election.slug})}>
        Go to Summary
      </a>
    );
    return(
      <div>
        {progressBar}
        {this.getButton()}
      </div>
    );
  }

});
