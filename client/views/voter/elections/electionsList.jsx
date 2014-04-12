/** @jsx React.DOM */

ElectionsList = ReactMeteor.createClass({
  getMeteorState: function() {
    console.log("computation rerun");
    return {
      electionNodes: Elections.find().map(function(election) {
        return <ElectionsItem election={election} />;
      })
    };
  },
  render: function() {
    return(
      <div>
        <h1>This is the Elections List</h1>
        {this.state.electionNodes}
      </div>
    );
  }
});

