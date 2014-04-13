root = global ? window

root.Utilities = {}

RESERVED_SLUGS = [
  "admin",
  "about"
]

Utilities.generateSlug = (title, collection)->
  slug = title.toLowerCase()
              .replace(/[^\w ]+/g, '')
              .replace(/\ +/g, '-')
  if slug.length == 0
    throw new Meteor.Error(500, "Please use alphanumeric letters in your name")
  if slug in RESERVED_SLUGS
    slug += "0"
  duplicatesCount = collection.find({slug: slug}).count()
  if duplicatesCount != 0
    slug += "-" + duplicatesCount
  return slug


