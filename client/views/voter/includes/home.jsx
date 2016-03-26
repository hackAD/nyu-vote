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
        <img id="stugov-logo" src="/stugov_logo.png" />
        <div id="login-info">
          <h1>
            Student Vote
          </h1>
          <p className="login-caption">
            Designed, Developed, and Supported under the auspices of NYU Student Government
          </p>
          <div className="centered-container">
            <a className="large-button" href="#" onClick={this.login}>
              Sign in
            </a>
          </div>
          <a className="login-caption info-link" href={Router.path("help")}>
            Get Help
          </a>
          <br/>
          <a className="login-caption info-link" href={Router.path("about")}>
            About This Project
          </a>
        </div>
      </div>
    );
  }
});

