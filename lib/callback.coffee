(global ? window).createCallback = (run, callback = null) ->
    return (err, resp) ->
        if err? 
            console.log(1)
            Meteor.userError.throwError(err.reason)
        else 
            if run?
                if callback?
                    run(resp, callback)
                else
                    run(resp)