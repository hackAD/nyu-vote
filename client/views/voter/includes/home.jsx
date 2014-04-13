/** @jsx React.DOM */


Home = React.createClass({
  login: function() {
    Meteor.loginWithGoogle({
      requestPermissions: ["email"],
      requestOfflineToken: true
    });
    return false;
  },
  loginWithDummy: function() {
    Meteor.loginWithPassword("devAdmin", "password");
  },
  render: function() {
    return (
      <div className="content-wrapper purple-bg">
        <div id="login-info">
          <h1>
            NYU Vote
          </h1>
          <a id="login-button" href="#" onClick={this.login}>
            Sign in
          </a>
          <a href="#" onClick={this.loginWithDummy}>
            Login With Dummy
          </a>
        </div>
      </div>
    );
  }
});

