seed = () ->
  if Meteor.users.find().count() == 0
    Accounts.createUser(
      username:"devAdmin"
      password:"password"
      email: "admin@nyu.edu"
      profile:
        name: "devAdmin"
        netId: "devAdmin"
    )
  if Groups.find().count() == 0
    Groups.insert(
      name: "Global Admins"
      description: "This is the initial group."
      creator: "devAdmin"
      admins: ["devAdmin"]
      netIds: ["devAdmin"]
    )
    # The group that gives people the power to create groups & elections
    Groups.insert(
      name: "Global Whitelist"
      description: "This is the list that designates who has admin access"
      creator: "devAdmin"
      admins: ["devAdmin"]
      netIds: ["devAdmin"]
    )
    Groups.insert(
      name: "nyuad_2016"
      description: "NYUAD Class of 2016."
      creator: "devAdmin"
      admins: ["devAdmin", "random_admin_1", "random_admin_2"]
      netIds: ["devAdmin", "random_admin_1", "2016_rep_candidate_1",
        "2016_rep_candidate_2", "nyuad_2016_student_1",
        "nyuad_2016_student_2", "devAdmin"]
    )
    Groups.insert(
      name: "nyu_2015"
      description: "NYU Class of 2015."
      creator: "random_admin_1"
      admins: ["random_admin_3"]
      netIds: ["random_admin_2", "nyu_2015_student_1", "nyu_2015_student_2",
        "nyu_2015_student_3", "devAdmin"]
    )

    election = new Election(
      name: "nyuad_2016_rep_election"
      description: "Election for class representatives of NYUAD class of 2016."
      status: "open"
      creator: "random_admin_1"
      groups: [Groups.findOne({name:"nyuad_2016"})._id]
      questions: []
    )
    questionId = election.addQuestion(
      name: "rep_question"
      description: "Class rep."
    )
    election.addChoice(questionId,
      name: "2016_rep_choice_1"
      description: "I am the best candidate because I am the first candidate"
      image: "http://reggiestake.files.wordpress.com/2012/06/darth-vader-3.jpeg"
    )
    election.addChoice(questionId,
      name: "2016_rep_choice_2"
      description: "I am the best candidate because I don't rely on numbering."
    )

    election.put()
    election = new Election(
      name: "gnu_best_election"
      description: "Election for the best in everything."
      status: "open"
      creator: "random_admin_3"
      groups: [Groups.findOne({name:"nyu_2015"})._id]
      questions: []
    )
    questionId = election.addQuestion(
      name: "gnu_best_coder_question"
      description: "Best coder"
    )
    election.addChoice(questionId,
      name: "gnu_best_coder_choice_1"
      description: "1337"
    )
    election.addChoice(questionId,
      name: "gnu_best_coder_choice_2"
      description: "I'm hardcore."
      image: "http://benswann.com/wp-content/uploads/2013/08/Presbo.jpg"
    )
    questionId = election.addQuestion(
      name: "gnu_best_painter_question"
      description: "Best painter"
    )
    election.addChoice(questionId,
      name: "gnu_best_painter_choice_1"
      description: "I'm lonely"
    )

    election.put()
    election = new Election(
      name: "awesomest_election"
      description: "Who is the awesomest?"
      status: "closed"
      creator: "devAdmin"
      groups: [
        Groups.findOne({name:"nyuad_2016"})._id,
        Groups.findOne({name:"nyu_2015"})._id
      ]
      questions: []
    )
    questionId = election.addQuestion(
      name: "awesomest_question"
      description: "Awesomest!!!"
    )
    election.addChoice(questionId,
      name: "awesomest_choice_1"
      description: "Moiri Gamboni"
    )
    election.put()

Meteor.startup () ->
  seed()

Meteor.methods(
  reseed: () ->
    user = Meteor.user()
    if user.isGlobalAdmin()
      Elections.remove({})
      Groups.remove({})
      seed()
)
