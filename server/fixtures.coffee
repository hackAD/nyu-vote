Meteor.startup( () ->
  if isDevEnv() and Meteor.users.find().count() == 0
    Accounts.createUser(
      username:"devAdmin"
      password:"password"
      profile:
        name: "devAdmin"
        netId: "devAdmin"
    )
  if isDevEnv() and Groups.find({"name": "global"}).count() == 0
    Groups.insert(
      name: "global"
      description: "This is the initial group."
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
      "2016_rep_candidate_2", "nyuad_2016_student_1", "nyuad_2016_student_2"]
    )
    Groups.insert(
      name: "nyu_2015"
      description: "NYU Class of 2015."
      creator: "random_admin_1"
      admins: ["random_admin_3"]
      netIds: ["random_admin_2", "nyu_2015_student_1", "nyu_2015_student_2", "nyu_2015_student_3"]
    )

    Elections.insert(
      name: "nyuad_2016_rep_election"
      description: "Election for class representatives of NYUAD students of class 2016."
      status: "open"
      creator: "random_admin_1"
      groups: [Groups.findOne({name:"nyuad_2016"})._id]
      voters: []
      questions: []
      options:
        voting_style: "NYUAD"
    )
    question = createQuestion("rep_question", "Class rep.", Elections.findOne({name:"nyuad_2016_rep_election"})._id)
    createChoice("2016_rep_choice_1", "I am the best candidate because I am the first candidate. Logic.",question,"repPic.jpg")
    createChoice("2016_rep_choice_2", "I am the best candidate because I don't rely on stupid numbering.",question,"repPic.jpg")

    Elections.insert(
      name: "gnu_best_election"
      description: "Election for the best in everything."
      status: "open"
      creator: "random_admin_3"
      groups: [Groups.findOne({name:"nyu_2015"})._id]
      voters: []
      questions: []
      options:
        voting_style: "NYU"
    )
    question = createQuestion("gnu_best_coder_question", "Best coder", Elections.findOne({name:"gnu_best_election"})._id)
    createChoice("gnu_best_coder_choice_1", "1337",question)
    createChoice("gnu_best_coder_choice_2", "I'm hardcore.",question, "haxorz.png")
    question = createQuestion("gnu_best_painter_question", "Best painter", Elections.findOne({name:"gnu_best_election"})._id)
    createChoice("gnu_best_painter_choice_1", "I'm lonely",question)

    Elections.insert(
      name: "awesomest_election"
      description: "Who is the awesomest?"
      status: "closed"
      creator: "devAdmin"
      groups: [Groups.findOne({name:"nyuad_2016"})._id, Groups.findOne({name:"nyu_2015"})._id]
      voters: ["random_admin_1","random_admin_2","nyu_2015_student_3",
      "nyu_2015_student_1", "nyuad_2016_student_2"]
      questions: []
      options:
        voting_style: "NYUAD"
    )
    question = createQuestion("awesomest_question", "Awesomest!!!", Elections.findOne({name:"awesomest_election"})._id)
    createChoice("awesomest_choice_1", "Moiri Gamboni",question)
    id = Elections.findOne({"questions.choices.name":"awesomest_choice_1"}, {fields:{"questions.choices.$._id": 1}}).questions[0].choices[0]._id
    voters = Elections.findOne({name:"awesomest_election"}).voters
    Elections.update(
      {"questions.choices._id": id},
      $push:
        "questions.0.choices.0.votes":
          $each:voters
    )
      
)
