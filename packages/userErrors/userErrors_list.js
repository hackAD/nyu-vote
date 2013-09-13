Template.userErrors.helpers({
  userErrors: function() {
    return Meteor.userErrors.find();
  }
});

Template.userError.rendered = function() {
  var error = this.data;
  Meteor.defer(function() {
    Meteor.userErrors.update(error._id, {$set: {seen: true}});
  });
};
Template.userError.events = ({
  "click .close": function(e) {
    e.preventDefault();
    $(e.target).parent().css({"display": "none"});
  }
});


