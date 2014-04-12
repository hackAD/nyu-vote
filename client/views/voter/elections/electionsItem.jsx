/** @jsx React.DOM */

ElectionsItem = React.createClass({
  goToElection: function() {
    Router.go("electionsShow", {slug: this.props.election.slug});
  },
  render: function() {
    return(
      <div>
        <h1>
          {this.props.election.name}
        </h1>
        <div>
          {this.props.election.description}
        </div>
        <button>Vote</button>
      </div>
    );
  }
});
