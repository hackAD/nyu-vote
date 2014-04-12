/** @jsx React.DOM */

ElectionsShow = ReactMeteor.createClass({
  getMeteorState: function() {
    election: Election.fetchOne(Session.get(""))
  },
  render: function() {
    return(
      <div>
        <h1>{this.state.election}</h1>
      </div>
    )
  }

});
