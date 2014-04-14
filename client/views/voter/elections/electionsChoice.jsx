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
    var isPicked = ballot.isPicked(this.props.questionIndex, this.props.choiceIndex);
    if (!this.props.isAbstain)
      return(
        <div className={isPicked ? "light-green-bg" : "dark-blue-bg"}>
          <div className={isPicked ? "green-bg" : "light-blue-bg"}>
            <h2 className="centered-container">{choice.name}</h2>  
          </div>
          <div className="centered-container">
            <ElectionsChoiceImage choice={choice} />
            <p className="body-text">{choice.description}</p>
            {isPicked ?
              <a className="large-button" onClick={this.toggleSelect}>Selected</a>
              : <a className="large-button" onClick={this.toggleSelect}>Select</a>
            }
          </div>
        </div>
      );
    else
      return(
        <div className={isPicked ? "light-green-bg" : "dark-blue-bg"}>
          <h2 className={isPicked ? "green-bg" : "light-blue-bg"}>Abstain</h2>
          <p>Abstain from answering this question</p>
          <button>Select</button>
        </div>
      );
  }
});

ElectionsChoiceImage = React.createClass({
  render: function() {
    var defaultImage = "http://www.pentagram.com/en/NYUAD_Pattern_620W.gif";
    var choice = this.props.choice;
    var style = {
      "background-image": "url(" +choice.image+")"
    };
    if (choice.image.length > 0)
      return(
        <div className="circular-photo" style={style}></div>
      );
    else
      return(
        <img className="circular-photo"  src={defaultImage} alt={choice.name} />
      );
  }
});
