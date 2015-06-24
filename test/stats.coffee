Stats = require '../src/stats'
require 'should'
sinon = require 'sinon'
{EventEmitter} = require 'events'

describe 'stats', ->
  beforeEach ->
    @clock = sinon.useFakeTimers()
    @stats = new Stats namespace: 'foo', gaugePollPeriodMs: 5 * 1000
    @res =
      contentType: (type) ->
        @_contentType = type
      send: (payload) ->
        @_payload = payload

  afterEach ->
    @clock.restore()

  describe 'gauge', ->
    it 'reacts to events from an event emitter', ->
      events = new EventEmitter
      @stats.gauge 'evented',
        event: 'bar'
        from: events
      @stats.stats.evented.should.eql 0
      events.emit 'foo', 1
      @stats.stats.evented.should.eql 0
      events.emit 'bar', 10
      @stats.stats.evented.should.eql 10

    it 'periodically polls an argument function', ->
      value = 1
      @stats.gauge 'foo', -> value
      @stats.stats.foo.should.eql 1
      value = 10
      @clock.tick 1000
      @stats.stats.foo.should.eql 1
      @clock.tick 10 * 1000
      @stats.stats.foo.should.eql 10

  it 'can increment value', ->
    @stats.increment 'counter', 1
    @stats.stats['counter'].should.eql 1
    @stats.render null, @res
    JSON.parse(@res._payload).counter.should.eql 1

  it 'can render function keys', ->
    @stats.key 'fun', ->
      1
    @stats.render null, @res
    JSON.parse(@res._payload).fun.should.eql 1

  it 'can render plain value keys', ->
    @stats.key 'plain', 1
    @stats.render null, @res
    JSON.parse(@res._payload).plain.should.eql 1
