/** @jsx React.DOM */

ElectionsShow = ReactMeteor.createClass({
  getMeteorState: function() {
    return {
      election: Election.getActive()
    };
  },
  render: function() {
    return(
      <div>
        <a href={Router.path("home")}>Exit</a>
        <h1>{this.state.election.name}</h1>
        <p>{this.state.election.description}</p>
        <a href={Router.path("electionsVote", {slug: this.state.election.slug, questionIndex: 0})}>Cast Your Ballot</a>
      </div>
    );
  }

});
