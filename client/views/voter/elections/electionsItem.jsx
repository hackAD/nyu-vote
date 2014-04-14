/** @jsx React.DOM */

ElectionsItem = React.createClass({
  render: function() {
    return(
      <a href={this.props.open ? Router.path("electionsShow", {slug: this.props.election.slug}) : "#"}>
        <div className="election-list-item">
          <h3 className="ballot-name">
            {this.props.election.name}
          </h3>
          {this.props.open ?
            <h3 id="right-arrow"> > </h3>
            : null
          }
        </div>
      </a>
    );
  }
});
