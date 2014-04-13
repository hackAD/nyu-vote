/** @jsx React.DOM */

ElectionsFooter = React.createClass({
  getButton: function() {
    var questionIndex = this.props.questionIndex;
    var ballot = this.props.ballot;
    var question = ballot.questions[questionIndex];
    var button;
    if (questionIndex === -1) {
      button = <a href="#" onClick={this.vote}>Cast Vote</a>;
    } else if (questionIndex == question.choices.length -1)
      button = <a href="#" onClick={this.vote}>Review Ballot</a>;
    else
      button = <a href="#" onClick={this.vote}>Next</a>;
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
