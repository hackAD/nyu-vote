/** @jsx React.DOM */

ElectionsList = ReactMeteor.createClass({
  getMeteorState: function() {
    return {
      openElectionNodes: Elections.find().map(function(election) {
        return <ElectionsItem election={election} open={true} />;
      }),
      closedElectionNodes: Elections.find().map(function(election) {
        return <ElectionsItem election={election} open={false} />;
      })
    };
  },
  render: function() {
    return(
      <div>
        <h1>This is the Elections List</h1>
        <div>
          {this.state.openElectionNodes}
        </div>
        <div>
          {this.state.closedElectionNodes}
        </div>
      </div>
    );
  }
});

