root = global ? window

root.Log = Meteor.npmRequire("winston")
Log.level = "error"
Meteor.npmRequire("winston-mongodb")

Log.add(Log.transports.MongoDB, {
  db: process.env.MONGO_URL,
  collection: "log",
  capped: true,
  cappedSize: 10000000, #10MB
  level: "verbose"
})
