import pymongo
import re

def main():
  with open("mongo_keys.txt") as f
    mongo_uri = f.read().strip()
  client = pymongo.MongoClient(mongo_uri, 10048)
  db = client["nyu-vote"]
  netIds = set()
  group = db.groups.find_one({"slug": "student-government-elections"})
  netIds = netIds.union(set(group["netIds"]))
  election = db.elections.find_one({"slug": "student-government-election-"})
  for ballot in db.ballots.find({"electionId": election["_id"]}):
    netIds.discard(ballot["netId"])
  pattern = re.compile("^[a-zA-Z]{1,6}[0-9]{1,4}$")
  actual_count = 0
  count = 0
  for netId in netIds:
    if pattern.match(netId):
      count += 1
      print(netId + "@nyu.edu,")
  print(count)




if __name__ == "__main__":
  main()
