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
          button = <a className="large-button review-final" href="#" onClick={this.vote}>Cast Ballot</a>;
        else
          button = <a href="#" className="disabled large-button">Incomplete</a>;
      }
    } else if (questionIndex == election.questions.length - 1) {
      if (allValid)
        button = <a className="review large-button" href={Router.path("electionsReview", {slug: election.slug})}>Review Ballot</a>;
      else
        button = <a href="#" className="disabled large-button">Incomplete</a>;
    }
    else {
      if (currentValid)
        button = <a className="large-button button-black" href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})}>Next</a>;
      else
        button = <a href={Router.path("electionsVote", {slug: election.slug, questionIndex: questionIndex + 1})} className="disabled large-button">Next</a>;
    }
    return button;
  },
  render: function() {
    var questionIndex = parseInt(this.props.questionIndex);
    if (questionIndex > -1)
      var totalQuestions = this.props.election.questions[questionIndex].choices.length;
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
        <a href={Router.path("electionsVote", {slug: self.props.election.slug, questionIndex: index})}>
          <div className={classes + " progress-circle"}></div>
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
      <a href={Router.path("electionsReview", {slug: this.props.election.slug})}>
        <div className={classes + " progress-circle"}></div>
      </a>
    );
    return(
      <div id="election-footer">
        <div id="election-footer-wrapper" className="centered-container">
          { questionIndex > -1 ? 
            <p>Progress: {questionIndex+1}/{totalQuestions}</p>
            : <p>Review Ballot</p>
          }
          {progressBar}
          {this.getButton(currentValid, allValid)}
        </div>
      </div>
    );
  }

});
