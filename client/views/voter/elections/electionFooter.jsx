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
        Meteor.setTimeout(function() {
          Router.go("home");
        }, 1500);
    });
  },
  getButton: function(currentValid, allValid) {
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
      else {
        if (allValid)
          button = <a href="#" onClick={this.vote}>Cast Ballot</a>;
        else
          button = <a href="#" className="disabled">Ballot Incomplete</a>;
      }
    } else if (questionIndex == election.questions.length - 1) {
      if (allValid)
        button = <a href={Router.path("electionsReview", {slug: election.slug})}>Review Ballot</a>;
      else
        button = <a href="#" className="disabled">Ballot Incomplete</a>;
    }
    else {
      if (currentValid)
        button = <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})}>Next</a>;
      else
        button = <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})} className="disabled">Next</a>;
    }
    return button;
  },
  render: function() {
    var self = this;
    var currentValid, allValid;
    var progressBar = _.map(self.props.election.questions, function(question, index) {
      var isValid = self.props.ballot.validate(index);
      if (self.props.questionIndex == index)
        currentValid = isValid;
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
    allValid = this.props.ballot.isValid();
    classes = React.addons.classSet({
      active: -1 == self.props.questionIndex,
      valid: allValid,
      invalid: !allValid,
      last: true
    });
    progressBar.push(
      <a className={classes} href={Router.path("electionsReview", {slug: this.props.election.slug})}>
        Go to Summary
      </a>
    );
    return(
      <div>
        {progressBar}
        {this.getButton(currentValid, allValid)}
      </div>
    );
  }

});
