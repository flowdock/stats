StatsD = require('node-statsd').StatsD
url    = require 'url'
_ = require 'underscore'

class Stats
  constructor: ({@namespace, sdUrl, @gaugePollPeriodMs}) ->
    @gaugePollPeriodMs ||= 10 * 1000
    sdUrl = url.parse(sdUrl || 'udp://127.0.0.1:8125')
    @namespace ||= (sdUrl.path && sdUrl.path[1..-1]) || 'flowdock'
    @sd = new StatsD
      host: sdUrl.hostname
      port: sdUrl.port
      prefix: @namespace + '-' + process.env.PORT + '.'
      dnsCache: true

    @keys = {}
    @stats = {}
    @_gaugePolls = {}
    setInterval @_pollGauges, @gaugePollPeriodMs

  increment: (stat, count = 1, sampleRate = 1) ->
    @sd.increment(stat, count, sampleRate)
    @stats[stat] ||= 0
    @stats[stat] += count

  decrement: (stat, count = 1, sampleRate = 1) ->
    @sd.decrement(stat, count, sampleRate)
    @stats[stat] ||= 0
    @stats[stat] -= count

  timing: (stat, time, sampleRate = 1) ->
    @sd.timing stat, time, sampleRate

  gauge: (stat, amount, sampleRate = 1) ->
    if _.isFunction amount
      @_gaugePoller stat, amount, sampleRate
    else
      @sd.gauge(stat, amount, sampleRate)
      @stats[stat] ||= 0
      @stats[stat] = amount

  _pollGauges: =>
    _.forEach @_gaugePolls, ({fn, rate}, stat) =>
      now = fn()
      @sd.gauge stat, now, rate
      @stats[stat] = now

  _gaugePoller: (stat, fn, sampleRate) ->
    now = fn()
    @sd.gauge stat, now, sampleRate
    @stats[stat] = now
    @_gaugePolls[stat] =
      fn: fn
      sampleRate: sampleRate

  key: (key, value) ->
    @keys[key] = value

  render: (req, res) =>
    status = _.clone @stats
    _.forEach @keys, (v, k) ->
      status[k] =
        if _.isFunction v
          v null
        else
          v
    res.contentType 'application/json'
    res.send JSON.stringify status, null, 4

module.exports = Stats
