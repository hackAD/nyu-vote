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
        <div className="white-bg header">
          <a href={Router.path("home")}>
            {"< "}Exit
          </a>
          ballot description
        </div>
        <div id="ballot-description-wrapper" className="dark-blue-bg">
          <div className="centered-container">
            <h1>{this.state.election.name}</h1>
            <p>{this.state.election.description}</p>
            <a className="large-button" href={Router.path("electionsVote", {slug: this.state.election.slug, questionIndex: 0})}>Start Ballot {"  >"}</a>
          </div>
        </div>
      </div>
    );
  }

});
