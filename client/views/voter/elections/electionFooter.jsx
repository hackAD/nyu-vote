/** @jsx React.DOM */

ElectionsFooter = React.createClass({
  getInitialState: function() {
    return {
      voting: false,
      hasVoted: this.props.ballot._id
    };
  },
  vote: function() {
    var self = this;
    var ballot = this.props.ballot;
    this.setState({voting: true});
    ballot.put(function(err) {
      self.setState({voting: false});
      if (err)
        Meteor.userError.throwError(err.reason);
      else
        self.setState({hasVoted: true});
    });
  },
  getButton: function() {
    var questionIndex = parseInt(this.props.questionIndex);
    var ballot = this.props.ballot;
    var election = this.props.election;
    var question = ballot.questions[questionIndex];
    var button;
    if (questionIndex === -1) {
      if (this.state.voting)
        button = <a href="#">Casting Ballot</a>;
      else if (this.hasVoted)
        button = <a href={Router.path("home")}>Ballot Cast</a>;
      else
        button = <a href="#" onClick={this.vote}>Cast Ballot</a>;
    } else if (questionIndex == election.questions.length - 1)
      button = <a href={Router.path("electionsReview", {slug: election.slug})}>Review Ballot</a>;
    else
      button = <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})}>Next</a>;
    return button;
  },
  render: function() {
    var self = this;
    var progressBar = _.map(self.props.election.questions, function(question, index) {
      isValid = self.props.ballot.validate(index);
      classes = React.addons.classSet({
        active: index == self.props.questionIndex,
        valid: isValid,
        invalid: !isValid
      });
      return(
        <a className={classes} href={Router.path("electionsVote", {slug: self.props.election.slug, questionIndex: index})}>
          GoTo {index}
        </a>
      );
    });
    isValid = this.props.ballot.isValid();
    classes = React.addons.classSet({
      active: -1 == self.props.questionIndex,
      valid: isValid,
      invalid: !isValid
    });
    progressBar.push(
      <a className={classes} href={Router.path("electionsReview", {slug: this.props.election.slug})}>
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
