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
            Student Vote
          </h1>
          <p className="login-caption">
            Designed, Developed, and Supported under the auspices of NYU Student Government
          </p>
          <a className="login-caption light-grey" href={Router.path("about")}>
            Get Help
          </a>
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

