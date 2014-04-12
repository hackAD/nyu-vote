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
    Meteor.loginWithPassword("devAdmin", "password", function(err) {

    });
  },
  render: function() {
    return (
      <div>
        <h1>
          This is the page where The election data is shown
        </h1>
        <a href="#" onClick={this.login}>
          Login With Google
        </a>
        <a href="#" onClick={this.loginWithDummy}>
          Login With Dummy
        </a>
      </div>
    );
  }
});

