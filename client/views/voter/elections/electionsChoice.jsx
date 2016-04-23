ElectionsChoice = React.createClass({
  abstain: function() {
    var ballot = this.props.ballot;
    if (ballot.isAbstaining(this.props.questionIndex))
      ballot.unAbstain(this.props.questionIndex);
    else
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
    var question = this.props.question;
    var isPicked;
    if (!this.props.isAbstain) {
      isPicked = ballot.isPicked(this.props.questionIndex, this.props.choiceIndex);
      return(
        <div className={isPicked ? "light-green-bg" : "dark-blue-bg"}>
          <div className={isPicked ? "green-bg" : "light-blue-bg"}>
            <h2 className="centered-container">{choice.name}</h2>  
          </div>
          <div className="centered-container">
            <ElectionsChoiceImage choice={choice} small={false} />
            <p className="body-text">{choice.description}</p>
            {question.options.type == "rank" ?
              <Dropdown ballot={ballot} question={question} choice={choice} questionIndex={this.props.questionIndex} choiceIndex={this.props.choiceIndex}/>
              :
              (isPicked ?
                <a href="#" className="large-button" onClick={this.toggleSelect}>Selected</a>
                : <a href="#" className="large-button" onClick={this.toggleSelect}>Select</a>
              )
            }
          </div>
        </div>
      );
    } else {
      isPicked = ballot.isAbstaining(this.props.questionIndex);
      return(
        <div className={isPicked ? "light-green-bg" : "dark-blue-bg"}>
          <div className={isPicked ? "green-bg" : "light-blue-bg"}>
            <h2 className="centered-container">Abstain</h2>
          </div>
          <div className="centered-container">
            <p>Abstain from answering this question</p>
            {isPicked ?
              <a href="#" className="large-button" onClick={this.abstain}>Selected</a>
              : <a href="#" className="large-button" onClick={this.abstain}>Select</a>
            }
          </div>
        </div>
      );
    }
  }
});

ElectionsChoiceImage = React.createClass({
  render: function() {
    var defaultImage = "/nyuad-pattern.jpg";
    var choice = this.props.choice;
    var small = this.props.small;
    var style = {
      "background-image": "url(" +choice.image+")"
    };
    if (choice.image.length > 0)
      return(
        <div className={"circular-photo" + (small ? " small" : "")} style={style}></div>
      );
    else
      return(
        <img className={"circular-photo" + (small ? " small" : "")} src={defaultImage} alt={choice.name} />
      );
  }
});
