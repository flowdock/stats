# Statistics client


    Stats = require 'stats'
    stats = new Stats
      namespace: 'applicationName'
      sdUrl: 'url to statsd'
      gaugePollPeriodMs: 5 * 1000 # has a default

    # counters are sent to statsd
    stats.increment 'counter', 1
    stats.gauge 'gauge', 1
    ...

    # gauges can take event emitters which set the gauge value
    stats.gauge 'eventedGauge', event: 'foo', emitter: emitter
    emitter.emit 'foo', 100

    # gauges can take also a poll function which peridically
    # updates the gauge value
    stats.gauge 'time', => Date.now()

    # key values that are not sent to stats
    stats.key 'started-at', new Date.now()

    # dynamically get the key value when needed
    stats.key 'fun', ->
      #count something

    ...

    # serve the json containing the counters and keys
    # json from under '/status'
    app.get '/status', stats.render
