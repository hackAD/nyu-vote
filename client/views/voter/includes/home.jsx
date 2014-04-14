/** @jsx React.DOM */

Home = React.createClass({
  login: function() {
    Meteor.loginWithGoogle({
      requestPermissions: ["email"],
      requestOfflineToken: true
    });
    return false;
  },
  render: function() {
    return (
      <div className="content-wrapper purple-bg">
        <div id="login-info">
          <h1>
            NYU Vote
          </h1>
          <div className="centered-container">
            <a className="large-button" href="#" onClick={this.login}>
              Sign in
            </a>
          </div>
        </div>
      </div>
    );
  }
});

