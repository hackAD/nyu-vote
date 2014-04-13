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
      name: "NYUAD 2016 Rep Election"
      description: "Election for class representatives of NYUAD class of 2016."
      groups: [Groups.findOne({name:"nyuad_2016"})._id]
    )
    questionId = election.addQuestion(
      name: "Who is the coolest person to be around?"
      description: "The coolest person is someone who you think is most worthy of ruling the world."
    )
    election.addChoice(questionId,
      name: "Brett Bolton"
      description: "My name is Brett and I love to play chess.  I also love to skype my parents.  One of my hobbies is to bring freshman to the cheese bread store near our dorms.  I like cheese bread because it reminds me of home.  Did I ever tell you that my mom makes the best cheese bread in the world?   She said that she will make every student in the university Cheese bread if I get elected."
      image: "https://fbcdn-sphotos-e-a.akamaihd.net/hphotos-ak-ash3/t1.0-9/p417x417/1662407_10151929878661903_963907986_n.jpg"
    )
    election.addChoice(questionId,
      name: "Koh Terai"
      description: "You should vote for me because I am nice.  I think about others and I think about myself.  I think, I am a thinker. a philosopher."
      image: "https://fbcdn-sphotos-a-a.akamaihd.net/hphotos-ak-prn2/t31.0-8/1421249_10153579206155001_25743345_o.jpg"
    )
    election.addChoice(questionId,
      name: "Linglang Zhang"
      description: "Coding is an art form.  If you cannot master it, you will not master anything.  Mastery of code is mastery of life.  From the beginning of time, mankind has always been programming even before the invention of computers.  Programming does not always need to be on the computer.  There is programming of the human mind, programming of theatrecal pieces, just programming of everything."
      image: "https://fbcdn-sphotos-f-a.akamaihd.net/hphotos-ak-ash4/t1.0-9/p417x417/1455102_567896989965010_819788213_n.jpg"
    )
    election.put()

    election = new Election(
      name: "The best of GNU Election"
      description: "Election for the best in everything."
      groups: [Groups.findOne({name:"nyu_2015"})._id]
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
      name: "Awesomest Person Election"
      description: "Who is the awesomest?"
      groups: [
        Groups.findOne({name:"nyuad_2016"})._id,
        Groups.findOne({name:"nyu_2015"})._id
      ]
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
    # if user.isGlobalAdmin()
    Elections.remove({})
    Groups.remove({})
    seed()
)
