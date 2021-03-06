ElectionsShow = React.createClass({
  mixins: [ReactMeteorData],
  getMeteorData: function() {
    return {
      election: Election.getActive()
    };
  },
  render: function() {
    return(
      <div>
        <div className="white-bg header">
          <a className="header-exit" href={Router.path("home")}>
            {"< "}Exit
          </a>
          ballot description
          <a className="header-help" href={Router.path("help")}>
            Get Help
          </a>
        </div>
        <div id="ballot-description-wrapper" className="dark-blue-bg">
          <div className="centered-container">
            <h1>{this.data.election.name}</h1>
            <p>{this.data.election.description}</p>
            <a className="large-button" href={Router.path("electionsVote", {slug: this.data.election.slug, questionIndex: 0})}>Start Ballot {"  >"}</a>
          </div>
        </div>
      </div>
    );
  }

});
