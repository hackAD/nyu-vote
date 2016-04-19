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

    pick: function(){
    	console.log("Picking");
    	ballot = this.props.ballot;
    	console.log(this.props.questionIndex);
    	ballot.pick(this.props.questionIndex, this.props.choiceIndex, 2);
    },

	render: function(){
		ballot = this.props.ballot;
		question = this.props.question;
		choice = ballot.questions[this.props.questionIndex].choices[this.props.choiceIndex];
		console.log(JSON.stringify(ballot));
		var message = (choice.value == 0 ? "Rank" : choice.value.toString() + ". priority");
		return(
		<a href="#" className="large-button" onClick ={this.pick}>{message}</a>
		);
	},

	renderDropdown: function(){
		var items = [];
		for (var i = 1; i <= question.choices.length; i++){
			var text = i.toString() + ". priority";
		}
	}
});