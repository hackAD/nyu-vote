/** @jsx React.DOM */

Template.voterView.rendered = function() {
  switch(Router.current().route.name) {
    case "home":
      React.renderComponent(
        <Home />,
        this.find("#container")
      );
      break;
  }
};
