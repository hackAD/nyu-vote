/** @jsx React.DOM */


var ElectionList = React.createClass({
  login: function() {
    Meteor.loginWithGoogle({
      requestPermissions: ["email"],
      requestOfflineToken: true
    });
    return false;
  },
  render: function() {
    return (
      <div>
        <h1>
          This is the page where The election data is shown
        </h1>
        <a onClick={this.login}>
          Link
        </a>
      </div>
    );
  }
});

Template.home.rendered = function() {
  React.renderComponent(
    <ElectionList />,
    this.find("#container")
  );
};
