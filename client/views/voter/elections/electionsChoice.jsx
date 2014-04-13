/** @jsx React.DOM */

ElectionsChoice = React.createClass({
  abstain: function() {
    var ballot = this.props.ballot;
    ballot.abstain(this.props.questionIndex);
  },
  toggleSelect: function() {
    var ballot = this.props.ballot;
    ballot.pick(this.props.questionIndex, this.props.choiceIndex);
  },
  render: function() {
    var choice = this.props.choice;
    var ballot = this.props.ballot;
    var defaultImage = "http://www.pentagram.com/en/NYUAD_Pattern_620W.gif";
    if (!this.props.isAbstain)
      return(
        <div>
          <h1>{choice.name}</h1>
          <p>{choice.description}</p>
          {choice.image.length > 0 ?
            <img src={choice.image} alt={choice.name} />
            : <img src={defaultImage} alt={choice.name} />
          }
          {ballot.isPicked(this.props.questionIndex, this.props.choiceIndex) ?
            <button onClick={this.toggleSelect}>Selected</button>
            : <button onClick={this.toggleSelect}>Select</button>
          }
        </div>
      );
    else
      return(
        <div>
          <h1>Abstain</h1>
          <p>Abstain from answering this question</p>
          <button>Select</button>
        </div>
      );
  }

});
