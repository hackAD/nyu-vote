/** @jsx React.DOM */

ElectionsList = ReactMeteor.createClass({
  getMeteorState: function() {
    var votedElections = Ballots.find().map(function(ballot) {return ballot.electionId;});
    var openElections = Elections.find({_id: {$nin: votedElections}});
    var closedEections = Elections.find({_id: {$in: votedElections}});
    return {
      openElectionsCount: openElections.count(),
      openElectionNodes: openElections.map(function(election) {
        return <ElectionsItem election={election} open={true} />;
      }),
      closedElectionNodes: closedEections.map(function(election) {
        return <ElectionsItem election={election} open={false} />;
      })
    };
  },
  logout: function() {
    Meteor.logout();
  },
  render: function() {
    return(
      <div id="election-list">
        <div className="white-bg header">
          Welcome {Meteor.user().profile.name}
        </div>
        <div className="light-green-bg">
          <div className="centered-container">
            <div id="ballot-counter">
              <h3>You have</h3>
              <h1>{this.state.openElectionsCount}</h1>
              <h3>Open Ballots</h3>
            </div>
            {this.state.openElectionNodes}
          </div>
        </div>
        <div className="dark-blue-bg">
          <div className="centered-container">
            <h2>Closed Ballots</h2>
            {this.state.closedElectionNodes}
          </div>
        </div>
        <div className="centered-container">
          <a className="large-button" href="#" onClick={this.logout}>Logout</a>
        </div>
        <a href={Router.path("about")} alt="about" class="soft">About This Project</a>
      </div>
    );
  }
});

