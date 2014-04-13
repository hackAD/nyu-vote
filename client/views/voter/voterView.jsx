/** @jsx React.DOM */

Template.voterView.rendered = function() {
  var self = this;
  Deps.autorun(function() {
    switch(Router.current().route.name) {
      case "home":
        Deps.autorun(function() {
          if (Meteor.userId())
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
          self.find("#container")
        );
        break;
      case "electionsVote":
        React.renderComponent(
          <ElectionsVote />,
          self.find("#container")
        );
        break;
      case "electionsReview":
        React.renderComponent(
          <ElectionsReview />,
          self.find("#container")
        );
        break;
    }
  });
};
