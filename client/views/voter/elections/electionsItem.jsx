/** @jsx React.DOM */

ElectionsItem = React.createClass({
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
