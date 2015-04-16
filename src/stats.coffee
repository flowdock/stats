StatsD = require('node-statsd').StatsD
url    = require 'url'
_ = require 'underscore'

class Stats
  constructor: ({@namespace, sdUrl}) ->
    sdUrl = url.parse(sdUrl || 'udp://127.0.0.1:8125')
    @namespace ||= (sdUrl.path && sdUrl.path[1..-1]) || 'flowdock'
    @sd = new StatsD
      host: sdUrl.hostname
      port: sdUrl.port
      prefix: @namespace + '-' + process.env.PORT + '.'
      dnsCache: true

    @keys = {}
    @stats = {}

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
    @sd.gauge(stat, amount, sampleRate)
    @stats[stat] ||= 0
    @stats[stat] = amount

  key: (key, value) ->
    @keys[key] = value

  render: (req, res) =>
    keys = {}
    _.forEach @keys, (v, k) ->
      keys[k] =
        if _.isFunction v
          v null
        else
          v
    status =
      counters: @stats
      keys: keys
    res.contentType 'application/json'
    res.send JSON.stringify status, null, 4

module.exports = Stats
