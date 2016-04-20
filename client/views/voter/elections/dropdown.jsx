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

    pick: function(priority){
    	console.log("Picking");
    	ballot = this.props.ballot;
    	console.log(this.props.questionIndex);
    	ballot.pick(this.props.questionIndex, this.props.choiceIndex, priority);
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
			var text = i.toString() + ". priority";
			items.push(<a href="#" className={"large-button" + (selected ? " green-bg" : "")} onClick={this.pick.bind(null, i)}>{text}</a>);
		}
		return items;
	}
});