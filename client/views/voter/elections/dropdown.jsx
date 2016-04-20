Dropdown = React.createClass({
	getInitialState: function(){
		return{
			visible: false,
		};
	},

    show: function() {
        this.setState({ visible: true });
        document.addEventListener("click", this.hide);
    },

    hide: function() {
        this.setState({ visible: false });
        document.removeEventListener("click", this.hide);
    },

    pick: function(priority, takenIndex = -1){
    	console.log("Picking");
    	ballot = this.props.ballot;
    	console.log(this.props.questionIndex);
    	ballot.pick(this.props.questionIndex, this.props.choiceIndex, priority);
    	if (takenIndex != -1){
    		ballot.pick(this.props.questionIndex, takenIndex, 0);
    	}
    },

	render: function(){
		ballot = this.props.ballot;
		question = this.props.question;
		choice = ballot.questions[this.props.questionIndex].choices[this.props.choiceIndex];
		console.log(JSON.stringify(ballot));
		var message = (choice.value == 0 ? "Rank" : choice.value.toString() + ". priority");
		return(
		<div>
		<a href="#" className="large-button" onClick={this.show}>{message}</a>
		<div>{this.state.visible ? this.renderDropdown() : <div></div>}</div>
		</div>
		);
	},

	renderDropdown: function(){
		var items = [];
		ballot = this.props.ballot;
		question = this.props.question;
		choice = ballot.questions[this.props.questionIndex].choices[this.props.choiceIndex];
		items.push(<a href="#" className="large-button" onClick={this.pick.bind(null, 0)}>Unrank</a>);
		for (var i = 1; i <= question.choices.length; i++){
			var selected = choice.value == i;
			var taken = false;
			var name;
			var takenIndex = -1;
			choices = ballot.questions[this.props.questionIndex].choices;
			for (var j = 0; j < question.choices.length; j++){
				currentChoice = choices[j];
				if (j != this.props.choiceIndex && currentChoice.value == i){
					taken = true;
					name = ballot.election.questions[this.props.questionIndex].choices[j].name;
					takenIndex = j;
					break;
				}
			}
			var text = i.toString() + ". priority";
			if (taken){
				text += " (this is taken by " + name + ")"
			}
			items.push(<a href="#" className={"large-button" + (selected ? " green-bg" : "")} onClick={this.pick.bind(null, i, takenIndex)}>{text}</a>);
		}
		return items;
	}
});