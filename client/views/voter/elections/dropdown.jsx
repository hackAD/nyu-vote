Dropdown = React.createClass({
    getInitialState: function(){
        return{
            visible: false,
        };
    },

    toggle: function() {
        this.setState({ visible: true });
        document.addEventListener("click", this.hide);
    },

    hide: function() {
        this.setState({ visible: false });
        document.removeEventListener("click", this.hide);
    },

    pick: function(priority, takenIndex = -1){
        var ballot = this.props.ballot;
        ballot.pick(this.props.questionIndex, this.props.choiceIndex, priority);
        if (takenIndex != -1){
            ballot.pick(this.props.questionIndex, takenIndex, 0);
        }
    },

    render: function(){
        var ballot = this.props.ballot;
        var question = this.props.question;
        var choice = ballot.questions[this.props.questionIndex].choices[this.props.choiceIndex];
        var message = (choice.value == 0 ? "Select Rank" : "Rank " + choice.value.toString());
        return(
        <div>
        <a href="#" className={"large-button" + (choice.value > 0 ? " green-bg" : "")} onClick={this.toggle}>{message}</a>
        <div>{this.state.visible ? this.renderDropdown() : null}</div>
        </div>
        );
    },

    renderDropdown: function(){
        var items = [];
        var ballot = this.props.ballot;
        var question = this.props.question;
        var choice = ballot.questions[this.props.questionIndex].choices[this.props.choiceIndex];
        for (var i = 1; i <= question.choices.length; i++){
            var selected = choice.value == i;
            var taken = false;
            var name = null;
            var takenIndex = -1;
            var choices = ballot.questions[this.props.questionIndex].choices;
            for (var j = 0; j < question.choices.length; j++){
                currentChoice = choices[j];
                if (j != this.props.choiceIndex && currentChoice.value == i){
                    taken = true;
                    name = ballot.election.questions[this.props.questionIndex].choices[j].name;
                    takenIndex = j;
                    break;
                }
            }
            var text = i.toString();
            var takenNode = (
                <div>
                    ({name})
                </div>
            );
            var cx = React.addons.classSet;
            var buttonClass = cx({"large-button": true,  "green-bg" : selected, "deep-blue-bg": taken});
            items.push(<a href="#" className={buttonClass} onClick={this.pick.bind(null, i, takenIndex)}>{text} {(taken ? takenNode : null)}</a>);
        }
        items.push(<a href="#" className="large-button" onClick={this.pick.bind(null, 0)}>Unrank</a>);
        return items;
    }
});