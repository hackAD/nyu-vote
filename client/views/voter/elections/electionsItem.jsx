/** @jsx React.DOM */

ElectionsItem = React.createClass({
  goToElection: function() {
    Router.go("electionsShow", {slug: this.props.election.slug});
  },
  render: function() {
    return(
      <a onClick={this.goToElection}>
        <div className="election-list-item">
          <h3>
            {this.props.election.name}
          </h3>
          <p className="right-arrow"> > </p>
        </div>
      </a>
    );
  }
});
