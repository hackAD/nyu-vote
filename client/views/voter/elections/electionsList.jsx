ElectionsList = React.createClass({
  getInitialState: function() {
    return {
      isAdmin: Groups.find().count() > 0,
    };
  },
  mixins: [ReactMeteorData],
  getMeteorData: function() {
    var votedElections = Ballots.find().map(function(ballot) {return ballot.electionId;});
    var openElections = Elections.find({_id: {$nin: votedElections}});
    var closedElections = Elections.find({_id: {$in: votedElections}});
    return {
      openElectionsCount: openElections.count(),
      openElectionNodes: openElections.map(function(election) {
        return <ElectionsItem election={election} open={true} />;
      }),
      closedElectionNodes: closedElections.map(function(election) {
        return <ElectionsItem election={election} open={false} />;
      })
    };
  },
  logout: function() {
    Meteor.logout(function() {
      window.location = "http://accounts.google.com/logout";
    });
  },
  componentWillReceiveProps: function() {
    this.setState({isAdmin: Groups.find().count() > 0})
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
              <h1>{this.data.openElectionsCount}</h1>
              <h3>Open Ballots</h3>
            </div>
            {this.data.openElectionNodes}
          </div>
        </div>
        <div className="dark-blue-bg">
          <div className="centered-container">
            <h2>Closed Ballots</h2>
            {this.data.closedElectionNodes}
          </div>
        </div>
        <div id="ballot-list-footer" className="dark-blue-bg">
          <div className="centered-container">
            <a className="large-button" href="#" onClick={this.logout}>Logout</a>
          </div>
          <a className="login-caption info-link" href={Router.path("help")}>
            Get Help
          </a>
          <br/>
          <a className="login-caption info-link" href={Router.path("about")}>
            About This Project
          </a>
          <br/>
          { // This was uncommented as the reactive routing made elections go haywire due to
            // Tracker.recompute if you fix it just uncomment this to get the go to admin page working again
          /*this.state.isAdmin ?
            <a className="login-caption info-link" href={Router.path("admin")}>
              Go to Admin Page
            </a>
            : null */ null
          }
        </div>
      </div>
    );
  }
});

