/** @jsx React.DOM */


        // <a href="#" onClick={this.loginWithDummy}>
        //   Login With Dummy
        // </a>


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
        <h1>
          NYU Vote
        </h1>
        <a id="login-button" href="#" onClick={this.login}>
          Sign in
        </a>
      </div>
    );
  }
});

