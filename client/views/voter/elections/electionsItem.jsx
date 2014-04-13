/** @jsx React.DOM */

ElectionsItem = React.createClass({
  goToElection: function() {
    Router.go("electionsShow", {slug: this.props.election.slug});
  },
  render: function() {
    return(
      <a onClick={this.goToElection}>
        <div className="election-list-item">
          <h3 className="ballot-name">
            {this.props.election.name}
          </h3>
          <h3 className="right-arrow"> > </h3>
        </div>
      </a>
    );
  }
});
