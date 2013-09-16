(global ? window).createCallback = (run, callback) ->
    return (err, resp) ->
            if err? 
                throw new Meteor.userError.throwError(err.reason)
            else 
                if run?
                    if callback?
                        run(resp, callback)
                    else
                        run(resp)