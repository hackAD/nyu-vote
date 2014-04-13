/** @jsx React.DOM */

ElectionsList = ReactMeteor.createClass({
  getMeteorState: function() {
    var openElections = Elections.find();
    var closedEections = Elections.find();
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
        <div>
          Welcome {Meteor.user().profile.name}
        </div>
        <div className="light-green-bg">
          <div>
            <h2>You have</h2>
            <h1>{this.state.openElectionsCount}</h1>
            <h2>Open Ballots</h2>
            {this.state.openElectionNodes}
          </div>
        </div>
        <div>
          <h2>Closed Ballots</h2>
          {this.state.closedElectionNodes}
        </div>
        <a href="#" onClick={this.logout}>Logout</a>
      </div>
    );
  }
});

