root = global ? window
root.isDevEnv =  () ->
  if process.env.ROOT_URL == "http://localhost:3000/"
    return true
  else
    return false
