ElectionsChoice = React.createClass({
  getInitialState: function() {
    return{
      informationVisible: false,
    };
  },

  showInformation: function() {
    this.setState({ informationVisible: true });
    document.addEventListener("click", this.hideInformation);
  },

  hideInformation: function() {
    this.setState({ informationVisible: false });
    document.removeEventListener("click", this.hideInformation);
  },

  abstain: function() {
    var ballot = this.props.ballot;
    if (ballot.isAbstaining(this.props.questionIndex))
      ballot.unAbstain(this.props.questionIndex);
    else {
      var isPickQuestion = this.props.question.type === "pick";
      // If it is not a pick question there will be several choices,
      // and it could therefore be a pain to lose all that information
      if (!isPickQuestion) {
        var selectedChoices = this.props.ballot.selectedChoices(this.props.questionIndex);
        // Since this is the abstain part any selected choice would not be an abstain choice
        // and would therefore be annoying to lose.
        var hasSelectedChoices = selectedChoices.length > 0;
        if (!hasSelectedChoices || hasSelectedChoices && confirm("Abstaining will reset all your current choices, are you sure you wish to proceed?")) {
          ballot.abstain(this.props.questionIndex);
        }
      }
      else {
        ballot.abstain(this.props.questionIndex);
      }
    }
  },

  toggleSelect: function() {
    var ballot = this.props.ballot;
    ballot.pick(this.props.questionIndex, this.props.choiceIndex);
  },

  render: function() {
    var choice = this.props.choice;
    var ballot = this.props.ballot;
    var infoMessage = this.props.infoMessage;
    var defaultImage = "http://www.pentagram.com/en/NYUAD_Pattern_620W.gif";
    var question = this.props.question;
    var isPicked;
    if (!this.props.isAbstain) {
      isPicked = ballot.isPicked(this.props.questionIndex, this.props.choiceIndex);
      return(
        <div className={isPicked ? "light-green-bg" : "dark-blue-bg"}>
          <div className={isPicked ? "green-bg" : "light-blue-bg"}>
            <h2 className="centered-container" style={this.state.informationVisible ? {paddingBottom: 0} : {}}>
              {/* Information is not broken out into it's own react element because it made styling easier when putting some
              things inside the h2 tag and some outside. If the info button was to be used other places than for No Confidence
              it would be smart to break it out to be it's own element and handle this differently*/}
              {choice.name}&nbsp;
              {infoMessage ? <img src="/info.png" className="info-message-icon" onClick={this.showInformation} /> : null}
            </h2>
            {this.state.informationVisible ?
              <p style={{paddingBottom: 10, paddingLeft: 5}}>{infoMessage}</p> : null
            }
          </div>
          <div className="centered-container">
            <ElectionsChoiceImage choice={choice} small={false} />
            <p className="body-text">{choice.description}</p>
            {question.options.type === "rank" ?
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
        <div className={isPicked ? "light-green-bg" : "abstain-header-bg"}>
          <div className={isPicked ? "green-bg" : "abstain-bg"}>
            <h2 className="centered-container">Abstain</h2>
            {infoMessage ?
              <Information message={infoMessage} />
              : null
            }
          </div>
          <div className="centered-container">
            <p>By abstaining you declare no opinion regarding this question</p>
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
    var className = "circular-photo" + (this.props.small ? " small-image" : "");
    var style = {
      "background-image": "url(" +choice.image+")"
    };
    if (choice.image.length > 0)
      return(
        <div className={className} style={style}></div>
      );
    else
      return(
        <img className={className} src={defaultImage} alt={choice.name} />
      );
  }
});
