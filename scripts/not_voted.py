import pymongo
import re

def main():
  with open("mongo_keys.txt") as f:
    mongo_uri = f.read().strip()
  client = pymongo.MongoClient(mongo_uri)
  db = client["nyu-vote"]
  netIds = set()
  for group in db.groups.find():
    netIds = netIds.union(set(group["netIds"]))
  for ballot in db.ballots.find():
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
