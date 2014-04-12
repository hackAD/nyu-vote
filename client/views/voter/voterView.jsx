/** @jsx React.DOM */

Template.voterView.rendered = function() {
  var self = this;
  switch(Router.current().route.name) {
    case "home":
      Deps.autorun(function() {
        if (Meteor.user())
          React.renderComponent(
            <ElectionsList />,
            self.find("#container")
          );
        else
          React.renderComponent(
            <Home />,
            self.find("#container")
          );
      });
      break;
    case "electionsShow":
      React.renderComponent(
        <ElectionsShow />,
        this.find("#container")
      );
      break;
  }
};
