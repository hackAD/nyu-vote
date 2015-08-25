Template.voterView.rendered = function() {
  var self = this;
  Deps.autorun(function() {
    switch(Router.current().route.getName()) {
      case "home":
        Deps.autorun(function() {
          if (Meteor.userId())
            React.render(
              <ElectionsList />,
              self.find("#container")
            );
          else
            React.render(
              <Home />,
              self.find("#container")
            );
        });
        break;
      case "electionsShow":
        React.render(
          <ElectionsShow />,
          self.find("#container")
        );
        break;
      case "electionsVote":
        React.render(
          <ElectionsVote />,
          self.find("#container")
        );
        break;
      case "electionsReview":
        React.render(
          <ElectionsReview />,
          self.find("#container")
        );
        break;
    }
  });
};
