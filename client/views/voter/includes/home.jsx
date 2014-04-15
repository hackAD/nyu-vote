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
          <p className="login-caption">
            Developed by NYU Abu Dhabi Research and Development. Sponsored by NYU SSC.
          </p>
          <a className="login-caption light-grey" href={Router.path("about")}>
            Learn More
          </a>
          <div className="centered-container">
            <a className="large-button" href="#" onClick={this.login}>
              Sign in
            </a>
          </div>
          <div className="centered-container">
            <a className="large-button" href="#" onClick={this.loginWithDummy}>
              Dummy
            </a>
          </div>
        </div>
      </div>
    );
  }
});

