ElectionsList = React.createClass({
  getInitialState: function() {
    return {
      isAdmin: false,
      lastUserNetId: null
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
  render: function() {
    var user = Meteor.user()
    // The if statement is to avoid an infinite loop of renders.
    // Since it is being done asynchronously if we don't do a check here
    // it will be running the render function 100 times per second
    if (user.profile.netId !== this.state.lastUserNetId) {
      Meteor.call("getAdminGroups", user, function(error, result) {
        var whitelist = result.whitelist;
        var globalAdminGroup = result.globalAdminGroup;
        var isAdmin =
          _.contains(globalAdminGroup.netIds, user.profile.netId) ||
          _.contains(globalAdminGroup.admins, user.profile.netId) ||
          _.contains(whitelist.netIds, user.profile.netId);
        this.setState({
          isAdmin: isAdmin,
          lastUserNetId: user.profile.netId,
        });
      }.bind(this));
    }

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
          {this.state.isAdmin ?
            <a className="login-caption info-link" href={Router.path("admin")}>
              Go to Admin Page
            </a>
            : null
          }
        </div>
      </div>
    );
  }
});

