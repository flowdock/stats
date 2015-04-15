# Statistics client


    Stats = require 'stats'
    stats = new Stats
      namespace: 'applicationName'
      sdUrl: 'url to statsd'

    # counters are sent to statsd
    stats.increment 'counter', 1
    stats.gauge 'gauge', 1
    ...

    # key values that are not sent to stats
    stats.key 'started-at', new Date.now()

    # dynamically get the key value when needed
    stats.key 'fun', ->
      #count something

    ...

    # serve the json containing the counters and keys
    # json from under '/status'
    app.get '/status', stats.render
