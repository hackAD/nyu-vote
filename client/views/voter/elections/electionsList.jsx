/** @jsx React.DOM */

ElectionsList = ReactMeteor.createClass({
  getMeteorState: function() {
    console.log("computation rerun");
    return {
      electionNodes: Elections.find({name: "nyuad_2016_rep_election"}).map(function(election) {
        return <ElectionsItem election={election} />;
      })
    };
  },
  render: function() {
    console.log("I'm rerendering!");
    return(
      <div>
        <h1>This is the Elections List</h1>
        {this.state.electionNodes}
      </div>
    );
  }
});

