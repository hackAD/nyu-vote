/** @jsx React.DOM */

ElectionsShow = ReactMeteor.createClass({
  getMeteorState: function() {
    return {
      election: Election.getActive()
    };
  },
  beginVote: function() {
    Router.go("electionsVote", {slug: this.state.election.slug, page: 0});
  },
  render: function() {
    return(
      <div>
        <h1>{this.state.election.name}</h1>
        <p>{this.state.election.description}</p>
        <button onClick={beginVote}>Cast Your Ballot</button>
      </div>
    );
  }

});
