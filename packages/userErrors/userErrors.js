Meteor.userErrors = new Meteor.Collection(null);

Meteor.userError = {
  throwError: function(message) {
    Meteor.userErrors.insert({message: message, seen: false});
  },
  clear: function() {
    Meteor.userErrors.remove({seen: true});
  }
};
